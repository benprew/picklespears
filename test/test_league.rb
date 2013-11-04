#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestLeague < PickleSpears::Test::Unit
  def test_league_manager_only_sees_games_for_leagues_they_are_managing
    manager = Player.create_test
    league  = League.create_test
    manager.add_league(league)
    league2 = League.create_test

    game = Game.create_test(date: Date.today, description: 'game here')
    home_team = Team.create_test(division_id: Division.create_test.id)
    away_team = Team.create_test(division_id: Division.create_test.id)
    game.home_team = home_team
    game.away_team = away_team

    out_of_league_team = Team.create_test(division_id: Division.create_test.id)
    out_of_league_team.add_game(Game.create_test(date: Date.today, description: 'game not here'))

    league.add_division(home_team.division)
    league2.add_division(out_of_league_team.division)

    login(manager, 'secret')

    get '/league/manage'
    assert_match(/game here/, last_response.body)
    assert_no_match(/game not here/, last_response.body)
  end
end
