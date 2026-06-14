/*
 * Truco multiplayer relay server
 *
 * A lightweight WebSocket relay that pairs two players into a room and
 * forwards game actions between them. Game rules stay authoritative on the
 * clients (the server only performs basic sanity checks and manages room
 * lifecycle, matchmaking and reconnection), mirroring the architecture of
 * the sibling Draughts project so it can be deployed the same way.
 *
 * Persistence (game history / stats) via Supabase is optional: if the
 * SUPABASE_URL / SUPABASE_KEY environment variables are absent the server
 * runs fully in-memory.
 */

'use strict';

const http = require('http');
const crypto = require('crypto');
const { WebSocketServer } = require('ws');

// --------------------------------------------------------------------------
// Configuration
// --------------------------------------------------------------------------

const PORT = parseInt(process.env.PORT || '8443', 10);
const ROOM_CODE_LENGTH = 6;
// Clients older than this are rejected. Bump when the protocol changes in an
// incompatible way.
const REQUIRED_VERSION = '1.0.0';
const DISCONNECT_TIMEOUT_MS = 60 * 1000;        // reconnection grace window
const GAME_INACTIVITY_TIMEOUT_MS = 30 * 60 * 1000;
const PING_INTERVAL_MS = 25 * 1000;             // keepalive ping

// Supported Truco variants for quick-match bucketing.
const VARIANTS = new Set([
    'paulista', 'mineiro', 'argentino', 'uruguayo', 'venezolano',
]);

// --------------------------------------------------------------------------
// Optional Supabase persistence
// --------------------------------------------------------------------------

let supabase = null;
if (process.env.SUPABASE_URL && process.env.SUPABASE_KEY) {
    try {
        const { createClient } = require('@supabase/supabase-js');
        supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);
        console.log('[truco] Supabase persistence enabled');
    } catch (err) {
        console.warn('[truco] Supabase requested but unavailable:', err.message);
    }
} else {
    console.log('[truco] Running in memory-only mode (no Supabase configured)');
}

// --------------------------------------------------------------------------
// State
// --------------------------------------------------------------------------

/** roomCode -> { code, variant, players: [client...], moves: [], createdAt, lastActivity, disconnectTimers: Map } */
const rooms = new Map();
/** clientId -> client metadata */
const clients = new Map();
/** variant -> [client waiting for quick match] */
const quickMatchQueue = new Map();

const stats = {
    startedAt: Date.now(),
    totalConnections: 0,
    roomsCreated: 0,
    quickMatches: 0,
    gamesByVariant: {},
    gamesCompleted: 0,
    peakConcurrentGames: 0,
};

// --------------------------------------------------------------------------
// Helpers
// --------------------------------------------------------------------------

function generateRoomCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no ambiguous chars
    let code;
    do {
        code = '';
        for (let i = 0; i < ROOM_CODE_LENGTH; i++) {
            code += alphabet[crypto.randomInt(alphabet.length)];
        }
    } while (rooms.has(code));
    return code;
}

function send(ws, type, payload = {}) {
    if (ws.readyState !== ws.OPEN) return;
    ws.send(JSON.stringify({ type, timestamp: Date.now(), ...payload }));
}

function sendError(ws, code, message) {
    send(ws, 'error', { code, message });
}

function versionAtLeast(version, required) {
    if (!version) return false;
    const a = version.split('.').map(Number);
    const b = required.split('.').map(Number);
    for (let i = 0; i < b.length; i++) {
        const x = a[i] || 0;
        if (x > b[i]) return true;
        if (x < b[i]) return false;
    }
    return true;
}

function opponentOf(room, client) {
    return room.players.find((p) => p && p.id !== client.id) || null;
}

function touchRoom(room) {
    room.lastActivity = Date.now();
}

function recordVariant(variant) {
    stats.gamesByVariant[variant] = (stats.gamesByVariant[variant] || 0) + 1;
    const active = [...rooms.values()].filter((r) => r.players.filter(Boolean).length === 2).length;
    if (active > stats.peakConcurrentGames) stats.peakConcurrentGames = active;
}

async function persistGameResult(room, result) {
    if (!supabase) return;
    try {
        await supabase.from('games').insert({
            room_code: room.code,
            variant: room.variant,
            result,
            moves: room.moves.length,
            created_at: new Date(room.createdAt).toISOString(),
            ended_at: new Date().toISOString(),
        });
    } catch (err) {
        console.warn('[truco] Failed to persist game result:', err.message);
    }
}

// --------------------------------------------------------------------------
// Room lifecycle
// --------------------------------------------------------------------------

function createRoom(client, variant) {
    const code = generateRoomCode();
    const room = {
        code,
        variant,
        players: [client],
        moves: [],
        createdAt: Date.now(),
        lastActivity: Date.now(),
        disconnectTimers: new Map(),
        started: false,
    };
    rooms.set(code, room);
    client.roomCode = code;
    client.seat = 0;
    stats.roomsCreated++;
    return room;
}

function joinRoom(client, room) {
    client.roomCode = room.code;
    client.seat = room.players.length;
    room.players.push(client);
    touchRoom(room);
}

function startGame(room) {
    if (room.started) return;
    room.started = true;
    recordVariant(room.variant);
    // Randomly choose who deals first.
    const firstDealer = crypto.randomInt(2);
    // Shared deal seed: both clients deal deterministically from this so their
    // decks match every hand without relaying card data.
    const seed = crypto.randomInt(1, 2 ** 31);
    room.seed = seed;
    room.firstDealer = firstDealer;
    room.players.forEach((player, seat) => {
        const opponent = room.players[1 - seat];
        send(player.ws, 'game_started', {
            roomCode: room.code,
            variant: room.variant,
            seat,
            firstDealer,
            seed,
            opponentName: opponent ? opponent.name : 'Opponent',
        });
    });
}

function cleanupRoom(room, reason) {
    for (const timer of room.disconnectTimers.values()) clearTimeout(timer);
    rooms.delete(room.code);
    if (reason) console.log(`[truco] Room ${room.code} closed: ${reason}`);
}

function removeFromQueues(client) {
    for (const [variant, queue] of quickMatchQueue) {
        const idx = queue.findIndex((c) => c.id === client.id);
        if (idx >= 0) {
            queue.splice(idx, 1);
            if (queue.length === 0) quickMatchQueue.delete(variant);
        }
    }
}

// --------------------------------------------------------------------------
// Message handlers
// --------------------------------------------------------------------------

const RELAY_ACTIONS = new Set([
    // In-game actions are relayed verbatim to the opponent. The clients hold
    // the authoritative Truco rules engine.
    'play_card', 'call_truco', 'respond_truco', 'run',
    'call_envido', 'call_flor', 'respond_bet',
    'mao_de_11_decision', 'signal', 'chat',
]);

function handleMessage(client, msg) {
    const room = client.roomCode ? rooms.get(client.roomCode) : null;

    switch (msg.type) {
        case 'create_room': {
            const variant = VARIANTS.has(msg.variant) ? msg.variant : 'paulista';
            const newRoom = createRoom(client, variant);
            send(client.ws, 'room_created', { roomCode: newRoom.code, variant });
            break;
        }

        case 'join_room': {
            const target = rooms.get((msg.roomCode || '').toUpperCase());
            if (!target) { sendError(client.ws, 'room_not_found', 'No room with that code.'); break; }
            if (target.players.filter(Boolean).length >= 2) {
                sendError(client.ws, 'room_full', 'That room is already full.'); break;
            }
            joinRoom(client, target);
            const host = target.players[0];
            send(host.ws, 'opponent_joined', { opponentName: client.name });
            startGame(target);
            break;
        }

        case 'quick_match': {
            const variant = VARIANTS.has(msg.variant) ? msg.variant : 'paulista';
            const queue = quickMatchQueue.get(variant) || [];

            // Drop any stale entry for this client so re-queuing can't duplicate
            // them or pair them against themselves.
            const dup = queue.findIndex((c) => c.id === client.id);
            if (dup >= 0) queue.splice(dup, 1);

            // Skip waiting clients that have gone away or are this same client.
            let waiting = null;
            while (queue.length > 0) {
                const candidate = queue.shift();
                if (candidate.id === client.id) continue;
                if (candidate.ws.readyState === candidate.ws.OPEN) { waiting = candidate; break; }
            }

            if (waiting) {
                if (queue.length === 0) quickMatchQueue.delete(variant);
                else quickMatchQueue.set(variant, queue);
                const newRoom = createRoom(waiting, variant);
                joinRoom(client, newRoom);
                stats.quickMatches++;
                // Tell both sides a match was found before the game payload, so
                // the UI can leave the searching state cleanly.
                send(waiting.ws, 'quick_match_found', { variant });
                send(client.ws, 'quick_match_found', { variant });
                send(waiting.ws, 'opponent_joined', { opponentName: client.name });
                startGame(newRoom);
            } else {
                queue.push(client);
                quickMatchQueue.set(variant, queue);
                send(client.ws, 'queued', { variant });
            }
            break;
        }

        case 'cancel_quick_match': {
            removeFromQueues(client);
            send(client.ws, 'quick_match_cancelled', {});
            break;
        }

        case 'resign': {
            if (!room) break;
            const opp = opponentOf(room, client);
            if (opp) send(opp.ws, 'opponent_resigned', {});
            persistGameResult(room, 'resign');
            stats.gamesCompleted++;
            cleanupRoom(room, 'resign');
            break;
        }

        case 'game_ended': {
            if (!room) break;
            persistGameResult(room, msg.result || 'completed');
            stats.gamesCompleted++;
            const opp = opponentOf(room, client);
            if (opp) send(opp.ws, 'game_ended', { result: msg.result });
            cleanupRoom(room, 'game ended');
            break;
        }

        case 'ping': {
            send(client.ws, 'pong', {});
            break;
        }

        default: {
            if (RELAY_ACTIONS.has(msg.type)) {
                if (!room) { sendError(client.ws, 'not_in_room', 'You are not in a game.'); break; }
                touchRoom(room);
                room.moves.push({ seat: client.seat, type: msg.type, at: Date.now() });
                const opp = opponentOf(room, client);
                if (opp) {
                    // Relay verbatim, tagging the sender's seat.
                    send(opp.ws, msg.type, { ...msg, seat: client.seat });
                }
            } else {
                sendError(client.ws, 'unknown_message', `Unknown message type: ${msg.type}`);
            }
        }
    }
}

// --------------------------------------------------------------------------
// Reconnection
// --------------------------------------------------------------------------

function handleReconnect(client, msg) {
    const room = rooms.get((msg.roomCode || '').toUpperCase());
    if (!room) { sendError(client.ws, 'room_not_found', 'Room no longer exists.'); return false; }
    const seat = msg.seat;
    if (seat !== 0 && seat !== 1) { sendError(client.ws, 'bad_seat', 'Invalid seat.'); return false; }

    const timer = room.disconnectTimers.get(seat);
    if (timer) { clearTimeout(timer); room.disconnectTimers.delete(seat); }

    client.roomCode = room.code;
    client.seat = seat;
    room.players[seat] = client;
    touchRoom(room);

    send(client.ws, 'reconnected', {
        roomCode: room.code,
        variant: room.variant,
        seat,
        seed: room.seed,
        firstDealer: room.firstDealer,
        moves: room.moves,
    });
    const opp = opponentOf(room, client);
    if (opp) send(opp.ws, 'opponent_reconnected', {});
    return true;
}

function handleDisconnect(client) {
    removeFromQueues(client);
    clients.delete(client.id);

    const room = client.roomCode ? rooms.get(client.roomCode) : null;
    if (!room) return;

    const opp = opponentOf(room, client);
    if (opp) send(opp.ws, 'opponent_disconnected', { graceMs: DISCONNECT_TIMEOUT_MS });

    // Hold the seat open for a reconnection grace window.
    const seat = client.seat;
    room.players[seat] = null;
    const timer = setTimeout(() => {
        const stillEmpty = !room.players[seat];
        if (stillEmpty) {
            if (opp && opp.ws.readyState === opp.ws.OPEN) {
                send(opp.ws, 'opponent_forfeited', {});
            }
            cleanupRoom(room, 'disconnect timeout');
        }
    }, DISCONNECT_TIMEOUT_MS);
    room.disconnectTimers.set(seat, timer);
}

// --------------------------------------------------------------------------
// HTTP + WebSocket server
// --------------------------------------------------------------------------

const httpServer = http.createServer((req, res) => {
    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', uptime: Date.now() - stats.startedAt }));
        return;
    }
    if (req.url === '/stats') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            ...stats,
            activeRooms: rooms.size,
            connectedClients: clients.size,
            queued: [...quickMatchQueue.entries()].map(([v, q]) => ({ variant: v, waiting: q.length })),
        }, null, 2));
        return;
    }
    res.writeHead(404); res.end('Not found');
});

const wss = new WebSocketServer({ server: httpServer });

wss.on('connection', (ws) => {
    const client = {
        id: crypto.randomUUID(),
        ws,
        name: 'Player',
        version: null,
        roomCode: null,
        seat: -1,
        isAlive: true,
    };
    clients.set(client.id, client);
    stats.totalConnections++;

    send(ws, 'connected', { clientId: client.id, requiredVersion: REQUIRED_VERSION });

    ws.on('pong', () => { client.isAlive = true; });

    ws.on('message', (data) => {
        let msg;
        try { msg = JSON.parse(data.toString()); }
        catch { sendError(ws, 'bad_json', 'Malformed JSON.'); return; }
        if (!msg || typeof msg.type !== 'string') {
            sendError(ws, 'bad_message', 'Missing message type.'); return;
        }

        // First contact must establish identity + version.
        if (msg.type === 'hello') {
            if (!versionAtLeast(msg.version, REQUIRED_VERSION)) {
                sendError(ws, 'version_too_old',
                    `Client ${msg.version || '?'} is too old; require >= ${REQUIRED_VERSION}.`);
                ws.close();
                return;
            }
            client.name = (msg.name || 'Player').slice(0, 32);
            client.version = msg.version;
            send(ws, 'hello_ok', {});
            return;
        }

        if (msg.type === 'reconnect') { handleReconnect(client, msg); return; }

        handleMessage(client, msg);
    });

    ws.on('close', () => handleDisconnect(client));
    ws.on('error', () => { /* close handler does cleanup */ });
});

// Keepalive: terminate clients that stop responding to pings.
const pingTimer = setInterval(() => {
    for (const client of clients.values()) {
        if (!client.isAlive) { client.ws.terminate(); continue; }
        client.isAlive = false;
        try { client.ws.ping(); } catch { /* ignore */ }
    }
}, PING_INTERVAL_MS);

// Reap inactive rooms.
const reaper = setInterval(() => {
    const now = Date.now();
    for (const room of rooms.values()) {
        if (now - room.lastActivity > GAME_INACTIVITY_TIMEOUT_MS) {
            for (const p of room.players) if (p) send(p.ws, 'room_expired', {});
            cleanupRoom(room, 'inactivity');
        }
    }
}, 60 * 1000);

httpServer.listen(PORT, () => {
    console.log(`[truco] Multiplayer relay listening on :${PORT} (protocol ${REQUIRED_VERSION})`);
});

function shutdown() {
    console.log('[truco] Shutting down...');
    clearInterval(pingTimer);
    clearInterval(reaper);
    for (const client of clients.values()) {
        try { client.ws.close(1001, 'Server shutting down'); } catch { /* ignore */ }
    }
    httpServer.close(() => process.exit(0));
    setTimeout(() => process.exit(0), 5000);
}
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
