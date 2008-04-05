#!/usr/local/ruby/bin/ruby

require 'open-uri'
require 'set'
require 'db'
require 'team'
require 'division'
require 'game'

class BuildDb

  attr_reader :teams, :divisions, :games
  
  def initialize(url='http://pdxindoorsoccer.com/Schedules/spring/')
    @@season_url = url
    @games = []
  end

  def build_divisions
    warn "building divisions"
    divisions = []
    open(@@season_url) do |f|
      f.each do |line|
        m = /href="((m|w|c\d)[^"]+)/.match(line)
        if m
          league = m[1][0,1] == "m" ? 'Men' : m[1][0,1] == 'w' ? 'Women' : 'Coed'
          name = m[1].split(/\./)[0]
          div = Division.find(:first, :conditions => [ "name = ?", name ]) || Division.new
          div.name = name
          div.league = league
          div.file = m[1]
          div.save!
          divisions.push(div)
        end
      end
    end
    warn "div length " + divisions.length.to_s
    @divisions = divisions
  end

  def build_teams
    warn "building teams"
    teams = Hash.new

    @divisions.each do |div|
      teams.merge!(_teams_for_division(div))
    end

    teams.values.each { |team| team.save! }
    warn "teams length " + teams.length.to_s
    @teams = teams.values
  end

  def _teams_for_division(division)
    teams = Hash.new
    open(@@season_url + "/" + division.file) do |f|
      f.each do |line|
        m = /\s+VS\s+(.*)/i.match(line)
        if m
          name = m[1].gsub(/\s+/, " ")
          t = Team.find(:first, :conditions => [ "name = ?", name ]) || Team.new
          t.division = division
          t.name = name
          teams[t.name] = t
        end
      end
    end
    teams
  end

  def build_games
    warn "building games"
    @games = (@teams.map{ |team| _all_games_for_team(team) }).flatten()
    @games.each { |game| game.save! }
    warn "games length " + @games.length.to_s
  end

  def _all_games_for_team(team)
    games = []
    open(@@season_url + "/" + team.division.file) do |f|
      f.grep(/#{team.name}/).each do |line|
        date = _parse_date_from_schedule_line(line)
        next unless date
        # add a year
        date = date + (60 * 60 * 24 * 365) if games.length > 1 && date < games[-1].date

        g = Game.find(:first, :conditions => [ "description = ?", line ]) || Game.new
        g.team = team
        g.date = date
        g.description = line
        games.push( g )
      end
    end
    games
  end

  def _parse_date_from_schedule_line(line)
    m = /\w{3}\s+(\w{3})\s+(\d{1,2})\s+/.match(line)
    if m && m[1] && m[2]
      return Time.parse(m[1] + " " + m[2])
    else
      print "Unable to parse time:" + line
      return false
    end
  end

  def run()
    build_divisions()
    build_teams()
    build_games()
  end

end

db_builder = BuildDb.new();
db_builder.run()




