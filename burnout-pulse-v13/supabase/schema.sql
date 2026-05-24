-- ============================================================
-- Burnout Pulse: Supabase schema
-- ============================================================
-- Run this in the Supabase SQL editor on a new project.
-- It creates the tables and the row-level security policies that
-- keep each user's data private. Read SUPABASE_SETUP.md first.
--
-- The design rule behind every policy below: a signed-in user can
-- read and write their own rows, read a friend's chat messages only
-- inside a shared thread, and read only anonymous handles and scores
-- on the leaderboard. Nothing else is exposed.
-- ============================================================

-- ---------- profiles ----------
-- One row per user. Created on sign-up. Holds the display name and
-- the optional anonymous leaderboard handle.

create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  first_name    text not null,
  handle        text unique,
  on_board      boolean not null default false,
  created_at    timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ---------- checkins ----------
-- One row per saved check-in. answers is the six-dimension map.

create table if not exists public.checkins (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  score         int not null check (score between 0 and 100),
  band          text not null,
  answers       jsonb not null,
  created_at    timestamptz not null default now()
);

alter table public.checkins enable row level security;

create policy "read own checkins"
  on public.checkins for select
  using (auth.uid() = user_id);

create policy "insert own checkins"
  on public.checkins for insert
  with check (auth.uid() = user_id);

create policy "delete own checkins"
  on public.checkins for delete
  using (auth.uid() = user_id);

-- ---------- coach_messages ----------
-- The coach conversation log. role is 'user', 'coach', or 'care'.
-- Private to the user. Nobody else can read it, including friends.

create table if not exists public.coach_messages (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references auth.users(id) on delete cascade,
  role          text not null check (role in ('user','coach','care')),
  body          text not null,
  created_at    timestamptz not null default now()
);

alter table public.coach_messages enable row level security;

create policy "read own coach messages"
  on public.coach_messages for select
  using (auth.uid() = user_id);

create policy "insert own coach messages"
  on public.coach_messages for insert
  with check (auth.uid() = user_id);

create policy "delete own coach messages"
  on public.coach_messages for delete
  using (auth.uid() = user_id);

-- ---------- leaderboard ----------
-- The leaderboard must show ONLY an anonymous handle and a score.
-- It must never expose first_name, email, or user_id.
--
-- Postgres row-level security is row-level, not column-level: any
-- read policy on `profiles` would expose the whole profile row,
-- including the real name. So the leaderboard is not a view over
-- profiles. It is a security-definer function that selects only the
-- two safe columns and returns them. The function runs with elevated
-- rights, but it can only ever hand back handle + score, so there is
-- nothing sensitive to leak.

create or replace function public.get_leaderboard()
returns table (handle text, score int)
language sql
security definer
set search_path = public
as $$
  select p.handle, c.score
  from public.profiles p
  join lateral (
    select score
    from public.checkins
    where user_id = p.id
    order by created_at desc
    limit 1
  ) c on true
  where p.on_board = true and p.handle is not null
  order by c.score asc;
$$;

-- Only signed-in users may call it.
revoke all on function public.get_leaderboard() from public;
grant execute on function public.get_leaderboard() to authenticated;

-- ---------- friendships ----------
-- A friendship is one row. requester and addressee are both users.
-- status is 'pending' or 'accepted'.

create table if not exists public.friendships (
  id            uuid primary key default gen_random_uuid(),
  requester     uuid not null references auth.users(id) on delete cascade,
  addressee     uuid not null references auth.users(id) on delete cascade,
  status        text not null default 'pending' check (status in ('pending','accepted')),
  created_at    timestamptz not null default now(),
  unique (requester, addressee)
);

alter table public.friendships enable row level security;

-- A user can see a friendship row if they are either side of it.
create policy "read own friendships"
  on public.friendships for select
  using (auth.uid() = requester or auth.uid() = addressee);

create policy "create friendship as requester"
  on public.friendships for insert
  with check (auth.uid() = requester);

-- Only the addressee can move a request to accepted.
create policy "addressee updates friendship"
  on public.friendships for update
  using (auth.uid() = addressee);

create policy "either side deletes friendship"
  on public.friendships for delete
  using (auth.uid() = requester or auth.uid() = addressee);

-- ---------- messages ----------
-- Friend-to-friend chat. Each row belongs to a friendship.

create table if not exists public.messages (
  id            uuid primary key default gen_random_uuid(),
  friendship_id uuid not null references public.friendships(id) on delete cascade,
  sender        uuid not null references auth.users(id) on delete cascade,
  body          text not null,
  created_at    timestamptz not null default now()
);

alter table public.messages enable row level security;

-- A user can read a message only if they belong to its friendship
-- and that friendship is accepted.
create policy "read messages in own accepted friendships"
  on public.messages for select
  using (
    exists (
      select 1 from public.friendships f
      where f.id = messages.friendship_id
        and f.status = 'accepted'
        and (auth.uid() = f.requester or auth.uid() = f.addressee)
    )
  );

-- A user can send a message only as themselves, only into an accepted
-- friendship they belong to.
create policy "send messages in own accepted friendships"
  on public.messages for insert
  with check (
    auth.uid() = sender
    and exists (
      select 1 from public.friendships f
      where f.id = messages.friendship_id
        and f.status = 'accepted'
        and (auth.uid() = f.requester or auth.uid() = f.addressee)
    )
  );

-- Messages are intentionally immutable: there is no update or delete
-- policy, so the row-level security default (deny) applies and no one
-- can edit or remove a sent message. Deleting a friendship cascades
-- and removes its messages; that is the only way they go away.

-- ============================================================
-- Send a friend request by email.
-- The client never gets access to auth.users and never learns the
-- target's user id. This function does the lookup server-side,
-- inserts the friendship as the caller, and returns only a status
-- string. If the email is not a registered user, it says so without
-- confirming or denying anything sensitive beyond that.
-- ============================================================
create or replace function public.request_friend(target_email text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  target_id uuid;
begin
  if auth.uid() is null then
    return 'not_signed_in';
  end if;

  select id into target_id
  from auth.users
  where lower(email) = lower(trim(target_email))
  limit 1;

  if target_id is null then
    return 'no_such_user';
  end if;
  if target_id = auth.uid() then
    return 'thats_you';
  end if;

  insert into public.friendships (requester, addressee)
  values (auth.uid(), target_id)
  on conflict (requester, addressee) do nothing;

  return 'request_sent';
end;
$$;

revoke all on function public.request_friend(text) from public;
grant execute on function public.request_friend(text) to authenticated;

-- ============================================================
-- Auto-create a profile row when a new user signs up.
-- ============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, first_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'first_name', 'there'));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
