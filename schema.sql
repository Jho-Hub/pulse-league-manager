
-- Pulse League Manager: Supabase schema
-- Run this in Supabase SQL Editor before deploying the web app.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'staff' check (role in ('admin','staff')),
  created_at timestamptz not null default now()
);

create table if not exists public.league_settings (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  value jsonb not null default '[]'::jsonb
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  player_code text,
  first_name text,
  last_name text,
  phone text,
  email text,
  division text,
  team text,
  jersey text,
  registration_fee numeric(10,2) default 0,
  paid numeric(10,2) default 0,
  payment_method text,
  waiver text default 'No',
  emergency_contact text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  division text,
  coach text,
  phone text,
  email text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  game_number integer,
  division text,
  game_date date,
  game_time time,
  court text,
  home_team text,
  away_team text,
  home_score integer,
  away_score integer,
  status text default 'Scheduled',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  team text,
  player text,
  fee numeric(10,2) default 0,
  amount_paid numeric(10,2) default 0,
  date_paid date,
  method text,
  reference text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  game_number integer,
  player_id text,
  player text,
  team text,
  present text default 'Yes',
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.bracket_matches (
  id uuid primary key default gen_random_uuid(),
  match_name text not null,
  team_a text,
  score_a integer,
  team_b text,
  score_b integer,
  winner text,
  sort_order integer default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Create/update timestamp trigger.
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists players_updated_at on public.players;
create trigger players_updated_at before update on public.players
for each row execute function public.set_updated_at();

drop trigger if exists teams_updated_at on public.teams;
create trigger teams_updated_at before update on public.teams
for each row execute function public.set_updated_at();

drop trigger if exists games_updated_at on public.games;
create trigger games_updated_at before update on public.games
for each row execute function public.set_updated_at();

drop trigger if exists bracket_updated_at on public.bracket_matches;
create trigger bracket_updated_at before update on public.bracket_matches
for each row execute function public.set_updated_at();

-- Basic RLS: authenticated league users can work with league data.
alter table public.profiles enable row level security;
alter table public.league_settings enable row level security;
alter table public.players enable row level security;
alter table public.teams enable row level security;
alter table public.games enable row level security;
alter table public.payments enable row level security;
alter table public.attendance enable row level security;
alter table public.bracket_matches enable row level security;

create policy "authenticated profiles" on public.profiles for all to authenticated using (true) with check (true);
create policy "authenticated settings" on public.league_settings for all to authenticated using (true) with check (true);
create policy "authenticated players" on public.players for all to authenticated using (true) with check (true);
create policy "authenticated teams" on public.teams for all to authenticated using (true) with check (true);
create policy "authenticated games" on public.games for all to authenticated using (true) with check (true);
create policy "authenticated payments" on public.payments for all to authenticated using (true) with check (true);
create policy "authenticated attendance" on public.attendance for all to authenticated using (true) with check (true);
create policy "authenticated bracket" on public.bracket_matches for all to authenticated using (true) with check (true);

-- New-user profile helper.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, display_name)
  values(new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1)))
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
