-- I24H initial backend schema
-- Run in the Supabase SQL Editor for the I24H project.
-- Never expose the service_role key in the Flutter application.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  role text not null default 'faithful'
    check (role in ('faithful', 'animateur', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  presenter text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint programs_valid_time check (ends_at is null or ends_at > starts_at)
);

create table if not exists public.replay_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  presenter text,
  media_path text not null,
  duration_seconds integer check (duration_seconds is null or duration_seconds > 0),
  recorded_at timestamptz,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.prayer_intentions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  message text not null check (char_length(trim(message)) between 3 and 3000),
  is_private boolean not null default true,
  status text not null default 'received'
    check (status in ('received', 'in_prayer', 'answered', 'archived')),
  created_at timestamptz not null default now()
);

create table if not exists public.donations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete restrict,
  amount_xof integer not null check (amount_xof >= 100),
  currency text not null default 'XOF' check (currency = 'XOF'),
  provider text not null check (provider in ('kkiapay', 'fedapay', 'cinetpay', 'other')),
  provider_reference text unique,
  status text not null default 'pending'
    check (status in ('pending', 'succeeded', 'failed', 'cancelled', 'refunded')),
  created_at timestamptz not null default now(),
  confirmed_at timestamptz
);

create index if not exists programs_published_start_idx
  on public.programs (starts_at) where is_published = true;
create index if not exists replay_items_published_date_idx
  on public.replay_items (recorded_at desc) where is_published = true;
create index if not exists prayer_intentions_user_created_idx
  on public.prayer_intentions (user_id, created_at desc);
create index if not exists donations_user_created_idx
  on public.donations (user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.programs enable row level security;
alter table public.replay_items enable row level security;
alter table public.prayer_intentions enable row level security;
alter table public.donations enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

-- Role is deliberately not client-editable. Profile updates are restricted to
-- non-privileged columns by column-level grants.
revoke update on public.profiles from authenticated;
grant update (full_name, phone, updated_at) on public.profiles to authenticated;

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists "Published programs are readable" on public.programs;
create policy "Published programs are readable"
  on public.programs for select to authenticated
  using (is_published = true);

drop policy if exists "Published replays are readable" on public.replay_items;
create policy "Published replays are readable"
  on public.replay_items for select to authenticated
  using (is_published = true);

drop policy if exists "Users can submit their own prayer intentions" on public.prayer_intentions;
create policy "Users can submit their own prayer intentions"
  on public.prayer_intentions for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Users can read their own prayer intentions" on public.prayer_intentions;
create policy "Users can read their own prayer intentions"
  on public.prayer_intentions for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users can read their own donations" on public.donations;
create policy "Users can read their own donations"
  on public.donations for select to authenticated
  using (user_id = (select auth.uid()));

-- Intentionally no client insert/update policy on donations. Payment records
-- must be created and confirmed by a trusted server/Edge Function after
-- verifying the payment provider's response or webhook.

-- Private bucket: use authenticated, time-limited signed URLs for replay
-- playback. Uploads are reserved for a trusted admin/server workflow.
insert into storage.buckets (id, name, public)
values ('i24h-replays', 'i24h-replays', false)
on conflict (id) do nothing;

drop policy if exists "Authenticated users can read replay media" on storage.objects;
create policy "Authenticated users can read replay media"
  on storage.objects for select to authenticated
  using (bucket_id = 'i24h-replays');

-- Do not add a client upload policy for this bucket. Admin uploads should be
-- performed by a trusted server or a future role-checked Edge Function.
