#!/usr/bin/env ruby

require 'pp'

require_relative '../picklespears'

missing_teams = Set.new
@@force_team_create = true

def deal_with_missing_team(name, division, game_date, game_description, is_home_team=false)
  if @@force_team_create == true
    warn "Creating Team: #{name}"
    game = Game.create(
      :date => game_date,
      :description => game_description,
    )
    TeamsGames.find_or_create(
      game_id: game.id,
      team_id: Team.create(:name => name, :division_id => division.id),
      ) { |tg| tg.is_home_team = is_home_team}
  else
    missing_teams << "#{name} #{division.name}"
  end
end

ARGV.each do |filename|
  puts filename
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (league, division, home, away, game_date, game_description) = line.split "|"

    division = Division.first(:name => division, :league => league)
    add_game_for_team(division, home, true)
    add_game_for_team(division, away, false)
  end
end

def add_game_for_team(division, team, is_home_team=false)
  teams = Team.filter(:name => team).all
  if teams.length == 0
    deal_with_missing_team(team, division, game_date, game_description, is_home_team)
    next
  end
  found_team = false

  teams.each do |t|
    next unless t.division.league == division.league

    found_team = true
    if t.division != division
      warn "TEAM: #{team} - Updating division from #{t.division.name} to #{division.name}"
      t.division = division
      t.save
    end
    game = Game.find_or_create(
      :date => game_date,
      :description => game_description
      )
    TeamsGame.find_or_create(
      game_id: game.id,
      team_id: team.id
      ) { |tg| tg.is_home_team = is_home_team }
  end

  deal_with_missing_team(team, division, game_date, game_description, is_home_team) unless found_team
end

if missing_teams.length > 0
  puts "Couldn't find teams for:"
  pp missing_teams
end
