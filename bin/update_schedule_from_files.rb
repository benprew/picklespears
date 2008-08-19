#!/usr/bin/env ruby

require 'team'
require 'game'
require 'pickle-spears'

Dir.glob('*.txt').each do |filename|
  f = File.new(filename)
  f.each do |line|
    ( team, game_date, game_description ) = line.split "\t"
    t = Team.first(:name => team)
    if !t
      warn "no team found for #{team} : #{filename}"
      next
    end
    next if Game.first(:description => game_description, :team_id => t.id )
    warn "building games for #{team}"
    g = Game.new(:date => game_date, :description => game_description, :team => t)
    g.save
  end
end
