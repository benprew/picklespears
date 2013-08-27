ALTER TABLE games DROP COLUMN reminder_sent;

ALTER TABLE players_games ADD COLUMN reminder_sent BOOLEAN DEFAULT false NOT NULL;

ALTER TABLE players_games ALTER COLUMN status DROP NOT NULL;
