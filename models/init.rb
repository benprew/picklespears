# encoding: utf-8
require 'dm-core'
require 'dm-migrations'
require 'yaml'

def make_connect_string(db_info)
  # for Heroku
  return ENV['DATABASE_URL'] if ENV['DATABASE_URL']

  if db_info['adapter'] == 'sqlite3'
    return sprintf "%s:%s", db_info['adapter'], db_info['database']
  else
    return sprintf "%s://%s:%s@localhost/%s", db_info['adapter'], db_info['username'], db_info['password'], db_info['database']
  end
end

DataMapper.setup(:default, make_connect_string(settings.db))

require_relative 'division'
require_relative 'game'
require_relative 'player'
require_relative 'players_game'
require_relative 'players_team'
require_relative 'team'

DataMapper.finalize
