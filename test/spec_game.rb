#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'test/spec'
require 'game'
require 'player'

context 'Player Spec' do
  before(:each) do
    @game = Game.first
  end

  specify 'num guys returns the number of guys confirmed for game' do
    @game.num_guys_confirmed.should.equal 0
  end

  specify 'guys confirmed for a game works if someone is actually confirmed' do
    pg = PlayersGame.first
    game = Game.get(pg.game_id)
    game.num_guys_confirmed.should.equal 1
  end
end
