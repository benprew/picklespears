$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/unit'
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
end
