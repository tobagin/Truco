-- Optional Supabase schema for Truco multiplayer persistence.
-- Apply this only if you configure SUPABASE_URL / SUPABASE_KEY.
-- The server runs fine in memory-only mode without it.

create table if not exists games (
    id           bigint generated always as identity primary key,
    room_code    text        not null,
    variant      text        not null,
    result       text        not null,
    moves        integer     not null default 0,
    created_at   timestamptz not null,
    ended_at     timestamptz not null default now()
);

create index if not exists games_variant_idx on games (variant);
create index if not exists games_ended_at_idx on games (ended_at);
