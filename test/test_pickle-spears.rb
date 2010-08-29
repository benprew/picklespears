#!/usr/bin/env ruby

require 'picklespears/test/unit'

class TestPickleSpears < PickleSpears::Test::Unit
  def test_homepage
    get '/'
    assert_match( /<title>Pickle Spears - now with more vinegar!<\/title>/, last_response.body )
    assert_match( /<div class='header'/, last_response.body )
  end

  def test_browse
    div = Division.create_test(:league => 'Women')
    Team.create_test( :division => div )
    get '/browse', :league => 'Women'
    assert_match /<title>Pickle Spears - browsing league: Women<\/title>/, last_response.body
    assert_match /href='\/team/, last_response.body, 'do we have at least one team'
  end

  def test_team_home
    Team.create_test(:id => 1, :name => 'test team')
    get '/team', :team_id => 1
    assert_match /Upcoming Games/, last_response.body, 'upcoming games'
  end

  def test_search
    div = Division.create_test(:league => 'manly men')
    found_team = Team.create_test(:name => 'THE HARPOON', :id => 10, :division => div)
    found_team2 = Team.create_test(:name => 'THE AHAS', :division => div)
    skipped_team = Team.create_test(:name => 'THE HBRPO', :division => div)

    teams = Team.all( :name.like => '%HA%', :order => [:name.asc] )
    get '/search', :team => 'Ha'
    [ found_team, found_team2 ].each do |team|
      assert_match /team_id=#{team.id}/, last_response.body, "team #{team.id} is found"
    end

    get '/search', :team => 'Harpoon'
    assert_equal '/team?team_id=10', (last_response.headers)['Location']
  end

  def test_stylesheet
    get '/stylesheet.css'
    assert_match /division/, last_response.body 
  end

  def test_not_signed_in_by_default
    get '/'
    assert_match /join/, last_response.body
  end

  def test_todo

    print <<-TODO
      [x] Join/Watch Multiple Teams
          [x] Leave a team
      [ ] Communicate with all members of team
      [x] Quickly see how many people are coming to the next game
          [x] Get reminders about the next game, via email sms
      [ ] Manage a team
          [ ] Send game reminders
          [ ] See who has paid and how much
      [ ] Get contact info for players
          [ ] Allows player to say a little about themselves
      [ ] Find teams/players looking for players/teams

      [ ] can set manager for team


      [ ] for :collections => @things, see: http://github.com/cschneid/irclogger
    TODO

  end

end
