#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestLeague < PickleSpears::Test::Unit
  def test_league_manager_only_sees_games_for_leagues_they_are_managing
    manager = Player.create_test
    league  = League.create_test(name: 'league 1')
    division1 = Division.create_test(league_id: league.id)
    manager.add_league(league)
    league2 = League.create_test(name: 'league 2')
    division2 = Division.create_test(league_id: league2.id)

    game = Game.create_test(date: Date.today, description: 'game here')
    home_team = Team.create_test(division_id: division1.id)
    away_team = Team.create_test(division_id: division1.id)
    game.home_team = home_team
    game.away_team = away_team

    out_of_league_team = Team.create_test(division_id: division2.id)
    out_of_league_team.add_game(
      Game.create_test(date: Date.today, description: 'game not here'))

    login(manager, 'secret')

    get '/league/manage'
    assert_match(/game here/, last_response.body)
    assert(last_response.body !~ /game not here/)
  end
end
