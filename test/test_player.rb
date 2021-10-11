# frozen_string_literal: true

require 'picklespears/test/unit'
require 'picklespears'

class TestPlayer < PickleSpears::Test::Unit
  def test_can_join_a_team
    player = Player.create_test(name: 'test user')
    team = Team.create_test
    player.add_team(team)
    pt = PlayersTeam.first(player_id: player.id, team_id: team.id)
    assert_equal(pt.player_id, player.id)
  end

  def test_can_use_attending_status_link_from_email
    player = Player.create_test(name: 'test user')
    team = Team.create_test
    team.add_player(player)
    game = Game.create_test(home_team: team)

    get(
      '/player/attending_status_for_game',
      status: 'no', game_id: game.id, player_id: player.id
    )

    assert_equal "http://#{DOMAIN}/team/#{team.id}/index", last_response.location, 'redirect url'
    follow_redirect!
    assert last_response.ok?
    pg = PlayersGame.first(player_id: player.id, game_id: game.id)
    assert_equal('no', pg.status)
  end

  def test_can_attend_a_game
    player = Player.create_test(name: 'test user')
    game = Game.create_test

    player.set_attending_status_for_game(game, 'yes')

    pg = PlayersGame.first(player_id: player.id, game_id: game.id)
    assert_equal('yes', pg.status)
  end

  def test_can_update_info_via_post
    player = Player.create_test
    login(player, 'secret')
    post '/player/update', { name: 'new_name', id: player.id }
    assert_equal "http://#{DOMAIN}/player/#{player.id}/index", last_response.location
    assert_equal 'new_name', player.reload.name
  end

  def test_join_team_as_part_of_sign_up_process_works
    league = League.create_test
    div = Division.create_test(league_id: league.id)
    Team.create_test(name: 'team to find', division_id: div.id)
    Team.create_test(name: 'should not be found', division_id: div.id)

    get '/player/join_team'
    assert_match(/Done!/, last_response.body)
    assert(last_response.body !~ /team to find/, 'team to find')
  end

  def test_can_leave_a_team
    player = Player.create_test
    team = Team.create_test
    team2 = Team.create_test

    team.add_player(player)
    team2.add_player(player)

    login(player, 'secret')
    post '/players_team/delete', { team_id: team.id }
    follow_redirect!
    assert_match "You have successfully left #{team.name}", last_response.body

    pts = PlayersTeam.all
    assert_equal(1, pts.length)
    assert_equal(team2.id, pts[0].team_id)
  end

  def test_default_status
    player = Player.create_test
    game = Game.create_test
    assert_equal 'No Reply', player.attending_status(game)
    PlayersGame.create_test(player_id: player.id, game_id: game.id)
    assert_equal 'No Reply', player.attending_status(game)
  end

  def test_upcoming_teams_games
    player = Player.create_test
    team = Team.create_test
    team2 = Team.create_test
    not_on_team = Team.create_test
    player.add_team(team)
    player.add_team(team2)

    team.add_game(Game.create_test(date: Date.today + 2))
    team2.add_game(Game.create_test(date: Date.today))
    not_on_team.add_game(Game.create_test(date: Date.today + 1))

    assert_equal(
      [[team2, team2.games.first], [team, team.games.first]],
      player.upcoming_teams_games
    )
  end

  def test_coerces_player_id_from_request
    player = Player.create_test
    get "/player/index?id=#{player.id}"

    assert_match(
      %r{<title>Teamvite - profile for #{player.name}</title>},
      last_response.body
    )
  end

  def test_reminder_email
    player = Player.create_test
    team = Team.create_test
    player.add_team(team)
    game = Game.create_test date: Date.today + 1
    TeamsGame.create_test game_id: game.id, team_id: team.id
    get "/game_reminder_email?game_id=#{game.id}&player_id=#{player.id}"

    expected = %(<p>Dear test user,</p><p>This is your game reminder. The next game is:</p><blockquote>\t#{game.date.strftime(PickleSpears::DATE_FORMAT)} #{game.description}</blockquote>Can you make the game?<br /><a href="http://www.teamvite.com/player/attending_status_for_game?game_id=#{game.id}&amp;player_id=#{player.id}&amp;status=yes"> Yes</a><br /><a href="http://www.teamvite.com/player/attending_status_for_game?game_id=#{game.id}&amp;player_id=#{player.id}&amp;status=no"> No</a><br /><a href="http://www.teamvite.com/player/attending_status_for_game?game_id=#{game.id}&amp;player_id=#{player.id}&amp;status=maybe"> Maybe</a><p>Thank you for using Teamvite.com!</p>)

    assert_equal expected, last_response.body
  end
end
