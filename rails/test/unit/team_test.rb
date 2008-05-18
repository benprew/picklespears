require File.dirname(__FILE__) + '/../test_helper'
require 'team'
require 'division'
require 'game'
require 'date'

class TeamTest < Test::Unit::TestCase
  fixtures :teams

  # Replace this with your real tests.
  def test_next_unreminded_game
    division = Division.new(:name => "test div", :league => "coed 3b")
    team = Team.new(:name => "The Great Whites", :division => division)

    should_be_game =
      team.games.create(:date => Date.today() + 1,
                        :description => "Great Whites VS Unknown" )

    team.games = [ should_be_game ]

    assert team.next_unreminded_game == should_be_game
  end
end
