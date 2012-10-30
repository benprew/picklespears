#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestPlayer < PickleSpears::Test::Unit

  def test_can_join_a_team
    player = Player.create_test(:name => 'test user')
    team = Team.create_test
    player.add_team(team)
    pt = PlayersTeam.first(:player_id => player.id, :team_id => team.id)
    assert_equal(pt.player_id, player.id)
  end

  def test_can_attend_a_game
    player = Player.create_test(:name => 'test user')
    game = Game.create_test

    player.set_attending_status_for_game(game, 'yes')

    pg = PlayersGame.first(:player_id => player.id, :game_id => game.id)
    assert_equal('yes', pg.status)
  end

  def test_can_update_info_via_post
    player = Player.create_test
    login(player, 'secret')
    post '/player/update', { :name => 'new_name' }
    assert_equal 'http://example.org/player', last_response.location
    assert_equal 'new_name', player.reload.name
  end

  def test_join_team_as_part_of_sign_up_process_works
    Player.create_test

    div = Division.create_test
    Team.create_test( :name => 'team to find', :division_id => div.id )
    Team.create_test( :name => 'should not be found', :division_id => div.id )

    get '/player/join_team'
    assert_match(/Done!/, last_response.body)
    assert_no_match(/team to find/, last_response.body)

    get '/player/join_team?team=find'
    assert_match(/find a team/, last_response.body)
  end

  def test_can_leave_a_team
    player = Player.create_test
    team = Team.create_test
    team2 = Team.create_test

    team.add_player(player)
    team2.add_player(player)

    login(player, 'secret')
    post '/players_team/delete', { team_id: team.id }
    follow_redirect!
    assert_match "You have successfully left #{team.name}", last_response.body

    pts = PlayersTeam.all
    assert_equal(1, pts.length)
    assert_equal(team2.id, pts[0].team_id)
  end
end
