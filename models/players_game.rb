require_relative 'team'
require_relative 'player'

class PlayersGame < Sequel::Model
  unrestrict_primary_key

  many_to_one :player
  many_to_one :game

  def self.create_test(attrs={})
    pg = PlayersGame.new
    pg.update(attrs) if attrs
    pg.save
    return pg
  end
end

