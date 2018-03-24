#!/usr/bin/env ruby

require 'bundler'
Bundler.setup

require 'excon'

def add_game_for_team(game_date, game_description, division, home:, away:)
  raise 'APP_URL must be in environment'  unless ENV['APP_URL']
  resp = Excon.post("#{ENV['APP_URL']}/game",
                    body: URI.encode_www_form(
                      date: game_date,
                      description: game_description,
                      home_team: home,
                      away_team: away,
                      division: division),
                    headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
                   )
  warn resp.body unless resp.status == 200
end

ARGV.each do |filename|
  puts filename
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (_league_name, division, home, away, date, description) = line.split '|'

    warn "adding #{division} #{description}"

    add_game_for_team(
      date,
      description,
      division,
      home: home,
      away: away
    )
  end
end
