# encoding: utf-8
require 'sequel'
require 'yaml'
require 'logger'
require 'pg'

times = 0
begin
  DB = Sequel.connect(ENV['DATABASE_URL'])
rescue Sequel::DatabaseConnectionError, PG::ConnectionBad
  if times < 3
    puts "failed to connect to database, retrying..."
    times += 1
    sleep(1*times)
    retry
  else
    raise
  end
end

require_relative 'division'
require_relative 'league'
require_relative 'game'
require_relative 'player'
require_relative 'players_game'
require_relative 'players_team'
require_relative 'team'
require_relative 'teams_game'
require_relative 'season'
require_relative 'season_exception'
require_relative 'season_day_to_avoid'
require_relative 'season_preferred_day'
