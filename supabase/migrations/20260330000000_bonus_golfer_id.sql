-- Add golfer_id to bonuses table and remove participant_id dependency
DROP TABLE IF EXISTS pga_test_bonuses CASCADE;

CREATE TABLE pga_test_bonuses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  golfer_id uuid references pga_test_golfers(id) on delete cascade not null,
  participant_id uuid references pga_test_participants(id) on delete cascade not null,
  bonus_type text not null check (bonus_type in ('par3_win', 'hio')),
  shots int not null default 1,
  created_at timestamptz default now()
);

ALTER TABLE pga_test_bonuses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON pga_test_bonuses FOR SELECT USING (true);
CREATE POLICY "Auth insert" ON pga_test_bonuses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Auth update" ON pga_test_bonuses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Auth delete" ON pga_test_bonuses FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_pga_bonuses_golfer ON pga_test_bonuses(golfer_id);
CREATE INDEX idx_pga_bonuses_participant ON pga_test_bonuses(participant_id);

-- Also create push subscriptions table if not exists
CREATE TABLE IF NOT EXISTS pga_test_push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_id UUID REFERENCES pga_test_participants(id) ON DELETE CASCADE NOT NULL,
  endpoint TEXT NOT NULL UNIQUE,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  favorites JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE pga_test_push_subscriptions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public all push" ON pga_test_push_subscriptions;
CREATE POLICY "Public all push" ON pga_test_push_subscriptions FOR ALL USING (true) WITH CHECK (true);
