#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'test/spec'
require 'team'
require 'game'
require 'date'

context 'Team Spec' do
  before(:each) do
    @team = Team.get(10)
  end 

  specify 'upcoming games is correct' do
    games = Game.all(:team_id => 10, :date.gt => Date.today())
    assert_equal(games.length, @team.upcoming_games.length)
    assert_equal(games[0], @team.upcoming_games[0])
  end
end
