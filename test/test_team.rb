#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def test_next_game
    teams = []
    teams << Team.create_test
    teams << Team.create_test
    games = teams.map { |t| t.add_game(Game.create_test) }

    teams.each do |t|
      assert( t.next_game == games.shift )
    end
  end

  def test_upcoming_games
    team = Team.create_test
    upcoming_game = Game.create_test(:date => Time.now())
    upcoming_game.add_team(team)
    upcoming_game2 = Game.create_test(:date => Time.now() + 1)
    upcoming_game2.add_team(team)
    historical_game = Game.create_test(:date => Date.today() - 1)
    historical_game.add_team(team)

    assert_equal([ upcoming_game.id, upcoming_game2.id ], team.upcoming_games.map(&:id))
  end

  def test_add_player_to_team
    team = Team.create_test
    post "/team/#{team.id}/add_player", email: 'foo@bar.com', name: 'Billy'

    assert last_response.ok?
    assert_match 'Player "Billy" added', last_response.body

    post "/team/#{team.id}/add_player", email: 'foo@bar.com', name: 'Billy'
    assert last_response.ok?
    assert_match 'Player "Billy" already on roster', last_response.body
  end
end
