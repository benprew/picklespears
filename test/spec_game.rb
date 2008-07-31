#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'pickle-spears'
require 'mocha'
require 'game'
require 'player'
require 'time'
require 'picklespears/test/unit'

context 'spec_game', PickleSpears::Test::Unit do
  before(:each) do
    @game = Game.new(:date => Time.now(), :description => 'test game', :team_id => 1)
    @game.save
  end

  specify 'num guys returns the number of guys confirmed for game' do
    @game.num_guys_confirmed.should.equal 0
  end

  specify 'guys confirmed for a game works if someone is actually confirmed' do
    player = Player.create_test(:gender => 'guy')
    PlayersGame.create_test(:game => @game, :player => Player.create_test)
    @pg = PlayersGame.create_test(:game => @game, :player => player, :status => 'yes')
    game = Game.get(@pg.game_id)
    game.num_guys_confirmed.should.equal 1
    game.num_gals_confirmed.should.equal 0
  end
end
