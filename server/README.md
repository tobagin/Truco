# Truco Multiplayer Server

A lightweight **WebSocket relay** that pairs two players into a room and
forwards Truco game actions between them. It mirrors the architecture of the
sibling [Draughts](https://github.com/tobagin/draughts) server so it deploys
the same way.

The relay is **not** an authoritative rules engine — the Truco rules live in
the clients. The server only handles room lifecycle, matchmaking,
reconnection, basic sanity checks, and (optionally) stats persistence.

## Running

### With Docker (recommended)

```bash
cd server
cp .env.example .env        # optional: edit for Supabase
docker compose up --build -d
```

### Directly with Node.js (>= 18)

```bash
cd server
npm install
npm start          # or: npm run dev  (auto-reload via nodemon)
```

The server listens on `PORT` (default **8443**).

## Endpoints

| Path       | Purpose                                   |
|------------|-------------------------------------------|
| `ws://host:8443/` | WebSocket game connection          |
| `GET /health`     | Liveness probe (`{"status":"ok"}`) |
| `GET /stats`      | JSON metrics snapshot              |

For production, terminate TLS at a reverse proxy (nginx/Caddy/Traefik) and
expose `wss://`.

## Persistence

Set `SUPABASE_URL` and `SUPABASE_KEY` to persist completed games (see
`supabase-schema.sql`). If unset, the server keeps everything in memory.

## Wire protocol (v1.0.0)

All messages are JSON objects with a `type` string and a `timestamp`
(milliseconds). The connection handshake is:

1. Server → `connected` `{ clientId, requiredVersion }`
2. Client → `hello` `{ version, name }`
3. Server → `hello_ok` (or `error` `version_too_old`, then closes)

### Client → Server

| Type | Payload | Meaning |
|------|---------|---------|
| `hello` | `version`, `name` | Identify + version-gate |
| `create_room` | `variant` | Create a private room, get a code |
| `join_room` | `roomCode` | Join an existing room |
| `quick_match` | `variant` | Enter matchmaking for a variant |
| `cancel_quick_match` | — | Leave the matchmaking queue |
| `reconnect` | `roomCode`, `seat` | Reclaim a seat after a drop |
| `resign` | — | Forfeit the current game |
| `game_ended` | `result` | Report a finished game |
| `ping` | — | Latency check (server replies `pong`) |

### In-game actions (relayed verbatim to the opponent)

`play_card`, `call_truco`, `respond_truco`, `run`, `call_envido`,
`call_flor`, `respond_bet`, `mao_de_11_decision`, `signal`, `chat`

Each is forwarded to the opponent with the sender's `seat` (0/1) attached.
Their payloads are defined by the client (see `src/services/network/`).

### Server → Client

| Type | Payload | Meaning |
|------|---------|---------|
| `connected` | `clientId`, `requiredVersion` | Connection accepted |
| `hello_ok` | — | Handshake accepted |
| `room_created` | `roomCode`, `variant` | Room ready, share the code |
| `opponent_joined` | `opponentName` | Second player arrived |
| `queued` | `variant` | Waiting for a quick-match opponent |
| `quick_match_cancelled` | — | Left the queue |
| `game_started` | `roomCode`, `variant`, `seat`, `firstDealer`, `opponentName` | Both players present; begin |
| `opponent_disconnected` | `graceMs` | Opponent dropped, grace window started |
| `opponent_reconnected` | — | Opponent came back |
| `opponent_forfeited` | — | Opponent did not return in time |
| `opponent_resigned` | — | Opponent resigned |
| `reconnected` | `roomCode`, `variant`, `seat`, `moves` | Your seat restored |
| `game_ended` | `result` | Game finished |
| `room_expired` | — | Room reaped for inactivity |
| `pong` | — | Reply to `ping` |
| `error` | `code`, `message` | Something went wrong |

## Constants

| Name | Value |
|------|-------|
| Default port | 8443 |
| Room code length | 6 (unambiguous alphabet) |
| Required client version | 1.0.0 |
| Disconnect grace | 60 s |
| Inactivity timeout | 30 min |
| Keepalive ping | 25 s |
