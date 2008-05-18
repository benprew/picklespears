require 'date'

class Team < ActiveRecord::Base
  belongs_to :division
  has_many :games
  has_and_belongs_to_many :players

  def next_unreminded_game
    games.grep { |g| g.date >= Date.today() }.grep { |g| !g.reminder.sent }[0]
  end
end
