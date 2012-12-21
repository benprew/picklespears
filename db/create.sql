DROP TABLE IF EXISTS teams_games;
DROP TABLE IF EXISTS league_managers;
DROP TABLE IF EXISTS players_games;
DROP TABLE IF EXISTS players_teams;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS divisions;
DROP TABLE IF EXISTS leagues;

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL
);

CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL,
    league_id integer NOT NULL
      REFERENCES leagues DEFERRABLE
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name character varying(128) NOT NULL,
    division_id integer NOT NULL
      REFERENCES divisions DEFERRABLE
);

CREATE TABLE games (
    id SERIAL PRIMARY KEY,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    description CHARACTER VARYING(256) NOT NULL,
    reminder_sent BOOLEAN DEFAULT false NOT NULL
);

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL,
    email_address CHARACTER VARYING(256) NOT NULL,
    password_hash CHARACTER VARYING(64),
    phone_number CHARACTER VARYING(16),
    birthdate CHARACTER VARYING(32),
    zipcode CHARACTER VARYING(16),
    gender CHARACTER VARYING(16),
    openid CHARACTER VARYING(1024),
    last_login DATE,
    google_calendar_id CHARACTER VARYING(64),
    password_reset_hash CHARACTER VARYING(64),
    password_reset_expires_on DATE
);

CREATE TABLE players_games (
    game_id integer NOT NULL
      REFERENCES games DEFERRABLE,
    player_id integer NOT NULL
      REFERENCES players DEFERRABLE,
    status character varying(16) NOT NULL,
    PRIMARY KEY (game_id, player_id)
);

CREATE TABLE players_teams (
    player_id integer NOT NULL
      REFERENCES players DEFERRABLE,
    team_id integer NOT NULL
      REFERENCES teams (id) DEFERRABLE,
    is_sub boolean DEFAULT false NOT NULL,
    is_manager boolean DEFAULT false NOT NULL,
    PRIMARY KEY (player_id, team_id)
);

CREATE TABLE league_managers (
    player_id integer NOT NULL
      REFERENCES players DEFERRABLE,
    league_id integer NOT NULL
      REFERENCES leagues DEFERRABLE,
    PRIMARY KEY (player_id, league_id)
);

CREATE TABLE teams_games (
  game_id INTEGER NOT NULL
    REFERENCES games DEFERRABLE,
  team_id INTEGER NOT NULL
    REFERENCES teams DEFERRABLE,
  is_home_team BOOLEAN DEFAULT false NOT NULL,
  has_coed_bonus_point BOOLEAN DEFAULT false NOT NULL,
  goals_scored INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (game_id, team_id)
);

