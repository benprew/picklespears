#!/usr/local/ruby/bin/ruby

require 'date'
require 'time'
require 'picklespears/round_robin_schedule'
require_relative '../picklespears'

include RoundRobinSchedule

class Schedule
  attr :schedule, :current_week

  def initialize(schedule_array, season_start_date)
    @schedule = schedule_array
    @current_week = season_start_date
    @games = build_week(current_week)
  end

  def next
    if @games.length < 1
      @current_week += 7
      @games = build_week(@current_week)
    end
    @games.shift
  end

  def add_scheduled_exception
    raise "TODO: Not implemented"
  end

  private

  def build_week(week)
    @schedule.map do |day|
      build_game_times(week, day.wday, day.num_games, day.first_game_time)
    end.flatten
  end

  def build_game_times(week_start, weekday_offset, num_games_for_day, first_game_time, game_length_in_minutes=50)
    start_date = week_start + weekday_offset
    num_games_for_day -= 1
    return (0..num_games_for_day).map do |i|
      dt = DateTime.strptime("#{start_date} #{first_game_time} CET", '%Y-%m-%d %H:%M %Z')
      time = dt.to_time
      time + (60 * game_length_in_minutes * i)
    end
  end
end

def games_for_teams(teams, schedule)
  build_games(teams, 8).each do |round|
    round.each do |game|
      p "#{schedule.next} #{game}"
    end
  end
end

def rounds_for_league(league_ids, schedule)
  division_rounds = []
  Division.filter(league_id: league_ids).order(:name.asc).each do |division|
    # TODO: This will need to be changed ot teams in the current season
    teams = division.teams_with_upcoming_games
    next unless teams.length > 0
    division_rounds << games_for_teams(teams, schedule)
  end

  return division_rounds
end

MENS_LEAGUE_ID = 1
COED_LEAGUE_ID = 2
WOMENS_LEAGUE_ID = 3

coed_schedule = Schedule.new(
  [
    OpenStruct.new({ wday: 0, num_games: 12, first_game_time: '13:10'}),
    OpenStruct.new({ wday: 4, num_games: 8, first_game_time: '18:10'}),
    OpenStruct.new({ wday: 6, num_games: 11, first_game_time: '13:10'}),
  ],
  Date.today - Date.today.wday
)

rounds_for_league(COED_LEAGUE_ID, coed_schedule)

single_gender_schedule = Schedule.new(
  [
    OpenStruct.new({ wday: 1, num_games: 5, first_game_time: '18:10'}),
    OpenStruct.new({ wday: 2, num_games: 5, first_game_time: '18:10'}),
    OpenStruct.new({ wday: 3, num_games: 5, first_game_time: '18:10'}),
    OpenStruct.new({ wday: 4, num_games: 5, first_game_time: '18:10'}),
  ],
  Date.today - Date.today.wday
)

rounds_for_league([MENS_LEAGUE_ID, WOMENS_LEAGUE_ID], coed_schedule)
