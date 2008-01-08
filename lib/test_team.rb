require 'test/unit'
require 'team'

class TestTeam < Test::Unit::TestCase
  def test_select
    teams = Team.select { |team| team.name == 'FC HARPOON' }
    assert(teams.length == 1)
    assert(teams[0].name = 'FC HARPOON')
  end
end
