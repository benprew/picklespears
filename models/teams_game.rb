require_relative 'team'
require_relative 'game'

class TeamsGame < Sequel::Model
  many_to_one :team
  many_to_one :game
end

