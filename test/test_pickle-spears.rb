# frozen_string_literal: true

require 'picklespears/test/unit'

class TestPickleSpears < PickleSpears::Test::Unit
  def test_homepage
    get '/'
    assert_match(/<title>Teamvite/, last_response.body)
  end

  def test_unknown_route_is_not_found
    get '/.git/config'
    assert last_response.status == 404
  end

  def test_browse
    league = League.create_test(name: 'Women')
    div = Division.create_test(league_id: league.id)

    team = Team.create_test(division: div, name: 'Barcelona')
    team.add_game(Game.create_test(date: Date.today + 1))

    get '/browse', league_id: league.id
    assert_match(%r{<title>Teamvite - browsing league: Women</title>}, last_response.body)
    assert_match(/Barcelona/, last_response.body, 'do we have at least one team')
  end

  def test_browse_with_league_id_strips_non_numbers
    league = League.create_test(name: 'Women')
    div = Division.create_test(league_id: league.id)

    team = Team.create_test(division: div, name: 'Barcelona')
    team.add_game(Game.create_test(date: Date.today + 1))

    get '/browse', league_id: "#{league.id}/"
    assert_match(%r{<title>Teamvite - browsing league: Women</title>}, last_response.body)
    assert_match(/Barcelona/, last_response.body, 'do we have at least one team')
  end

  def test_team_home
    team = Team.create_test(name: 'test team')
    get '/team/index', id: team.id
    assert_match(/Upcoming Games/, last_response.body, 'upcoming games')
  end

  def test_search
    league = League.create_test(name: 'manly men')
    div = Division.create_test(league_id: league.id)
    found_team = Team.create_test(name: 'THE HARPOON', division_id: div.id)
    found_team2 = Team.create_test(name: 'THE AHAS', division_id: div.id)
    Team.create_test(name: 'THE HBRPO', division_id: div.id)

    get '/team/search', team: 'Ha'
    [found_team, found_team2].each do |team|
      assert_match(%r{team/#{team.id}/index}, last_response.body, "team #{team.id} is found")
    end
  end

  def test_stylesheet
    get '/stylesheet.css'
    assert_match(/division/, last_response.body)
  end

  def test_not_signed_in_by_default
    get '/'
    assert_match(/login/, last_response.body)
  end

  def test_send_game_reminders
    home_team = Team.create_test
    away_team = Team.create_test
    player = Player.create_test
    player.add_team(away_team)

    game = Game.create_test(date: Date.today + 1, home_team: home_team)
    game.away_team = away_team

    get '/send_game_reminders'
    assert PlayersGame[game.id, player.id].reminder_sent
  end
end
