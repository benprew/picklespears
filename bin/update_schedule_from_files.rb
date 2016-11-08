#!/usr/bin/env ruby

require 'pp'
require 'bundler'

Bundler.setup
require 'excon'

require_relative '../picklespears'

def deal_with_missing_team(name, division)
  fail "ERR: no team for #{name} #{division.name}" unless @force_team_create

  warn "Creating Team: #{name}"
  Team.create(name: name, division_id: division.id)
end

def find_team(division, team_name)
  teams = Team.where(name: team_name).all.reject do |t|
    t.division.league != division.league
  end

  fail "ERR: too many teams name: #{team_name} teams: #{teams.map(&:name)}" if
    teams.length > 1


  if teams.length == 0
    deal_with_missing_team(
      team_name,
      division)
  else
    team = teams.first
    if team.division != division
      warn "MOV: team: #{team.name} from: #{team.division.name} to: #{division.name}"
      team.division = division
      team.save
    end
    teams.first
  end
end

def add_game_for_team(game_date, game_description, division, home:, away:)
  if ENV['APP_URL']
    resp = Excon.post("#{ENV['APP_URL']}/game",
                      body: URI.encode_www_form(
                        date: game_date,
                        description: game_description,
                        home_team: home.name,
                        away_team: away.name,
                        division: division.name),
                      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
                     )
    fail(resp) unless resp.status == 200
  else
    game = Game.find_or_create(
      date: game_date,
      description: game_description)

    game.home_team = home
    game.away_team = away
    game.save
  end
end

@force_team_create = true

ARGV.each do |filename|
  puts filename
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (league_name, division, home, away, date, description) = line.split '|'

    league = League.first(name: league_name)
    division = Division.first(name: division, league: league)
    add_game_for_team(
      date,
      description,
      division,
      home: find_team(division, home),
      away: find_team(division, away)
    )
  end
end
