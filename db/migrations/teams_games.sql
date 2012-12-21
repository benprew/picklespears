-- after table teams_games is created

insert into teams_games select * from (
        select max(id) as game_id, max(team_id) as team_id from games group by description
        union all
        select max(id) as game_id, min(team_id) as team_id from games group by description ) x
        group by game_id, team_id
;

update teams_games set is_home_team = true FROM
(select t.id as home_team, g.id as game_id from games g
        inner join teams_games tg on (g.id = tg.game_id)
        inner join teams t on (tg.team_id = t.id)
  where description ilike t.name || ' VS%') x
WHERE x.home_team = teams_games.team_id and x.game_id = teams_games.game_id
;

alter table games drop column team_id;

delete from players_games where game_id not in (select game_id from teams_games);
delete from games where id not in (select game_id from teams_games);
