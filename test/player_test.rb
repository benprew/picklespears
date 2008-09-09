#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/unit'
require 'pickle-spears'
require 'picklespears/test/unit'

class TestPlayer < PickleSpears::Test::Unit
  def test_can_join_a_team
    player = Player.create_test(:name => 'test user')
    team = Team.create_test(:id => 12)
    player.join_team(team)
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
    Player.create_test( :email_address => 'test', :password => 'test' )
    post_it '/player/sign_in', 'email_address=test;password=test'
    cookie = @response.headers['Set-Cookie']
    post_it '/player/update?name=new_name', '', { "HTTP_COOKIE" => cookie }

    assert_equal('/player', @response.location)
    assert_equal('new_name', Player.first(:email_address => 'test').name)
  end

  def test_join_team_as_part_of_sign_up_process_works
    Player.create_test( :email_address => 'test', :password => 'test' )

    div = Division.create_test
    Team.create_test( :name => 'team to find', :division => div )
    Team.create_test( :name => 'should not be found', :division => div )

    post_it '/player/sign_in', 'email_address=test;password=test'
    session_id = @response.headers['Set-Cookie']

    get_it '/player/join_team', '', { "HTTP_COOKIE" => session_id }
    assert_match(/Done!/, @response.body)
    assert_no_match(/team to find/, @response.body)

    get_it '/player/join_team?team=find', '', { "HTTP_COOKIE" => session_id }
    assert_match(/team to find/, @response.body)
  end

  def test_can_update_password
    player = Player.create_test
    assert player.fupdate({ :password => 'test', :password2 => 'test' })
  end

end
