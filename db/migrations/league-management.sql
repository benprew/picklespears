CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    name CHARACTER VARYING(128) NOT NULL
);


CREATE TABLE league_managers (
    player_id integer NOT NULL
      REFERENCES players DEFERRABLE,
    league_id integer NOT NULL
      REFERENCES leagues DEFERRABLE,
    PRIMARY KEY (player_id, league_id)
);

ALTER TABLE divisions ADD COLUMN league_id INTEGER REFERENCES leagues;

INSERT INTO leagues (name) SELECT 'Portland Indoor ' || league FROM divisions GROUP BY league;

UPDATE divisions SET league_id = l.id FROM leagues l WHERE 'Portland Indoor ' || divisions.league = l.name;

ALTER TABLE divisions ALTER COLUMN league_id SET NOT NULL;

ALTER TABLE divisions DROP COLUMN league;
