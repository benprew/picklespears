#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'pickle-spears'

context 'spec_player' do

  specify 'can join a team' do
    player = Player.create_test(:name => 'test user')
    team = Team.create_test(:id => 12)
    player.join_team(team)
    pt = PlayersTeam.first(:player_id => player.id, :team_id => team.id)
    pt.player_id.should.equal player.id
    player.destroy
    pt.destroy
  end

  specify 'can attend a game' do
    player = Player.create_test(:name => 'test user')
    game = Game.create_test
  
    player.set_attending_status_for_game(game, 'yes')
  
    pg = PlayersGame.first(:player_id => player.id, :game_id => game.id)
    pg.status.should.equal 'yes'
    player.destroy
    pg.destroy
  end
end
