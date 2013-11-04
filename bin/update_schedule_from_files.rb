#!/usr/bin/env ruby

require 'pp'

require_relative '../picklespears'

def deal_with_missing_team(name, division, game_date, game_description, is_home_team=false)
  if @force_team_create == true
    warn "Creating Team: #{name}"
    Team.create(name: name, division_id: division.id)
  else
    missing_teams << "#{name} #{division.name}"
    []
  end
end

def add_game_for_team(division, team_name, is_home_team = false, game_date, game_description)
  teams = Team.where(name: team_name).all.reject do |t|
    t.division.league != division.league
  end

  if teams.length == 0
    teams << deal_with_missing_team(
      team_name,
      division,
      game_date,
      game_description,
      is_home_team)
  end

  teams.each do |team|
    if team.division != division
      warn "TEAM: #{team.name} - Division: #{team.division.name} to #{division.name}"
      team.division = division
      team.save
    end
    game = Game.find_or_create(
      date: game_date,
      description: game_description)

    is_home_team ? game.home_team = team : game.away_team = team
  end
end

missing_teams = Set.new
@force_team_create = true

ARGV.each do |filename|
  puts filename
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (league_name, division, home, away, date, description) = line.split '|'

    league = League.first(name: league_name)
    division = Division.first(name: division, league: league)
    add_game_for_team(division, home, true, date, description)
    add_game_for_team(division, away, false, date, description)
  end
end

if missing_teams.length > 0
  puts "Couldn't find teams for:"
  pp missing_teams
end
