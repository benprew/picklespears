#!/usr/local/ruby/bin/ruby

require 'date'
require 'picklespears/round_robin_schedule'

include RoundRobinSchedule

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
  build_games(teams, 8).each do |round|
    p round
    round.each do |game|
      schedule_game date, round
    end
  end
end
