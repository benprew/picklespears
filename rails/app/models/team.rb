class Team < ActiveRecord::Base
  belongs_to :division
  has_many :games
  has_and_belongs_to_many :players

  def next_unreminded_game
  end
end
