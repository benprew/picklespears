#!/usr/bin/env ruby

require 'pp'

require_relative '../picklespears'

missing_teams = Set.new

Dir.glob('*.txt').each do |filename|
  f = File.new(filename)
  f.each do |line|
    line.chop!
    (league, division, home, away, game_date, game_description) = line.split "|"

    division = Division.first(:name => division, :league => league)
    [ home, away ].each do |team|
      teams = Team.all(:name => team)
      if teams.length == 0
        missing_teams << "#{team} #{division.name}"
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
        Game.first_or_create(
          :date => game_date,
          :description => game_description,
          :team_id => t.id
        ).save
      end
      missing_teams << "#{team} #{division.name}" unless found_team
    end
  end
end

puts "Couldn't find teams for:"
pp missing_teams
