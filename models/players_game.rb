require_relative 'team'
require_relative 'player'

class PlayersGame < Sequel::Model
  many_to_one :player
  many_to_one :game

  def self.create_test(attrs={})
    pg = PlayersGame.new
    PlayersGame.unrestrict_primary_key
    pg.update(attrs) if attrs
    PlayersGame.restrict_primary_key
    pg.save
    return pg
  end
end

