require 'picklespears/test/unit'

class TestDivision < PickleSpears::Test::Unit
  def setup
    @division = Division.create_test(name: 'Coed d1')
    team = Team.create_test(division: @division)
    game = Game.create_test
    game.add_team(team)
  end

  def test_division_index
    get '/division', division_id: @division.id

    assert_match @division.name, last_response.body
    assert last_response.ok?
  end

  def test_unknown_division
    get '/division', division_id: 133

    follow_redirect!
    assert last_response.ok?
    assert_match 'No division found', last_response.body
  end

  def test_division_index_redirect_to_list_with_invalid_division_id
    get '/division'

    assert_equal "http://#{DOMAIN}/division/list", last_response.location
    follow_redirect!
    assert last_response.ok?
    assert_match 'No division found', last_response.body
  end
end
