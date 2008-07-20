#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'test/spec'
require 'game'
require 'player'
require 'active_record/transactions'

context 'Player Spec' do
  before(:each) do
    ActiveRecord::Base.establish_connection(
                                            :adapter  => "mysql",
                                            :host     => "localhost",
                                            :username => "rails_user",
                                            :password => "foo",
                                            :database => "test"
                                            )

    @game = Game.find(:first)
  end

  specify 'num guys returns the number of guys confirmed for game' do
    PlayersGame.transaction do
      @player = Player.new
      #    @pg = PlayersGames.new(@game.object_id, @player.object_id)
      @player.players_games.new(:game_id => @game.object_id, :status => 'yes')
      assert_equal(1, @game.num_guys_confirmed)
      Playersgame.rollback
    end
  end
end
