# Teamvite - Sports Team Management

http://www.teamvite.com

## DESCRIPTION:

Teamvite is a web app designed to allow a recreational sports team manager to track games and players coming to those games.  It tracks response status from players and reminds them several days before the game.  Also, it allows players to join multiple teams, and see their upcoming schedule of games, useful for players that play on multiple teams.

## REQUIREMENTS:

Built with Ruby and Sinatra, see the Gemfile for app-specific requirements.

## TESTING

Test your changes in docker

    docker-compose run web bash
    bundle exec rake test # TEST=test/test_season.rb #TESTOPTS="--name=test_season_exception_day -v"

### Common tasks
* Update PDX Indoor games
``` shell
bin/pdx-indoor-schedule.rb <season>
docker-compose run web bash
env APP_URL=http://www.teamvite.com bin/update_schedule_from_files.rb pi_games.txt
```

* Cleanup old games in db
``` sql
heroku pg:psql -a teamvite
delete from teams_games where game_id in (select id from games where date < current_date - 90);
delete from games where date < current_date - 90;
delete from players_games where game_id in (select id from games where date < current_date - 90);
delete from teams where id not in (select team_id from teams_games);
```

* Rows in tables

``` sql
select table_schema,
       table_name,
       (xpath('/row/cnt/text()', xml_count))[1]::text::int as row_count
from (
  select table_name, table_schema,
         query_to_xml(format('select count(*) as cnt from %I.%I', table_schema, table_name), false, true, '') as xml_count
  from information_schema.tables
  where table_schema = 'public' --<< change here for the schema you want
) t order by 3 desc;
```

## LICENSE:

(The MIT License)

Copyright (c) 2009 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
