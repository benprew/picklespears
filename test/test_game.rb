require 'picklespears/test/unit'

class TestGame < PickleSpears::Test::Unit
  def setup
    super
    @game = Game.create_test(date: Time.now, description: 'test game')
    @game.away_team = Team.create_test
  end

  def test_num_guys_returns_the_number_of_guys_confirmed_for_game
    assert_equal(0, @game.num_guys_confirmed)
  end

  def test_home_and_away_team
    game = Game.create_test
    home_team = Team.create_test(name: 'test home team')
    away_team = Team.create_test(name: 'test away team')
    game.home_team = home_team
    game.away_team = away_team

    assert_equal away_team.name, game.away_team.name
    assert_equal home_team.name, game.home_team.name
  end

  def test_cannot_add_multiple_away_teams
    #    assert_equal ['test team'], @game.teams.map(&:name)
    new_away_team = Team.create_test(name: 'new away team')
    @game.away_team = new_away_team
    assert_equal ['new away team'], @game.teams.map(&:name)
  end

  def test_guys_confirmed_for_a_game
    player = Player.create_test(gender: 'guy', name: 'test player', email_address: 'none@none.com')
    PlayersGame.create_test(
      game_id: @game.id,
      player_id: Player.create_test.id,
      status: 'no'
    )
    pg = PlayersGame.create_test(
      game_id: @game.id,
      player_id: player.id,
      status: 'yes'
    )
    game = Game[pg.game_id]
    assert_equal(1, game.num_guys_confirmed)
    assert_equal(0, game.num_gals_confirmed)
  end

  def test_attending_status
    game = Game.create_test
    player = Player.create_test
    login(player, 'secret')
    post "/game/#{game.id}/attending_status", status: 'yes'

    assert last_response.ok?
  end
end
