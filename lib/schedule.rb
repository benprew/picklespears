require 'open-uri'
require 'cgi'
require 'logger'
require 'set'
require 'lib/team'
require 'lib/division'

class Schedule

  attr_reader :teams, :divisions

  def initialize(url='http://pdxindoorsoccer.com/Schedules/secondfall/')
    @@season_url = url
    @cgi = CGI.new("html4")
    @log = Logger.new("/var/log/schedule")
    _set_divisions
    _set_teams
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
    @teams = Hash.new

    @divisions.each do |div, value|
      _add_teams_for_division(div)
    end
  end

  def _add_teams_for_division(division)
    open(@@season_url + "/" + division.file) do |f|
      f.each do |line|
        m = /\s+VS\s+(.*)/i.match(line)
        if m
          t = Team.new
          t.division = division.name
          t.name = m[1]
          @teams[t.name] = t
        end
      end
    end
  end

  # new
  def divisions_and_teams_for_group(group)
    division = Hash.new
    
    @divisions.select { |div, val| div.group == group }.each do |div, val|
      division[div.name] = @teams.select { |name, t| t.division == div.name }
    end

    division
  end

  def schedule_for_team(team)
    upcoming_games = _upcoming_games_for_team(team)

    @cgi.out{
      @cgi.html{
        @cgi.head{ @cgi.title{ team + " Schedule" } } +
        @cgi.body { 
          @cgi.h1 { team } +
          @cgi.b { upcoming_games.shift } + "<br />" +
          upcoming_games.join("<br />\n")
        }
      }
    }
  end

  def _upcoming_games_for_team(team)
    today = Time.parse(Time.now().strftime("%m/%d/%Y"))
    games = _all_games_for_team(team)

    while ( games && games[0][0] < today )
      games.shift;
    end

    games.map { |x| x[1] }
  end

  def _all_games_for_team(team)
    raise "no team named " + team unless @teams[team]
    games = []
    open(@@season_url + "/" + @teams[team].division) do |f|
      f.grep(/#{team}/).each do |line|
        date = _parse_date_from_schedule_line(line)
        next unless date
        # add a year
        date = date + (60 * 60 * 24 * 365) if games.length > 1 && date < games[-1][0]
        games.push( [ date, line ] ) if (line =~ /#{team}/)
      end
    end
    games
  end

  def _parse_date_from_schedule_line(line)
    m = /\w{3}\s+(\w{3})\s+(\d{1,2})\s+/.match(line)
    if m && m[1] && m[2]
      return Time.parse(m[1] + " " + m[2])
    else
      @log.warn("Unable to find time for line: " + line)
      return false
    end
  end
end

