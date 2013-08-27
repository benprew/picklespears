#!/usr/bin/ruby

require 'date'
require_relative '../picklespears'
require 'gga4r'
require 'picklespears/round_robin_schedule'
require 'picklespears/schedule'

include RoundRobinSchedule

MENS_LEAGUE_ID = 1
COED_LEAGUE_ID = 2
WOMENS_LEAGUE_ID = 3
SEASON_TO_SCHEDULE = 'Summer 2013'

def find_season(name)
  Season.where(name: name).first ||
    Season.select { |t| t.name.gsub(/[^A-Z0-9]/, '') == name.upcase.gsub(/[^A-Z0-9]/, '') }.first ||
    raise("No season for '#{name}'")
end

@season = find_season(SEASON_TO_SCHEDULE)

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
  total_games = 0
  division_rounds = []
  Division.filter(league_id: league_ids).order(:name.asc).each do |division|
    # TODO: This will need to be changed ot teams in the current season
    team_ids = @season.teams.select { |t| t.division_id == division.id }.map(&:id)
    next unless team_ids.length > 0
    rounds = build_games(team_ids, 8)
    rounds.each { |r| r.each { |g| (h, a) = g; total_games += 1 } }
    division_rounds << rounds.map { |round| round.map { |pairing| OpenStruct.new( team_ids: pairing, league_id: division.league_id ) } }
  end

  games = 0

# This array needs to be as long as the longest round
  first_round = division_rounds.shift
  longest_round = division_rounds.max { |a, b| a.length <=> b.length }.length
  (longest_round - first_round.length).times { first_round << nil }

  first_round.zip(*division_rounds) do |round|
    round.flatten(1).shuffle.each do |pairing|
      next unless pairing
      games += 1
      schedule.add_game!(pairing)
    end
  end
  raise "Not enough games scheduled!" if games != total_games
end

def create_population(num_times=10)
  population = []

  num_times.times do
    schedule = Schedule.new(
      @season,
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
    puts "adding population"
    population << schedule
  end

  population
end

def save_schedule(schedule)
end

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

require 'perftools'

# use Linux perf for profiling:
# http://blog.tddium.com/2012/11/20/profiling-ruby/
# or you can use DTrace:
# http://crypt.codemancers.com/posts/2013-04-16-profile-ruby-apps-dtrace-part1/

# /var/www/teamvite/bundle/ruby/1.9.1/bundler/gems/perftools.rb-a632a4522682/bin/pprof --text /bin/ls /tmp/population_create_perf.log
#PerfTools::CpuProfiler.start("/tmp/population_create_perf.log") do
  puts "Creating population"
  ga = GeneticAlgorithm.new(create_population(10), max_population: 20)

puts "Evolving"
1000.times { |i| puts "Generation #{i}"; ga.evolve; puts "best: #{ga.best_fit.fitness} #{ga.best_fit.object_id}"; break if ga.best_fit.fitness == 1 }
require 'pp'
best = ga.best_fit
p best.fitness

warn "Writing schedule"
best.export_to_file('schedule.csv')
