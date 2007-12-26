#!/usr/local/ruby/bin/ruby

require 'team'
require 'set'
require 'open-uri'
require 'division'

class BuildDb

  attr_reader :teams, :divisions
  
  def initialize(url='http://pdxindoorsoccer.com/Schedules/secondfall/')
    @@season_url = url
    _set_divisions
    @teams = _set_teams
  end

  def _set_divisions
    divisions = Hash.new
    open(@@season_url) do |f|
      f.each do |line|
        m = /href="((m|w|c\d)[^"]+)/.match(line)
        if m
          div = Division.new
          div.file = m[1]
          div.name = m[1].split(/\./)[0]
          div.group = m[1][0,1] == "m" ? 'Men' : m[1][0,1] == 'w' ? 'Women' : 'Coed'
          divisions[div] = true
        end
      end
    end
    @divisions = divisions
  end

  def _set_teams
    teams = Set.new

    @divisions.each do |div, value|
      teams = teams | _teams_for_division(div)
    end
    teams
  end

  def _teams_for_division(division)
    teams = Set.new
    open(@@season_url + "/" + division.file) do |f|
      f.each do |line|
        m = /\s+VS\s+(.*)/i.match(line)
        if m
          t = Team.new
          t.division = division.name
          t.name = m[1]
          teams.add(t)
        end
      end
    end
    teams
  end

  def run()
    p Team.teams.length if Team.teams
    Team.teams= @teams
    p @teams.length
    p Team.teams.length
    Team.save()
  end
end

db_builder = BuildDb.new();
db_builder.run()




