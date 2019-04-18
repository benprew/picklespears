require 'picklespears/test/unit'
require 'picklespears/schedule'

class TestSchedule < PickleSpears::Test::Unit
  MENS_LEAGUE_ID = 1
  COED_LEAGUE_ID = 2
  WOMENS_LEAGUE_ID = 3

  def setup
    season = Season.new
    season.start_date = Date.new(2013,3,11)

    @schedule = Schedule.new(
      season,
      [
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 1, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ COED_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 6, num_games: 4, first_game_time: '13:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, COED_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 7, num_games: 4, first_game_time: '13:10'}), # sunday is flex day
        },
      ])

    @games = []
    (1..20).map { |i| g = OpenStruct.new( team_ids: [i, i + 3], league_id: COED_LEAGUE_ID ); @schedule.add_game!(g); @games << g }
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

  def test_build_for_week
    game_times = @schedule.send(:build_for_week, Date.new(2013,3,11))

    assert_equal ['18:10', '19:00', '19:50', '20:40', '21:30'], game_times.select { |gt| gt.date.to_date == Date.new(2013,03,11) }.map { |g| g.date.strftime('%H:%M') }
    assert_equal ['13:10', '14:00', '14:50', '15:40' ], game_times.select { |gt| gt.date.to_date == Date.new(2013,03,16) }.map { |g| g.date.strftime('%H:%M') }
    assert_equal ['13:10', '14:00', '14:50', '15:40' ], game_times.select { |gt| gt.date.to_date == Date.new(2013,03,17) }.map { |g| g.date.strftime('%H:%M') }
  end

  def test_game_swap
    @schedule.games.sort! { |a,b| a.date <=> b.date }
    pre_swap_games = Marshal.load( Marshal.dump(@schedule.games))

    @schedule.send(:swap_games!, 0, 7)
    post_swap_games = @schedule.games.sort { |a,b| a.date <=> b.date }

    assert_equal pre_swap_games.map(&:league_ids), post_swap_games.map(&:league_ids)
    assert_equal [ pre_swap_games[7], pre_swap_games[1..6], pre_swap_games[0] ].flatten(1).map(&:team_ids), post_swap_games.map(&:team_ids)[0..7]
  end

  def test_swappable
    season = Season.new
    season.start_date = Date.new(2013,3,11)

    schedule = Schedule.new(
      season,
      [
        {
          league_ids: [ MENS_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 1, num_games: 5, first_game_time: '18:10'}),
        },
        {
          league_ids: [ COED_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 6, num_games: 4, first_game_time: '13:10'}),
        },
        {
          league_ids: [ MENS_LEAGUE_ID, COED_LEAGUE_ID, WOMENS_LEAGUE_ID ],
          slot_info: OpenStruct.new({ cwday: 7, num_games: 4, first_game_time: '13:10'}), # sunday is flex day
        },
      ])

    (1..2).map { |i| g = OpenStruct.new( team_ids: [1, 2], league_id: COED_LEAGUE_ID ); schedule.add_game!(g);  }

    assert schedule.send(:swappable?, *schedule.games), "games should be swappable"
  end

  # def test_ideal_solution_fitness
  #   assert !@schedule.instance_variable_get(:@score_by_games)
  #   @schedule.instance_variable_set(:@score_by_games, [])

  #   assert_equal 1, @schedule.fitness
  # end
end
