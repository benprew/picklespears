#!/usr/bin/env ruby

require 'picklespears/test/unit'

class TestSeason < PickleSpears::Test::Unit
  def setup
    @season = Season.create(name: 'Winter 2013', start_date: Date.new(2013,11,01))
  end

  def test_season_index
    get '/season', season_id: @season.id

    assert last_response.ok?
  end

  def test_season_list
    get '/season'
    follow_redirect!

    assert_equal "http://#{DOMAIN}/season/list", last_request.url
    assert last_response.ok?
    assert_match /#{@season.name}/, last_response.body
  end

  def test_season_create
    visit '/season/create'
    fill_in :name, with: 'New Season'
    fill_in :start_date, with: '2013-05-25'
    click_button 'Next'

    assert_equal Date.new(2013,5,25), Season.where(name: 'New Season').first.start_date
  end

  def test_get_season_edit
    get '/season/edit', season_id: @season.id
    assert last_response.ok?
  end

  def test_season_edit
    visit "/season/edit?season_id=#{@season.id}"
    fill_in :name, with: 'Winter Cup 2013'
    click_button 'Update'

    @season.reload
    assert_equal 'Winter Cup 2013', @season.name
  end

  def test_season_exception_day
    visit "/season/edit?season_id=#{@season.id}"

    within(:xpath, "//form[@action='/season/add_exception_day']") do
      fill_in :date, with: '2013-05-25'
      click_button 'Add'
    end

    assert_equal [ Date.new(2013,5,25) ], @season.season_exceptions.map(&:date)
  end

  def test_season_add_league
    league = League.create_test
    division = Division.create_test(name: 'Test Division', league: league)
    team = Team.create_test(division: division)
    game = Game.create_test
    game.add_team(team)

    visit "/season/edit?season_id=#{@season.id}"
    select league.name, from: :league_id
    click_button 'Add All Teams in League'

    assert_equal [ team ], @season.teams
  end

  def test_team_create
    division = Division.create_test(name: 'Test Division')
    team = Team.create_test(division: division)
    game = Game.create_test
    game.add_team(team)

    visit "/season/create_team?season_id=#{@season.id}"
    fill_in :name, with: 'A new Team'
    select 'Test Division', from: :division_id
    click_button 'Create Team'

    assert_equal Team.where(name: 'A new Team').all, @season.teams
  end
end
