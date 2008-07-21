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
    assert_equal(0, @game.num_guys_confirmed)
  end
end
