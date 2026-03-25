-- =============================================================================
-- PGA Pool Test - Database Schema
-- Run this in the Supabase SQL Editor (same project as masters-pool)
-- Supabase Project: wmqmufxyovfhxorzvrzn
-- =============================================================================

-- SAFE: Drop old test tables if they exist (does NOT touch masters_* tables)
drop table if exists pga_test_bonuses cascade;
drop table if exists pga_test_scores cascade;
drop table if exists pga_test_golfers cascade;
drop table if exists pga_test_participants cascade;
drop table if exists pga_test_field cascade;

-- 1. Participants
create table pga_test_participants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  draft_position int,
  eliminated boolean default false,
  created_at timestamptz default now()
);

-- 2. Golfers (drafted players)
create table pga_test_golfers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  participant_id uuid references pga_test_participants(id) on delete cascade not null,
  draft_round int not null,
  draft_pick int not null,
  made_cut boolean default true,
  created_at timestamptz default now()
);

-- 3. Scores per golfer per round
create table pga_test_scores (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  golfer_id uuid references pga_test_golfers(id) on delete cascade not null,
  round int not null check (round between 1 and 4),
  score int not null,
  created_at timestamptz default now(),
  unique(golfer_id, round)
);

-- 4. Bonuses (Par 3 Contest)
create table pga_test_bonuses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  participant_id uuid references pga_test_participants(id) on delete cascade not null,
  bonus_type text not null check (bonus_type in ('par3_win', 'hio')),
  shots int not null default 1,
  created_at timestamptz default now()
);

-- 5. Tournament Field (Houston Open 2026)
create table pga_test_field (
  id serial primary key,
  name text not null,
  country text not null
);

-- =============================================================================
-- Row Level Security
-- =============================================================================

alter table pga_test_participants enable row level security;
alter table pga_test_golfers enable row level security;
alter table pga_test_scores enable row level security;
alter table pga_test_bonuses enable row level security;
alter table pga_test_field enable row level security;

-- Public read for all tables
create policy "Public read" on pga_test_participants for select using (true);
create policy "Public read" on pga_test_golfers for select using (true);
create policy "Public read" on pga_test_scores for select using (true);
create policy "Public read" on pga_test_bonuses for select using (true);
create policy "Public read" on pga_test_field for select using (true);

-- Authenticated write
create policy "Auth insert" on pga_test_participants for insert with check (auth.uid() = user_id);
create policy "Auth update" on pga_test_participants for update using (auth.uid() = user_id);
create policy "Auth delete" on pga_test_participants for delete using (auth.uid() = user_id);

create policy "Auth insert" on pga_test_golfers for insert with check (auth.uid() = user_id);
create policy "Auth update" on pga_test_golfers for update using (auth.uid() = user_id);
create policy "Auth delete" on pga_test_golfers for delete using (auth.uid() = user_id);

create policy "Auth insert" on pga_test_scores for insert with check (auth.uid() = user_id);
create policy "Auth update" on pga_test_scores for update using (auth.uid() = user_id);
create policy "Auth delete" on pga_test_scores for delete using (auth.uid() = user_id);

create policy "Auth insert" on pga_test_bonuses for insert with check (auth.uid() = user_id);
create policy "Auth update" on pga_test_bonuses for update using (auth.uid() = user_id);
create policy "Auth delete" on pga_test_bonuses for delete using (auth.uid() = user_id);

-- =============================================================================
-- Indexes
-- =============================================================================

create index idx_pga_participants_user on pga_test_participants(user_id);
create index idx_pga_golfers_participant on pga_test_golfers(participant_id);
create index idx_pga_golfers_user on pga_test_golfers(user_id);
create index idx_pga_scores_golfer on pga_test_scores(golfer_id);
create index idx_pga_scores_round on pga_test_scores(round);
create index idx_pga_bonuses_participant on pga_test_bonuses(participant_id);

-- =============================================================================
-- Houston Open 2026 Field (135 players from ESPN)
-- =============================================================================

insert into pga_test_field (name, country) values
('Bronson Burgoon', 'United States'),
('Andrew Putnam', 'United States'),
('Erik van Rooyen', 'South Africa'),
('Vince Whaley', 'United States'),
('Danny Walker', 'United States'),
('Marco Penge', 'England'),
('Keith Mitchell', 'United States'),
('Chad Ramey', 'United States'),
('Matthieu Pavon', 'France'),
('Max Greyserman', 'United States'),
('Nicolai Højgaard', 'Denmark'),
('Nick Dunlap', 'United States'),
('Rickie Fowler', 'United States'),
('Danny Willett', 'England'),
('Shane Lowry', 'Ireland'),
('Wyndham Clark', 'United States'),
('Doug Ghim', 'United States'),
('Sam Stevens', 'United States'),
('Jason Day', 'Australia'),
('Chris Kirk', 'United States'),
('Brian Campbell', 'United States'),
('Sam Burns', 'United States'),
('Chris Gotterup', 'United States'),
('William Mouw', 'United States'),
('Jhonattan Vegas', 'Venezuela'),
('Stephan Jaeger', 'Germany'),
('Garrick Higgo', 'South Africa'),
('Ben Griffin', 'United States'),
('Nico Echavarria', 'Colombia'),
('Harry Hall', 'England'),
('Kurt Kitayama', 'United States'),
('Sahith Theegala', 'United States'),
('Kevin Yu', 'Chinese Taipei'),
('Ryan Gerard', 'United States'),
('Aldrich Potgieter', 'South Africa'),
('Sudarshan Yellamaraju', 'Canada'),
('Ryan Fox', 'New Zealand'),
('Tom Hoge', 'United States'),
('Aaron Wise', 'United States'),
('Tom Kim', 'South Korea'),
('Mac Meissner', 'United States'),
('Michael Brennan', 'United States'),
('David Lipsky', 'United States'),
('Rasmus Højgaard', 'Denmark'),
('Hank Lebioda', 'United States'),
('Kristoffer Reitan', 'Norway'),
('Takumi Kanaya', 'Japan'),
('Dylan Wu', 'United States'),
('Beau Hossler', 'United States'),
('Jimmy Stanger', 'United States'),
('Patrick Fishburn', 'United States'),
('Lee Hodges', 'United States'),
('Jeffrey Kang', 'United States'),
('Johnny Keefer', 'United States'),
('Dan Brown', 'England'),
('Adrien Saddier', 'France'),
('Jordan Smith', 'England'),
('Alejandro Tosti', 'Argentina'),
('Pontus Nyholm', 'Sweden'),
('Isaiah Salinda', 'United States'),
('Paul Waring', 'England'),
('Casey Russell', 'United States'),
('Jesper Svensson', 'Sweden'),
('Rasmus Neergaard-Petersen', 'Denmark'),
('Jackson Suber', 'United States'),
('Davis Chatfield', 'United States'),
('Brice Garnett', 'United States'),
('Sam Ryder', 'United States'),
('K.H. Lee', 'South Korea'),
('Mark Hubbard', 'United States'),
('Denny McCarthy', 'United States'),
('Rico Hoey', 'Philippines'),
('Thorbjørn Olesen', 'Denmark'),
('Peter Malnati', 'United States'),
('Adam Svensson', 'Canada'),
('Will Zalatoris', 'United States'),
('Eric Cole', 'United States'),
('Kevin Roy', 'United States'),
('Adam Scott', 'Australia'),
('Tony Finau', 'United States'),
('Emiliano Grillo', 'Argentina'),
('Séamus Power', 'Ireland'),
('Trey Mullinax', 'United States'),
('Min Woo Lee', 'Australia'),
('Matt Kuchar', 'United States'),
('Brooks Koepka', 'United States'),
('Taylor Pendrith', 'Canada'),
('Jake Knapp', 'United States'),
('Michael Thorbjornsen', 'United States'),
('Joe Highsmith', 'United States'),
('Adam Schenk', 'United States'),
('J.T. Poston', 'United States'),
('Aaron Rai', 'England'),
('Sungjae Im', 'South Korea'),
('Ricky Castillo', 'United States'),
('Pierceson Coody', 'United States'),
('Lucas Glover', 'United States'),
('Billy Horschel', 'United States'),
('Harris English', 'United States'),
('Patrick Rodgers', 'United States'),
('Davis Riley', 'United States'),
('Steven Fisk', 'United States'),
('Gary Woodland', 'United States'),
('Patton Kizzire', 'United States'),
('Alex Smalley', 'United States'),
('Davis Thompson', 'United States'),
('S.H. Kim', 'South Korea'),
('Karl Vilips', 'Australia'),
('Charley Hoffman', 'United States'),
('Mackenzie Hughes', 'Canada'),
('Christiaan Bezuidenhout', 'South Africa'),
('Matt Wallace', 'England'),
('Max McGreevy', 'United States'),
('Chandler Phillips', 'United States'),
('Rafael Campos', 'Puerto Rico'),
('Kris Ventura', 'Norway'),
('Austin Eckroat', 'United States'),
('Matti Schmid', 'Germany'),
('A.J. Ewart', 'Canada'),
('Luke Clanton', 'United States'),
('John Parry', 'England'),
('Marcelo Rozo', 'Colombia'),
('Zecheng Dou', 'China'),
('Cole Hammer', 'United States'),
('Kensei Hirata', 'Japan'),
('Adrien Dumont de Chassart', 'Belgium'),
('Haotong Li', 'China'),
('Zach Bauchou', 'United States'),
('Christo Lamprecht', 'South Africa'),
('John VanDerLaan', 'United States'),
('David Ford', 'United States'),
('Mason Howell', 'United States'),
('Chandler Blanchet', 'United States'),
('Gordon Sargent', 'United States'),
('Neal Shipley', 'United States');
