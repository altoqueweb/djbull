-- =====================================================================
-- DJ Bull · Base de datos (Supabase)
-- Pegar TODO este archivo en Supabase → SQL Editor → New query → Run.
-- Se puede correr de nuevo sin romper nada.
-- =====================================================================

-- ---------- 1. Administradores (correos que pueden entrar al panel) ----------
create table if not exists public.admins (
  email text primary key
);

insert into public.admins (email) values
  ('contacto.djbull@gmail.com'),
  ('altoque.web1@gmail.com')
on conflict do nothing;

-- ¿El usuario que hizo login es administrador?
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

-- ---------- 2. Ajustes generales (una sola fila) ----------
create table if not exists public.settings (
  id               int primary key default 1 check (id = 1),
  hero_url         text,
  subtitle         text default 'Ultrabailable · Stgo/Iqq/Viña · Eventos y clubes',
  stat_events      text default '+10',
  stat_years       text default '3',
  stat_followers   text default '+1K',
  mix_title        text,
  mix_url          text,
  booking_email    text default 'contacto.djbull@gmail.com',
  instagram_url    text default 'https://www.instagram.com/djbull.cl',
  tiktok_url       text default 'https://www.tiktok.com/@djbull.cl',
  youtube_url      text default 'https://youtube.com/@djbullcl',
  updated_at       timestamptz default now()
);
insert into public.settings (id) values (1) on conflict do nothing;

-- ---------- 3. Flyers ----------
create table if not exists public.flyers (
  id          uuid primary key default gen_random_uuid(),
  category    text not null check (category in ('Cumpleaños','Empresas','Discos','Matrimonios')),
  title       text,
  image_url   text not null,
  position    int default 0,
  created_at  timestamptz default now()
);

-- ---------- 4. Próximas fechas ----------
create table if not exists public.fechas (
  id          uuid primary key default gen_random_uuid(),
  date        date not null,
  title       text not null,
  venue       text,
  city        text,
  ticket_url  text,
  created_at  timestamptz default now()
);

insert into public.fechas (date, title, venue, city)
select * from (values
  ('2026-12-27'::date, 'Prometeo', 'Teatro Alicia', 'Santiago'),
  ('2027-02-12'::date, 'Cocoteo',  'Club Heaven',   'Iquique')
) v(date, title, venue, city)
where not exists (select 1 from public.fechas);

-- ---------- 5. Videos de TikTok (links pegados desde el panel) ----------
create table if not exists public.tiktoks (
  id          uuid primary key default gen_random_uuid(),
  url         text not null check (url ~* '^https://(www\.|vm\.|vt\.)?tiktok\.com/'),
  position    int default 0,
  created_at  timestamptz default now()
);

-- ---------- 6. Solicitudes de booking ----------
create table if not exists public.bookings (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 120),
  email       text not null check (char_length(email) between 3 and 200),
  event_type  text check (char_length(event_type) <= 60),
  event_date  date,
  guests      int check (guests is null or guests between 1 and 100000),
  message     text check (message is null or char_length(message) <= 2000),
  status      text default 'nueva' check (status in ('nueva','respondida','cerrada')),
  created_at  timestamptz default now()
);

-- ---------- 7. Métricas ----------
create table if not exists public.analytics (
  id          bigserial primary key,
  type        text not null check (char_length(type) <= 40),
  label       text check (label is null or char_length(label) <= 200),
  source      text check (source is null or char_length(source) <= 60),
  device      text check (device is null or char_length(device) <= 20),
  session_id  text check (session_id is null or char_length(session_id) <= 64),
  created_at  timestamptz default now()
);
create index if not exists analytics_created_idx on public.analytics (created_at desc);

-- =====================================================================
-- Seguridad (RLS): el público solo lee lo público y solo puede
-- CREAR solicitudes y métricas. Todo lo demás, solo administradores.
-- =====================================================================
alter table public.admins    enable row level security;
alter table public.settings  enable row level security;
alter table public.flyers    enable row level security;
alter table public.fechas    enable row level security;
alter table public.tiktoks   enable row level security;
alter table public.bookings  enable row level security;
alter table public.analytics enable row level security;

do $$
declare t text;
begin
  -- borrar políticas anteriores para poder correr el archivo de nuevo
  for t in select unnest(array['admins','settings','flyers','fechas','tiktoks','bookings','analytics']) loop
    execute format('drop policy if exists "public read" on public.%I', t);
    execute format('drop policy if exists "admin all" on public.%I', t);
    execute format('drop policy if exists "public insert" on public.%I', t);
  end loop;
end $$;

-- Lectura pública del contenido de la página
create policy "public read" on public.settings for select using (true);
create policy "public read" on public.flyers   for select using (true);
create policy "public read" on public.fechas   for select using (true);
create policy "public read" on public.tiktoks  for select using (true);

-- Administradores: todo
create policy "admin all" on public.admins    for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.settings  for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.flyers    for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.fechas    for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.tiktoks   for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.bookings  for all using (public.is_admin()) with check (public.is_admin());
create policy "admin all" on public.analytics for all using (public.is_admin()) with check (public.is_admin());

-- Visitantes: solo pueden enviar solicitudes y registrar métricas
create policy "public insert" on public.bookings  for insert with check (status = 'nueva');
create policy "public insert" on public.analytics for insert with check (true);

-- =====================================================================
-- Almacenamiento de imágenes (portada y flyers)
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "media public read"  on storage.objects;
drop policy if exists "media admin write"  on storage.objects;
drop policy if exists "media admin update" on storage.objects;
drop policy if exists "media admin delete" on storage.objects;

create policy "media public read"  on storage.objects for select using (bucket_id = 'media');
create policy "media admin write"  on storage.objects for insert with check (bucket_id = 'media' and public.is_admin());
create policy "media admin update" on storage.objects for update using (bucket_id = 'media' and public.is_admin());
create policy "media admin delete" on storage.objects for delete using (bucket_id = 'media' and public.is_admin());
