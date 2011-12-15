require_relative 'player'
require_relative 'team'

class PlayersTeam
  include DataMapper::Resource
  belongs_to :player
  belongs_to :team

  property :player_id, Integer, :key => true
  property :team_id, Integer, :key => true

  def self.create_test(attrs={})
    pt = PlayersTeam.new
    pt.save
    pt.update(attrs) if attrs
    return pt
  end
end

