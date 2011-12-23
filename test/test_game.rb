#!/usr/bin/env ruby

require 'picklespears/test/unit'

class TestGame < PickleSpears::Test::Unit
  def setup
    super
    @game = Game.create_test(:date => Time.now(), :description => 'test game', :team_id => 1)
  end

  def test_num_guys_returns_the_number_of_guys_confirmed_for_game
    assert_equal(0, @game.num_guys_confirmed)
  end

  def test_guys_confirmed_for_a_game
    player = Player.create_test(:gender => 'guy')
    PlayersGame.create_test(
      :game_id => @game.id,
      :player_id => Player.create_test.id,
      :status => 'no'
    )
    pg = PlayersGame.create_test(
      :game_id => @game.id,
      :player_id => player.id,
      :status => 'yes'
    )
    game = Game[pg.game_id]
    assert_equal(1, game.num_guys_confirmed)
    assert_equal(0, game.num_gals_confirmed)
  end
end
