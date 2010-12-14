#!/usr/local/ruby/bin/ruby

require 'date'

class Array
  def rotate_left!
    push shift unless length == 0
  end
end

def build_games(teams)
  rounds = []
  games_per_team = Hash[*teams.map{ |t| [t, 0] }.flatten]

  while teams.length > 1 do
    mid = teams.length / 2
    first_half = teams[0, mid]
    last_half = teams[mid, teams.length]
    round = first_half.zip last_half.reverse
    rounds += [ round ]

    round.each { |g| g.each { |t| games_per_team[t] += 1 } }
    teams = teams.select { |t| games_per_team[t] < 8 }
    teams.rotate_left!
  end

  raise "unable to schedule game for team #{teams[0]}" if teams.length == 1

  rounds
end

def schedule_game(date, game)
  # if before Friday, advance until Friday
  while (date.wday < 4 ) do
    date += 1
  end

  play_times = (17..24).map { |x| [ 4, x ] } + (10..24).map { |x| [ 5, x ] } + (9..22).map { |x| [ 6, x ] }
  
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
  [ 'Coed', '4a', (1..5).map { |i| "team #{i}" } ]
]

teams.each do |team_info|
  league = team_info[0]
  division = team_info[1]
  teams = team_info[2]

  date = Date.today()
  build_games(teams).each do |round|
    round.each do |game|
      schedule_game date, round
    end
  end
end
