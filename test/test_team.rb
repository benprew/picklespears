require 'test/unit'
require 'team'

class TestTeam < Test::Unit::TestCase
  def test_next_unreminded_game
    next_game = Team.find(1).next_unreminded_game
    assert(next_game)
  end
end
