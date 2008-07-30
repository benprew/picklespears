$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/unit'
require 'pickle-spears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def test_next_unreminded_game
    team = Team.create_test(:id => 1)
    game = Game.create_test(:team => team)
    next_game = Team.get(1).next_unreminded_game
    assert(next_game)
  end
end
