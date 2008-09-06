require 'rubygems'
require 'dm-core'
require 'player'
require 'team'

class PlayersTeam
  include DataMapper::Resource
  belongs_to :player
  belongs_to :team

  property :player_id, Integer, :key => true
  property :team_id, Integer, :key => true

  def self.create_test(attrs={})
    pt = PlayersTeam.new
    pt.update_attributes(attrs) if attrs
    return pt
  end
end

