#!/usr/bin/env ruby

require 'picklespears/test/unit'
require 'picklespears/schedule'

class TestSchedule < PickleSpears::Test::Unit

  MENS_LEAGUE_ID = 1
  COED_LEAGUE_ID = 2
  WOMENS_LEAGUE_ID = 3

  def setup
    @schedule = Schedule.new(
      Date.new(2013,3,11),
      [
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 1, num_games: 5, first_game_time: '18:10'}),
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

    @games = []
    (1..4).map { |i| g = OpenStruct.new( team_ids: [i, i + 3], league_id: COED_LEAGUE_ID ); @schedule.add_game!(g); @games << g }
  end

  def test_scheduled_games
    assert_equal @games.map(&:team_ids), @schedule.games.map(&:team_ids)
  end

  def games_this_week
    game_info = @schedule.games[0]
    game_info.team_ids.each do |team_id|
      assert @schedule.teams_have_game_this_week(game_info.date.strftime('%W'), [team_id])
    end
    assert !@schedule.teams_have_game_this_week(game_info.date.strftime('%W'), [12345])
  end

  def first_game
    assert @schedule.first_game_of_day?(Time.new(2013,3,16, 13,10,00, '+00:00'))
    assert !@schedule.first_game_of_day?(Time.new(2013,3,16, 14,00,00, '+00:00'))
  end

  def last_game
    assert @schedule.last_game_of_day?(Time.new(2013,3,16, 00,00,00, '+00:00')) # last game is really midnight of the 17th
    assert !@schedule.last_game_of_day?(Time.new(2013,3,16, 23,10,00, '+00:00'))
  end

  # def test_game_swap
  #   @schedule.send(:swap_game!, 0, 2)

  #   assert_equal @times.map(&:to_s), @schedule.games.map { |g| g.date.to_s }
  #   assert_equal [ @games[2], @games[1], @games[0], @games[3] ].map(&:id), @schedule.games.map(&:id)
  # end

  # def test_ideal_solution_fitness
  #   assert !@schedule.instance_variable_get(:@score_by_games)
  #   @schedule.instance_variable_set(:@score_by_games, [])

  #   assert_equal 1, @schedule.fitness
  # end
end
