-- Entrena Ref Beach Soccer — esquema de base de datos
-- Se puede correr este archivo completo las veces que haga falta, no rompe nada si ya existe algo.

create table if not exists profiles (
  email text primary key,
  name text,
  last_name text,
  country text,
  created_at timestamptz default now()
);

create table if not exists app_config (
  key text primary key,
  value text
);

create table if not exists exercises (
  id text primary key,
  label text,
  url text not null,
  top text not null,
  bottom text not null,
  in_fixed_test boolean default false,
  play_count integer default 0,
  created_at timestamptz default now()
);

create table if not exists history (
  id bigint generated always as identity primary key,
  email text,
  date timestamptz default now(),
  type text,
  series integer,
  top_score integer,
  bottom_score integer,
  perceived_rating integer,
  perceived_label text,
  official_level text
);

-- Por si la tabla ya existía de antes sin esta columna
alter table history add column if not exists official_level text;

-- Habilitar Row Level Security (no da error si ya estaba activado)
alter table profiles enable row level security;
alter table app_config enable row level security;
alter table exercises enable row level security;
alter table history enable row level security;

-- Políticas: primero borro si ya existían, después las creo. Así se puede correr
-- este archivo cuantas veces sea necesario sin que tire error de "ya existe".

drop policy if exists "public read profiles" on profiles;
drop policy if exists "public write profiles" on profiles;
drop policy if exists "public update profiles" on profiles;
create policy "public read profiles" on profiles for select using (true);
create policy "public write profiles" on profiles for insert with check (true);
create policy "public update profiles" on profiles for update using (true);

drop policy if exists "public read config" on app_config;
drop policy if exists "public write config" on app_config;
drop policy if exists "public update config" on app_config;
create policy "public read config" on app_config for select using (true);
create policy "public write config" on app_config for insert with check (true);
create policy "public update config" on app_config for update using (true);

drop policy if exists "public read exercises" on exercises;
drop policy if exists "public write exercises" on exercises;
drop policy if exists "public update exercises" on exercises;
drop policy if exists "public delete exercises" on exercises;
create policy "public read exercises" on exercises for select using (true);
create policy "public write exercises" on exercises for insert with check (true);
create policy "public update exercises" on exercises for update using (true);
create policy "public delete exercises" on exercises for delete using (true);

drop policy if exists "public read history" on history;
drop policy if exists "public write history" on history;
drop policy if exists "public update history" on history;
create policy "public read history" on history for select using (true);
create policy "public write history" on history for insert with check (true);
create policy "public update history" on history for update using (true);

-- Actualización: marcar resultados de ARIET cargados a mano (hechos fuera de la app)
alter table history add column if not exists manual boolean default false;

-- Actualización: contador de reportes de "video no se reproduce"
alter table exercises add column if not exists broken_reports integer default 0;

-- Actualización: Video Tests organizados por el administrador (nombre + orden elegido a mano)
create table if not exists video_tests (
  id text primary key,
  name text not null,
  video_ids jsonb not null default '[]',
  created_at timestamptz default now()
);
alter table video_tests enable row level security;
drop policy if exists "public read video_tests" on video_tests;
drop policy if exists "public write video_tests" on video_tests;
drop policy if exists "public update video_tests" on video_tests;
drop policy if exists "public delete video_tests" on video_tests;
create policy "public read video_tests" on video_tests for select using (true);
create policy "public write video_tests" on video_tests for insert with check (true);
create policy "public update video_tests" on video_tests for update using (true);
create policy "public delete video_tests" on video_tests for delete using (true);

-- Resultados detallados de cada Video Test organizado (quién lo hizo, en cuáles acertó/erró)
create table if not exists video_test_results (
  id bigint generated always as identity primary key,
  test_id text not null,
  email text not null,
  date timestamptz default now(),
  score integer,
  max_score integer,
  detail jsonb default '[]'
);
alter table video_test_results enable row level security;
drop policy if exists "public read vt_results" on video_test_results;
drop policy if exists "public write vt_results" on video_test_results;
create policy "public read vt_results" on video_test_results for select using (true);
create policy "public write vt_results" on video_test_results for insert with check (true);

-- Actualización: "Mi gimnasio" — rutina personal por día de la semana, con evolución de kilos
create table if not exists gym_exercises (
  id text primary key,
  email text not null,
  day text not null,
  name text not null,
  equipment text,
  logs jsonb not null default '[]',
  created_at timestamptz default now()
);
alter table gym_exercises enable row level security;
drop policy if exists "public read gym_exercises" on gym_exercises;
drop policy if exists "public write gym_exercises" on gym_exercises;
drop policy if exists "public update gym_exercises" on gym_exercises;
drop policy if exists "public delete gym_exercises" on gym_exercises;
create policy "public read gym_exercises" on gym_exercises for select using (true);
create policy "public write gym_exercises" on gym_exercises for insert with check (true);
create policy "public update gym_exercises" on gym_exercises for update using (true);
create policy "public delete gym_exercises" on gym_exercises for delete using (true);

-- Actualización: título personalizado por día en Rutina gym (ej: Lunes -> "Pecho")
create table if not exists gym_day_titles (
  email text not null,
  day text not null,
  title text,
  primary key (email, day)
);
alter table gym_day_titles enable row level security;
drop policy if exists "public read gym_day_titles" on gym_day_titles;
drop policy if exists "public write gym_day_titles" on gym_day_titles;
create policy "public read gym_day_titles" on gym_day_titles for select using (true);
create policy "public write gym_day_titles" on gym_day_titles for all using (true) with check (true);

-- Actualización: repeticiones por ejercicio en Rutina gym
alter table gym_exercises add column if not exists reps text;

-- Actualización: marcar cuándo se completó la rutina de cada día (para el estado semanal)
alter table gym_day_titles add column if not exists completed_at timestamptz;

-- Actualización: marcar ejercicios hechos (se resetea al tocar "Rutina realizada") + registro de Running
alter table gym_exercises add column if not exists done boolean default false;

create table if not exists running_logs (
  id bigint generated always as identity primary key,
  email text not null,
  date timestamptz not null default now(),
  km numeric,
  minutes numeric
);
alter table running_logs enable row level security;
drop policy if exists "public read running_logs" on running_logs;
drop policy if exists "public write running_logs" on running_logs;
create policy "public read running_logs" on running_logs for select using (true);
create policy "public write running_logs" on running_logs for insert with check (true);
