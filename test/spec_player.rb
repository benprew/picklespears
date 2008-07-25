#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'test/spec'
require 'player'
require 'team'
require 'game'

context 'PickleSpears' do

  specify 'can join a team' do
    player = Player.new(:name => 'test user')
    player.save
    team = Team.get(12)
    player.join_team(team)
    pt = PlayersTeam.first(:player_id => player.id, :team_id => team.id)
    pt.player_id.should.equal player.id
    player.destroy
    pt.destroy
  end

  specify 'can attend a game' do
    player = Player.new(:name => 'test user')
    player.save
  
    game = Game.first
  
    player.set_attending_status_for_game(game, 'yes')
  
    pg = PlayersGame.first(:player_id => player.id, :game_id => game.id)
    pg.status.should.equal 'yes'
    player.destroy
    pg.destroy
  end
end
