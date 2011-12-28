#!/usr/bin/env ruby

require 'pp'

require_relative '../picklespears'

missing_teams = Set.new
@@force_team_create = true

def deal_with_missing_team(name, division, game_date, game_description)
  if @@force_team_create == true
    warn "Creating Team: #{name}"
    Game.create(
      :date => game_date,
      :description => game_description,
      :team_id => Team.create(:name => name, :division_id => division.id).id
    )
  else
    missing_teams << "#{name} #{division.name}"
  end
end

Dir.glob('*.txt').each do |filename|
  puts filename
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (league, division, home, away, game_date, game_description) = line.split "|"

    division = Division.first(:name => division, :league => league)
    [ home, away ].each do |team|
      teams = Team.filter(:name => team).all
      if teams.length == 0
        deal_with_missing_team(team, division, game_date, game_description)
        next
      end
      found_team = false

      teams.each do |t|
        next unless t.division.league == division.league

        found_team = true
        if t.division.name != division.name
          warn "TEAM: #{team} - Updating division from #{t.division.name} to #{division.name}"
          t.division = division
          t.save
        end
        Game.find_or_create(
          :date => game_date,
          :description => game_description,
          :team_id => t.id
        )
      end

      deal_with_missing_team(team, division, game_date, game_description) unless found_team
    end
  end
end

if missing_teams.length > 0
  puts "Couldn't find teams for:"
  pp missing_teams
end
