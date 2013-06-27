#!/usr/bin/env ruby

# Expects a schedule in tab-delimited format with the following fields
# Game Date
# Home Team
# Away Team

require 'csv'
require 'optparse'

require_relative '../picklespears'
require 'picklespears/schedule'
require 'picklespears/schedule_builder'

OptionParser.new do |op|
  op.on("--season season", "season name") { |val| @season_name = val }
  op.on('--schedule schedule')    { |val| @schedule_filename = val }
end.parse!

def score_schedule(builder)
  empty_game_times = 0
  crappy_game_times = 0
  nonpreferred_game_time = 0
  games_on_requested_days_off = 0

  builder.calc_score_by_games.sort { |a, b| a[0] <=> b[0] }.each do |score_detail|
    (date, score) = score_detail
    case score
    when ScheduleBuilder::SCORE_FOR_EMPTY_GAME_TIME
      puts "#{date} has previous empty games"
      empty_game_times += 1
    when ScheduleBuilder::SCORE_FOR_CRAPPY_GAME_TIME
      puts "#{date} is 2nd 'crappy' game time for team"
      crappy_game_times += 1
    when ScheduleBuilder::SCORE_FOR_GAME_ON_NON_PREFERRED_DAY
      puts "#{date} is on non-preferred day"
      nonpreferred_game_time += 1
    when ScheduleBuilder::SCORE_FOR_GAME_ON_REQUESTED_DAY_OFF
      puts "#{date} is on requested day off"
      games_on_requested_days_off += 1
    end
  end

  puts "# of games after empty slot: #{empty_game_times}"
  puts "# of games that are a 2nd first or last game for team: #{crappy_game_times}"
  puts "# of games that are on a nonpreferred day for a team: #{nonpreferred_game_time}"
  puts "# of games that are on a team's requested day off: #{games_on_requested_days_off}"
end

season = Season.where(name: @season_name).first

MENS_LEAGUE_ID = 1
COED_LEAGUE_ID = 2
WOMENS_LEAGUE_ID = 3

schedule = Schedule.new(season,
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
      ])

CSV.read(@schedule_filename).each do |r|
  (date_str, home_team, away_team) = r

  date = DateTime.strptime(date_str, '%a %b %e %I:%M %p')

  home = season.teams.select { |t| t.name == home_team }.first
  away = season.teams.select { |t| t.name == away_team }.first

  raise "no team for #{home_team}" unless home
  raise "no team for #{away_team}" unless away

  schedule.games << OpenStruct.new(
    team_ids: [home.id, away.id],
    league_id: home.division.league.id,
    league_ids: home.division.league.id,
    date: date.to_time)
end

score_schedule(schedule)
schedule.export_to_file('schedule.csv')
