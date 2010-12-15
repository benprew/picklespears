#!/usr/bin/env ruby

require 'picklespears/test/unit'
require 'picklespears/round_robin_schedule'

class TestScheduler < PickleSpears::Test::Unit

  include RoundRobinSchedule

  def test_nine_teams_eight_games
    teams = (1..9).map { |i| "t #{i}" }
    rounds = build_games teams, 8

    assert_equal 9, rounds.length

    teams.each do |team|
      assert_equal 8, _games(team, rounds).length

      teams.each do |t2|
        assert_equal(1, _pairings(t2, team, rounds).length, "#{team}, #{t2}") if team != t2
      end
    end

  end

  def test_three_teams_eight_games
    teams = (1..3).map { |i| "t #{i}" }
    rounds = build_games(teams, 8)

    assert_equal 12, rounds.length

    teams.each do |team|
      assert_equal 8, _games(team, rounds).length, "team: #{team}"
      if team != teams[0]
        assert_equal 4, _pairings(teams[0], team, rounds).length
      end
    end

  end

  def test_twenty_teams_eight_games
    teams = (1..20).map { |i| "t #{i}" }
    rounds = build_games teams, 8

    assert_equal 8, rounds.length

    teams.each do |team|
      assert_equal 8, _games(team, rounds).length, "team: #{team}"

      teams.each do |t2|
        assert((0..1).include?(_pairings(t2, team, rounds).length), "#{team}, #{t2}") if team != t2
      end

    end

  end

  def test_twenty_one_teams_ten_games
    teams = (1..21).map { |i| "t #{i}" }
    rounds = build_games teams, 10

    assert_equal 11, rounds.length

    teams.each do |team|
      assert_equal 10, _games(team, rounds).length, "team: #{team}"

      teams.each do |t2|
        assert((0..1).include?(_pairings(t2, team, rounds).length), "#{team}, #{t2}") if team != t2
      end
    end
  end

  def test_rounds_needed_for_eight_games
    rounds_needed_for_odd_numbers = Hash[ 3 => 12, 5 => 10, 7 => 10 ]
    games = 8
    (2..55).each do |i|
      teams = (1..i).map { |j| "t #{j}" }
      if i % 2 == 0
        assert_equal 8, build_games(teams, 8).length
      else
        assert_equal rounds_needed_for_odd_numbers[i] || 9, build_games(teams, 8).length
      end
    end
  end

  def test_invalid_input
    assert_raises RuntimeError, LoadError do
      build_games([ 'team 1' ], 0)
    end

    assert_raises RuntimeError, LoadError do
       build_games(['team 1'], 3)
    end

    assert_raises RuntimeError, LoadError do
       build_games([], 3)
    end
    assert_raises RuntimeError, LoadError do
       build_games(nil, 3)
    end
  end

  def _pairings(team1, team2, rounds)
    pairing = [ team1, team2 ].sort

    rounds.inject([]) do |pairings, round|
      pairings + round.select { |g| g if g.sort == pairing }
    end
  end

  def _games(team, rounds)
    rounds.inject([]) do |games, round|
      games + round.select { |g| team if g.include?(team) }
    end
  end


end

