require 'picklespears/test/unit'

class TestDivision < PickleSpears::Test::Unit
  def setup
    @division = Division.create_test(name: 'Coed d1')
    team = Team.create_test(division: @division)
    game = Game.create_test
    game.add_team(team)
  end

  def test_division_index
    get '/division/index', id: @division.id

    assert_match @division.name, last_response.body
    assert last_response.ok?
  end

  def test_unknown_division
    get '/division/index', id: 133

    assert last_response.status == 404
    assert_match 'not found', last_response.body
  end
end
