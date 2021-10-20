# frozen_string_literal: true

require 'picklespears'
require 'picklespears/test/unit'

class TestTeam < PickleSpears::Test::Unit
  def setup
    @team = Team.create_test
  end

  def test_team_update
    d = Division.create_test

    assert !@team.manager_name

    visit "/team/#{@team.id}/edit"
    select d.name, from: 'division_id'
    fill_in 'manager_name', with: 'Bennie'
    click_button 'Update'

    assert_equal "/team/#{@team.id}/index", current_path

    assert_equal 'Bennie', @team.reload.manager_name
  end

  def test_next_game
    teams = []
    teams << Team.create_test
    teams << Team.create_test
    games = teams.map { |t| t.add_game(Game.create_test) }

    teams.each do |t|
      assert_equal t.next_game, games.shift
    end
  end

  def test_upcoming_games
    upcoming_game = Game.create_test(date: Time.now)
    upcoming_game.home_team = @team
    upcoming_game2 = Game.create_test(date: Time.now + 1)
    upcoming_game2.home_team = @team
    @team.add_game(Game.create_test(date: Date.today - 1))

    assert_equal([upcoming_game.id, upcoming_game2.id], @team.upcoming_games.map(&:id))
  end

  def test_add_player_to_team
    post '/team/add_player', email: 'foo@bar.com', name: 'Billy', id: @team.id
    follow_redirect!
    assert last_response.ok?, "response not ok: #{last_response.status}"
    assert_match(/Player.*Billy.*added/, last_response.body)

    post '/team/add_player', email: 'foo@bar.com', name: 'Billy', id: @team.id
    follow_redirect!
    assert last_response.ok?
    assert_match(/Player.*Billy.*already on roster/, last_response.body)
  end

  def test_team_calendar
    @team.add_game(Game.create_test)
    get "/team/calendar.ics?layout=false&id=#{@team.id}"

    assert last_response.ok?, 'Can show calendar'
    assert_match @team.games.first.description, last_response.body
    assert_match 'VTIMEZONE', last_response.body, 'includes timezone'
    assert_match("DTSTART;TZID=America/Los_Angeles:#{@team.games.first.date.strftime('%Y%m%d')}", last_response.body)
    assert_match("DTEND;TZID=America/Los_Angeles:#{(@team.games.first.date + 1.hours).strftime('%Y%m%d')}",
                 last_response.body)
  end

  def test_invalid_team_page
    get '/team?team_id=invalid'
    assert_equal 404, last_response.status
  end
end
