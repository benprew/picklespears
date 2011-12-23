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

    team = Team.create_test( :division => div, :name => 'Barcelona' )
    Game.create_test( :team_id => team.id, :date => Date.today + 1 )

    get '/browse', :league => 'Women'
    assert_match /<title>Pickle Spears - browsing league: Women<\/title>/, last_response.body
    assert_match /Barcelona/, last_response.body, 'do we have at least one team'
  end

  def test_team_home
    team = Team.create_test( :name => 'test team' )
    get '/team', :team_id => team.id
    assert_match /Upcoming Games/, last_response.body, 'upcoming games'
  end

  def test_search
    div = Division.create_test(:league => 'manly men')
    found_team = Team.create_test(:name => 'THE HARPOON', :division_id => div.id)
    found_team2 = Team.create_test(:name => 'THE AHAS', :division_id => div.id)
    skipped_team = Team.create_test(:name => 'THE HBRPO', :division_id => div.id)

    teams = Team.filter(:name.like '%HA%').order(:name.asc).all
    get '/team/search', :team => 'Ha'
    [ found_team, found_team2 ].each do |team|
      assert_match /team_id=#{team.id}/, last_response.body, "team #{team.id} is found"
    end

    get '/team/search', :team => 'Harpoon'
    assert_equal "http://example.org/team?team_id=#{found_team.id}", last_response.location
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

    == Schedule system ==
      [ ] can set manager for team
      [ ] can schedule refs for games
      [ ] can enter results of games
      [ ] can show schedues of upcoming games

    == Team management ==
      [ ] Add a new team
      [ ] Add a game
      [ ] Add a player to a team (name, email)

      [ ] Change login to just use passwords instead of openid

      [ ] restructure file layout similar to monkrb
      [ ] Investigate webrat for testing

      [ ] Communicate with all members of team
      [ ] Manage a team
          [ ] Send game reminders
          [ ] See who has paid and how much
      [ ] Get contact info for players
          [ ] Allows player to say a little about themselves
      [ ] Find teams/players looking for players/teams

    TODO

  end

end
