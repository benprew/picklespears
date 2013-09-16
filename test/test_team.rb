#!/usr/bin/env ruby

require 'picklespears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def setup
    @team = Team.create_test
  end

  def test_next_game
    teams = []
    teams << Team.create_test
    teams << Team.create_test
    games = teams.map { |t| t.add_game(Game.create_test) }

    teams.each do |t|
      assert( t.next_game == games.shift )
    end
  end

  def test_upcoming_games
    upcoming_game = Game.create_test(:date => Time.now())
    upcoming_game.home_team = @team
    upcoming_game2 = Game.create_test(:date => Time.now() + 1)
    upcoming_game2.home_team = @team
    @team.add_game(Game.create_test(:date => Date.today() - 1))

    assert_equal([ upcoming_game.id, upcoming_game2.id ], @team.upcoming_games.map(&:id))
  end

  def test_add_player_to_team
    post "/team/#{@team.id}/add_player", email: 'foo@bar.com', name: 'Billy'

    assert last_response.ok?
    assert_match 'Player "Billy" added', last_response.body

    post "/team/#{@team.id}/add_player", email: 'foo@bar.com', name: 'Billy'
    assert last_response.ok?
    assert_match 'Player "Billy" already on roster', last_response.body
  end

  def test_team_calendar
    @team.add_game(Game.create_test)
    get "/team/#{@team.id}/calendar.ics"

    assert last_response.ok?, "Can show calendar"
    assert_match @team.games.first.description, last_response.body
    assert_match 'DTSTART;TZID=America/Los_Angeles:' + @team.games.first.date.strftime('%Y%m%d'), last_response.body
    assert_match 'DTEND;TZID=America/Los_Angeles:' + (@team.games.first.date + 1.hours).strftime('%Y%m%d'), last_response.body
  end
end
