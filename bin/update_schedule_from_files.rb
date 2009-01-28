#!/usr/bin/env ruby

require 'team'
require 'game'
require 'division'
require 'pickle-spears'

Dir.glob('*.txt').each do |filename|
  f = File.new(filename)
  f.each do |line|
    line.chop!
    items = line.split "\t"
    team = items.shift
    game_date = items.shift
    game_description = items.join " "
    t = Team.first(:name => team)
    if !t
      warn "no team found for #{team} : #{filename}"
      next
    end
    league = \
      filename[0,1] == 'm' ? 'Men' \
      : filename[0,1] == 'w' ? 'Women' \
      : 'Coed'
    possible_new_div = Division.first_or_create(:name => filename.match(/[^.]+/)[0], :league => league)
    if !possible_new_div || t.division.name != possible_new_div.name
      warn "TEAM: #{team} - Updating division from #{t.division.name} to #{possible_new_div.name}"
      t.division = possible_new_div
      t.save
      possible_new_div.save
    end
    next if Game.first(:description => game_description, :team_id => t.id )
    warn "building games for #{team}"
    g = Game.new(:date => game_date, :description => game_description, :team => t)
    g.save
  end
end
