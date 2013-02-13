#!/usr/local/ruby/bin/ruby

require 'date'
require 'gga4r'
require_relative '../picklespears'
require 'picklespears/schedule_builder'
require 'picklespears/round_robin_schedule'
require 'picklespears/schedule'

include RoundRobinSchedule

MENS_LEAGUE_ID = 1
COED_LEAGUE_ID = 2
WOMENS_LEAGUE_ID = 3

# def games_for_teams(teams, schedule, league_id)
#   build_games(teams, 8).each do |round|
#     p round
#     round.each do |game|
#       p "#{schedule.next(league_id)} #{game}"
#     end
#     raise
#   end
# end

def rounds_for_league(league_ids, schedule)
  division_rounds = []
  games = []
  Division.filter(league_id: league_ids).order(:name.asc).each do |division|
    # TODO: This will need to be changed ot teams in the current season
    team_ids = division.teams_with_upcoming_games.map(&:id)
    next unless team_ids.length > 0
    rounds = build_games(team_ids, 8)
    division_rounds << rounds.map { |round| round.map { |pairing| OpenStruct.new( team_ids: pairing, league_id: division.league_id ) } }
  end

  first_round = division_rounds.shift

  first_round.zip(*division_rounds).each do |round|
    round.flatten(1).shuffle.each do |pairing|
      next unless pairing
      schedule.add_game!(pairing)
    end
  end
end

def create_population(num_times=10)
  population = []

  num_times.times do
    schedule = Schedule.new(
      Date.today - Date.today.cwday + 1, #start date
      [
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 1, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 2, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 3, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 4, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ COED_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 5, num_games: 8, first_game_time: '18:10'}),
        },
        {
          league_ids: [ COED_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 6, num_games: 11, first_game_time: '13:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, COED_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 7, num_games: 12, first_game_time: '13:10'}), # sunday is flex day
        },
      ]
      )

    rounds_for_league([COED_LEAGUE_ID, MENS_LEAGUE_ID, WOMENS_LEAGUE_ID], schedule)
    population << ScheduleBuilder.new(schedule)
  end

  population
end

def save_schedule(schedule)
  puts "Writing schedule"
  File.open('schedule.csv', 'w') do |file|
    schedule.games.each do |game|
      file.puts [game.date.strftime(PickleSpears::DATE_FORMAT), game.team_ids.map { |id| Team[id].name }.flatten(1) ].join "\t"
    end
  end
end

def score_schedule(builder)
  builder.score_by_games.sort { |a, b| a[0] <=> b[0] }.each do |score_detail|
    (date, score) = score_detail
    case score
    when ScheduleBuilder::SCORE_FOR_EMPTY_GAME_TIME
      puts "#{date} has previous empty games"
    when ScheduleBuilder::SCORE_FOR_CRAPPY_GAME_TIME
      puts "#{date} is 2nd 'crappy' game time for team"
    end
  end
end

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

require 'perftools'
PerfTools::CpuProfiler.start("/tmp/population_create_perf.log") do
  puts "Creating population"
  ga = GeneticAlgorithm.new(create_population(10), max_population: 20)

  best = ga.best_fit

  score_schedule(best)
  save_schedule(best.schedule)
end

raise

puts "Evolving"
100.times { |i| puts "Generation #{i}"; ga.evolve; puts "best: #{ga.best_fit.fitness} #{ga.best_fit.object_id}"; break if ga.best_fit.fitness == 1 }
require 'pp'
best = ga.best_fit
# pp best.score_by_games.map { |gs| best.games[gs[0]] }
p best.fitness

