# encoding: utf-8
require 'sequel'
require 'yaml'
require 'logger'

def make_connect_string(db_info)
  if db_info[:adapter] == 'sqlite3'
    return sprintf "%s:%s", db_info[:adapter], db_info[:database]
  else
    return sprintf "%s://%s:%s@localhost/%s", db_info[:adapter], db_info[:username], db_info[:password], db_info[:database]
  end
end

unless settings.respond_to?(:db)
  # running on Heroku
  DB = Sequel.connect(ENV['DATABASE_URL'])
else
  DB = Sequel.connect(
    make_connect_string(settings.db),
    :logger => Logger.new(settings.db[:logfile]))
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
