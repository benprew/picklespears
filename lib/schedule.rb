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
    divisions = Set.new
    open(@@season_url) do |f|
      f.each do |line|
        m = /href="((m|w|c\d)[^"]+)/.match(line)
        if m
          div = Division.new
          div.file = m[1]
          div.name = m[1].split(/\./)[0]
          div.group = m[1][0,1] == "m" ? 'Men' : m[1][0,1] == 'w' ? 'Women' : 'Coed'
          divisions.add(div)
        end
      end
    end
    @divisions = divisions
  end

  def _set_teams
    @teams = Set.new

    @divisions.each do |div|
      _add_teams_for_division(div)
    end

    p @teams
  end

  def divisions_and_teams_for_group(group)
    division = Hash.new
    
    @divisions.select { |div| div.group == group }.each do |div|
      division[div.name] = @teams.select { |t| t.division == div.name }
    end

    division
  end

  def _add_teams_for_division(division)
    open(@@season_url + "/" + division.file) do |f|
      f.each do |line|
        m = /\s+VS\s+(.*)/i.match(line)
        if m
          t = Team.new
          t.division = division.name
          t.name = m[1]
          @teams.add(t)
        end
      end
    end
  end

  def schedule_for_team(team)
    upcoming_games = _upcoming_games_for_team(team)

    @cgi.out{
      @cgi.html{
        @cgi.head{ @cgi.title{ team + " Schedule" } } +
        @cgi.body { 
          @cgi.h2 { "Next game: " + upcoming_games.shift } +
          upcoming_games.join("<br />\n")
        }
      }
    }
  end



  def all_games_for(team)
    games = []
    open(@@season_url + "/" + division) do |f|
      f.each do |line|
        games.push( [ _parse_date_from_schedule_line(line), line ] ) if (line =~ /#{team}/)
      end
    end
    games
  end

  def _division_for_team(team)
    
  end

  def _divisions()
    divisions = Hash.new

    _schedule_files.each do |division_file|
      teams = Set.new
      open(@@season_url + "/" + division_file) do |f|
        f.each do |line|
          m = /\s+VS\s+(.*)/i.match(line)
          teams.add(m[1]) if m
        end
      end
      divisions[division_file] = teams
    end
    divisions
  end

  def _upcoming_games_for_team(team, division)
    today = Time.parse(Time.now().strftime("%m/%d/%Y"))
    _all_games_for_team(team, division).select do |elem|
      @log.warn(elem)
      @log.warn(today)
      @log.warn(elem[0] && elem[0] >= today)
      elem[0] && elem[0] >= today
    end.map { |i| i[1] }
  end


  def _parse_date_from_schedule_line(line)
    m = /\w+\s+(\w+)\s+(\d+)/.match(line)
    if m[1] && m[2]
      return Time.parse(m[1] + " " + m[2])
    else
      @log.warn("Unable to find time for line: " + line)
      return ""
    end
  end

#   def choose_team()
#     @cgi.out{
#       @cgi.html{
#         @cgi.head { @cgi.title("Choose a team") } +
#         @cgi.body { _divisions_str() }
#       }
#     }
#   end

#   def _divisions_str()
#     divisions = _divisions()
#     men = divisions.keys.grep(/^m/).sort
#     women = divisions.keys.grep(/^w/).sort
#     coed = divisions.keys.grep(/^c/).sort
#     # coed is usually the largest
#     all = coed.zip(women, men)

#     @cgi.table {
#       @cgi.tr { ["Coed", "Women", "Men"].map { |i| @cgi.th { @cgi.h1{ i } } }.join("\n") +
#         all.map { |division_slice|
#           @cgi.tr {
#             division_slice.map { |division_filename|
#               if division_filename
#                 @cgi.td {
#                   @cgi.h2 { division_filename } + 
#                   @cgi.form("get") {
#                     @cgi.hidden("division", division_filename) +
#                     @cgi.popup_menu("team", *(divisions[division_filename].sort)) +
#                     @cgi.submit()
#                   }
#                 }
#               else
#                 @cgi.td { "&nbsp;" }
#               end
#             }.join("\n")
#           }
#         }.join("\n")
#       }
#     }
#   end

  def _table_header(list)
    return list.map { |i| @cgi.th { i } }.join("\n")
  end


end

