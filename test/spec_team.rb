#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/spec'
require 'pickle-spears'
require 'team'
require 'game'
require 'date'

context 'spec_team' do
  before(:each) do
    @team = Team.create_test(:id => 10)
    @team.save
  end 

  specify 'upcoming games is correct' do
    upcoming_game = Game.create_test(:team_id => 10, :date => Date.today())
    historical_game = Game.create_test(:team_id => 10, :date => Date.today() - 1)
    @team.upcoming_games.length.should.equal 1
    @team.upcoming_games[0].id.should.equal upcoming_game.id
  end
end
