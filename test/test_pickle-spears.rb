#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'sinatra'
require 'sinatra/test/unit'
require 'pickle-spears'

class PickleSpearsTest < Test::Unit::TestCase

  def test_homepage
    get_it '/'
    assert_match( /<title>Pickle Spears - now with more vinegar!<\/title>/, @response.body )
    assert_match( /<hr \/>/, @response.body )
  end

  def test_browse
    get_it '/browse?league=Women'
    assert_match /<title>Pickle Spears - browsing league: Women<\/title>/, @response.body
    assert_match /<select/, @response.body, 'do we have at least one team'
  end

  def test_team_home
    get_it '/team?team_id=1'
    assert_match /Upcoming games/, @response.body, 'upcoming games'
  end

  def test_search
    teams = Team.find(:all, :conditions => [ "name like ?", '%HA%' ], :order => "name")
    get_it '/search?team=Ha'
    teams.each do |team|
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
    get_it '/sign_in'
    assert_match /<title>Pickle Spears - sign in/, @response.body
  end

end
