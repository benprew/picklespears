require 'date'
require 'db'
require 'rubygems'
require 'activerecord'
require 'game'
require 'division'
require 'player'

class Team < ActiveRecord::Base
  belongs_to :division
  has_many :games
  has_and_belongs_to_many :players

  def next_unreminded_game
    games.select { |g| g.date >= Date.today() }.select { |g| !g.reminder_sent }[0]
  end

  def upcoming_games
    games.select { |x| x.date >= Date.today() }.sort { |a, b| a.date <=> b.date }
  end

  def next_game
    return upcoming_games[0]
  end
end
