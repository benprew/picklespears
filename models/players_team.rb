require_relative 'player'
require_relative 'team'

class PlayersTeam < Sequel::Model
  many_to_one :player
  many_to_one :team

  def self.create_test(attrs={})
    pt = PlayersTeam.new
    pt.save
    pt.update(attrs) if attrs
    return pt
  end
end
