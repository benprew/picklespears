#!/usr/bin/env ruby

require 'pickle-spears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def test_next_game
    teams = []
    teams << Team.create_test(:id => 1)
    teams << Team.create_test(:id => 2)
    games = []
    games << Game.create_test(:team => teams[0])
    games << Game.create_test(:team => teams[1])

    teams.each do |t|
      assert( t.next_game == games.shift )
    end
  end

  def test_upcoming_games
    team = Team.create_test(:id => 10)
    upcoming_game = Game.create_test(:team => team, :date => Date.today())
    historical_game = Game.create_test(:team => team, :date => Date.today() - 1)
    assert_equal(1, team.upcoming_games.length)
    assert(team.upcoming_games[0] == upcoming_game)
  end
end
