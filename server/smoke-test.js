/* Standalone smoke test for the Truco relay. Not part of the deployable image. */
'use strict';
const http = require('http');
const WebSocket = require('ws');

const PORT = process.env.PORT || 8443;
const base = `http://127.0.0.1:${PORT}`;
const wsUrl = `ws://127.0.0.1:${PORT}`;

let failures = 0;
function check(cond, label) {
    console.log(`${cond ? 'PASS' : 'FAIL'}: ${label}`);
    if (!cond) failures++;
}
const open = () => new Promise((res) => { const ws = new WebSocket(wsUrl); ws.on('open', () => res(ws)); });
const next = (ws) => new Promise((res) => ws.once('message', (d) => res(JSON.parse(d.toString()))));
const send = (ws, obj) => ws.send(JSON.stringify(obj));

(async () => {
    // /health
    await new Promise((res) => http.get(`${base}/health`, (r) => {
        check(r.statusCode === 200, 'GET /health returns 200'); r.resume(); res();
    }));

    const host = await open();
    check((await next(host)).type === 'connected', 'host receives connected');
    send(host, { type: 'hello', version: '1.0.0', name: 'Host' });
    check((await next(host)).type === 'hello_ok', 'host handshake hello_ok');

    send(host, { type: 'create_room', variant: 'paulista' });
    const created = await next(host);
    check(created.type === 'room_created' && created.roomCode.length === 6, 'room_created with 6-char code');
    const code = created.roomCode;

    const guest = await open();
    await next(guest); // connected
    send(guest, { type: 'hello', version: '1.0.0', name: 'Guest' });
    await next(guest); // hello_ok
    send(guest, { type: 'join_room', roomCode: code });

    const hostJoined = await next(host); // opponent_joined
    const hostStart = await next(host); // game_started
    const guestStart = await next(guest); // game_started
    check(hostJoined.type === 'opponent_joined' && hostJoined.opponentName === 'Guest', 'host sees opponent_joined');
    check(hostStart.type === 'game_started' && hostStart.seat === 0, 'host game_started seat 0');
    check(guestStart.type === 'game_started' && guestStart.seat === 1, 'guest game_started seat 1');

    // Relay a play_card from host -> guest
    send(host, { type: 'play_card', card: { suit: 'clubs', value: 4 } });
    const relayed = await next(guest);
    check(relayed.type === 'play_card' && relayed.seat === 0 && relayed.card.value === 4,
        'play_card relayed to opponent with seat tag');

    // Version gate
    const oldClient = await open();
    await next(oldClient);
    send(oldClient, { type: 'hello', version: '0.0.1', name: 'Old' });
    check((await next(oldClient)).type === 'error', 'old version rejected');

    // join unknown room
    send(guest, { type: 'join_room', roomCode: 'ZZZZZZ' });
    check((await next(guest)).type === 'error', 'join unknown room errors');

    host.close(); guest.close(); oldClient.close();
    setTimeout(() => { console.log(failures ? `\n${failures} FAILURES` : '\nALL PASSED'); process.exit(failures ? 1 : 0); }, 200);
})().catch((e) => { console.error('ERROR', e); process.exit(2); });
