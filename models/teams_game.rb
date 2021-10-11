require_relative 'team'
require_relative 'game'

class TeamsGame < Sequel::Model
  unrestrict_primary_key

  many_to_one :team
  many_to_one :game

  def self.create_test(attrs = {})
    TeamsGame.new(attrs).save
  end
end
