#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def test_next_game
    teams = []
    teams << Team.create_test
    teams << Team.create_test
    games = teams.map { |t| Game.create_test(:team_id => t.id) }

    teams.each do |t|
      assert( t.next_game == games.shift )
    end
  end

  def test_upcoming_games
    team = Team.create_test
    upcoming_game = Game.create_test(:team_id => team.id, :date => Time.now())
    historical_game = Game.create_test(:team_id => team.id, :date => Date.today() - 1)
    assert_equal(1, team.upcoming_games.length)
    assert_equal(team.upcoming_games[0].id, upcoming_game.id)
  end

  def test_add_player_to_team
    team = Team.create_test
    post "/team/#{team.id}/add_player", email: 'foo@bar.com', name: 'Billy'

    assert last_response.ok?
    assert_match 'Player "Billy" added', last_response.body
  end
end
