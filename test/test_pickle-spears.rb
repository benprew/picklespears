#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/unit'
require 'pickle-spears'
require 'test/unit'
require 'picklespears/test/unit'

class TestPickleSpears < PickleSpears::Test::Unit
  def test_homepage
    get_it '/'
    assert_match( /<title>Pickle Spears - now with more vinegar!<\/title>/, @response.body )
    assert_match( /<div class='header'/, @response.body )
  end

  def test_browse
    div = Division.create_test(:league => 'Women')
    Team.create_test( :division => div )
    get_it '/browse?league=Women'
    assert_match /<title>Pickle Spears - browsing league: Women<\/title>/, @response.body
    assert_match /<select/, @response.body, 'do we have at least one team'
  end

  def test_team_home
    Team.create_test(:id => 1, :name => 'test team')
    get_it '/team?team_id=1'
    assert_match /Upcoming Games/, @response.body, 'upcoming games'
  end

  def test_search
    div = Division.create_test(:league => 'manly men')
    found_team = Team.create_test(:name => 'THE HARPOON', :id => 10, :division => div)
    found_team2 = Team.create_test(:name => 'THE AHAS', :division => div)
    skipped_team = Team.create_test(:name => 'THE HBRPO', :division => div)

    teams = Team.all( :name.like => '%HA%', :order => [:name.asc] )
    get_it '/search?team=Ha'
    [ found_team, found_team2 ].each do |team|
      assert_match /team_id=#{team.id}/, @response.body, "team #{team.id} is found"
    end

    get_it '/search?team=Harpoon'
    assert_equal '/team?team_id=10', (@response.headers)['Location']
  end

  def test_stylesheet
    get_it '/stylesheet.css'
    assert_match /division/, @response.body 
  end

  def test_not_signed_in_by_default
    get_it '/player/sign_in'
    assert_match /<title>Pickle Spears - sign in/, @response.body
  end
end
