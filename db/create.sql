CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL,
    league CHARACTER VARYING(128) NOT NULL
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name character varying(128) NOT NULL,
    division_id integer NOT NULL,
    FOREIGN KEY (division_id) REFERENCES divisions (id)
);

CREATE TABLE games (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL,
    description CHARACTER VARYING(256) NOT NULL,
    team_id INTEGER NOT NULL,
    reminder_sent BOOLEAN DEFAULT false NOT NULL,
    FOREIGN KEY (team_id) REFERENCES teams (id)
);

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    name character varying(128) NOT NULL,
    email_address character varying(256),
    phone_number character varying(16),
    is_sub boolean DEFAULT false NOT NULL,
    birthdate character varying(32),
    zipcode character varying(16),
    gender character varying(16),
    openid character varying(1024)
);

CREATE TABLE players_games (
    game_id integer NOT NULL,
    player_id integer NOT NULL,
    status character varying(16) NOT NULL,
    FOREIGN KEY (game_id) REFERENCES games (id),
    FOREIGN KEY (player_id) REFERENCES players (id)
);

CREATE TABLE players_teams (
    player_id integer NOT NULL,
    team_id integer NOT NULL,
    FOREIGN KEY (player_id) REFERENCES players (id),
    FOREIGN KEY (team_id) REFERENCES teams (id)
);

CREATE TABLE schema_migrations (
    version character varying(255) PRIMARY KEY NOT NULL
);

