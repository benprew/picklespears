-- create seasons table
CREATE TABLE seasons_teams(
    season_id INTEGER NOT NULL
      REFERENCES seasons DEFERRABLE,
    team_id integer NOT NULL
      REFERENCES teams (id) DEFERRABLE,
    PRIMARY KEY (season_id, team_id)
);

-- create season_exceptions table
CREATE TABLE season_exceptions(
    id SERIAL PRIMARY KEY,
    description CHARACTER VARYING(256),
    date DATE NOT NULL,
    season_id INTEGER NOT NULL
      REFERENCES seasons DEFERRABLE
);

CREATE TABLE seasons_teams(
    season_id INTEGER NOT NULL
      REFERENCES seasons DEFERRABLE,
    team_id integer NOT NULL
      REFERENCES teams (id) DEFERRABLE,
    PRIMARY KEY (season_id, team_id)
);

CREATE TABLE season_preferred_days(
    season_id INTEGER NOT NULL
      REFERENCES seasons DEFERRABLE,
    team_id integer NOT NULL
      REFERENCES teams (id) DEFERRABLE,
    preferred_day_of_week varchar(8) NOT NULL,
    PRIMARY KEY (season_id, team_id, preferred_day_of_week)
);

CREATE TABLE season_days_to_avoid(
    season_id INTEGER NOT NULL
      REFERENCES seasons DEFERRABLE,
    team_id integer NOT NULL
      REFERENCES teams (id) DEFERRABLE,
    day_to_avoid date NOT NULL,
    PRIMARY KEY (season_id, team_id, day_to_avoid)
);

ALTER TABLE teams ADD COLUMN manager_name character varying(128);
ALTER TABLE teams ADD COLUMN manager_email character varying(256);
ALTER TABLE teams ADD COLUMN manager_phone_no character varying(16);

ALTER TABLE games ADD COLUMN season_id INTEGER REFERENCES seasons;

-- many games are part of the same season
-- a game can only have one season
-- leagues can have many seasons (through games)
