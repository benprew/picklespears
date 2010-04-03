#!/usr/local/ruby/bin/ruby

require 'open-uri'
require 'set'

class BuildDb

  attr_reader :teams, :divisions, :games
  
  def initialize(url='http://pdxindoorsoccer.com/Schedules/spring/')
    @@season_url = url
    @games = []
  end

  def build_divisions
    warn "building divisions"
    div_files = []
    open(@@season_url) do |f|
      f.each do |line|
        m = /href="((m|w|c\d)[^"]+)/.match(line)
        if m
          div_files.push(m[1])
        end
      end
    end
    warn "div length #{div_files.length}"
    return div_files
  end

  def build_teams(div_files)
    div_files.each do |file|
      warn "working on #{file}"
      teams = _teams_for_division_file file

      # write out to filename locally
      f = File.new(file, 'w')
      teams.each do |name|
        games = _all_games_for_team(file, name)
        games.each { |g| f.write( [ name, g.flatten ].join("\t")) }
      end
      f.close
    end
  end

  def _teams_for_division_file(file)
    names = Set.new
    open(@@season_url + "/" + file) do |f|
      f.each do |line|
        m = /\s+VS\s+(.*)/i.match(line)
        if m
          foo = m[1].gsub(/\s+$/, '')
          foo = foo.gsub(/\s+/, ' ')
          names.add foo
        end
      end
    end
    names
  end

  def _all_games_for_team(file, team_name)
    games = []
    open(@@season_url + "/" + file) do |f|
      f.grep(Regexp.new(Regexp.quote(team_name))).each do |line|
        date = _parse_date_from_schedule_line(line)
        next unless date
        # add a year
        date = date + (60 * 60 * 24 * 365) if games.length > 1 && date < games[-1][0]
        games.push( [ date, line ] )
      end
    end
    games
  end

  def _parse_date_from_schedule_line(line)
    m = /\w{3}\s+(\w{3})\s+(\d{1,2})\s+(\d+|MIDNITE|NOON)(:15)\s+(AM|PM)?/.match(line)
    if m && m[1] && m[2]
      hour = m[3]
      minute = m[4]
      am_pm = m[5]
      if hour == "NOON"
        hour = 12
        am_pm = 'PM'
      end
      if hour == 'MIDNITE'
        hour = 11
        minute = ':59'
        am_pm = 'PM'
      end
      return Time.parse(m[1] + " " + m[2] + " #{hour}#{minute} #{am_pm}")
    else
      print "Unable to parse time:" + line
      return false
    end
  end

  def run()
    div_files = build_divisions()
    build_teams(div_files)
  end

end

db_builder = BuildDb.new();
db_builder.run()




