#!/usr/local/ruby/bin/ruby

require 'date'

def build_games(teams)
  team_games = {}
  teams.sort.each do |team|
    team_games[team] ||= []
    teams.sort.each do |other_team|
      team_games[other_team] ||= []
      break if team_games[team].length == 8
      next if team == other_team
      game = ((rand * 2).to_i == 0 ? [team, other_team] : [other_team, team])
      team_games[team].push(game)
    end

#     while(team_games[team].length < 8) do
#       teams.shuffle.each do |other_team|
#         next if team_games[other_team].length == 8
#         break if team_games[team].length == 8
#         game = ((rand * 2).to_i == 0 ? [team, other_team] : [other_team, team])
#         team_games[team].push(game)
#         team_games[other_team].push(game)
#       end
#    end
  end
  p team_games
  team_games.each do |key, val| 
    puts key + "    " + val.length.to_s
    p length
  end


  team_games
end

def schedule_games(date, games)
  # if before Friday, advance until Friday
  while (date.wday < 4 ) do
    date += 1
  end

  play_times = 17..24.map { |x| [ 4, x ] }
  play_times += 10..24.map { |x| [ 5, x ] }
  play_times += 9..22.map { |x| [ 6, x ] }

  p play_times
  
end

def has_more_games?()
  @teams_games.map { |team, games| games.legth }.max > 0
end



def build_games_for_team(team, other_teams)
  randomized = other_teams.shuffle
  team_games = {}
  team_games[team] = []
  
  while(team_games[team].length != 8) do
    if randomized.length == 0 then
      randomized = other_teams.shuffle
    end
    other_team = randomized.shift
    game = ((rand * 2).to_i == 0 ? [team, other_team] : [other_team, team])
      
    team_games[team].push(game)
    team_games[other_team] = [] unless team_games[other_team]
    team_games[other_team].push(game)
  end

  team_games.each do |key, val|
    puts key
    p val
  end
  team_games
  
end


play_times = [
  [ 0, [ 17..22 ] ], #mon
  [ 1, [ 17..22 ] ], #tue
  [ 2, [ 17..22 ] ], #wed
  [ 3, [ 17..22 ] ], #thu
  [ 4, [ 17..24 ] ], #fri
  [ 5, [ 10..24 ] ], #sat
  [ 6, [ 9..24 ] ] #sun
]

coed_play_times = [
  [ 4, [ 17..24 ] ], #fri
  [ 5, [ 10..24 ] ], #sat
  [ 6, [ 9..24 ] ] #sun
]

teams = [
  [ 'Coed', '4a', [ 'FC-Harpoon', 'Moto Machende', 'Burninators', 'Defectors', 'Bigfoot', 'Black & Blue' ] ]
]

teams.each do |team_info|
  league = team_info[0]
  division = team_info[1]
  teams = team_info[2]

  @team_games = build_games(teams)
  date = Date.today()
  while(has_more_games?(@team_games)) do
    schedule_games(date, @team_games)
  end
  
end


