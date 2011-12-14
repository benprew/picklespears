require_relative 'team'
require_relative 'player'

class PlayersGame
  include DataMapper::Resource
  belongs_to :player
  belongs_to :game

  property :player_id, Integer, :key => true
  property :game_id, Integer, :key => true
  property :status, String

  def self.create_test(attrs={})
    pg = PlayersGame.new
    pg.save
    pg.update(attrs) if attrs
    pg.save
    return pg
  end
end

