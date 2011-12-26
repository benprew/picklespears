DROP TABLE IF EXISTS players_games;
DROP TABLE IF EXISTS players_teams;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS divisions;

CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL,
    league CHARACTER VARYING(128) NOT NULL
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
    team_id INTEGER NOT NULL
      REFERENCES teams DEFERRABLE,
    reminder_sent BOOLEAN DEFAULT false NOT NULL
);

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    name character varying(128) NOT NULL,
    email_address character varying(256) NOT NULL,
    phone_number character varying(16),
    birthdate character varying(32),
    zipcode character varying(16),
    gender character varying(16),
    openid character varying(1024)
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
    is_manager boolean DEFAULT false NOT NULL
);
