require_relative 'team'

class Division < Sequel::Model
  one_to_many :teams
  many_to_one :league

  def self.create_test(attrs={})
    division = Division.new( :name => 'test division', :league_id => 1 )
    division.save
    division.update(attrs) if attrs
    division.save
    return division
  end

  def teams_with_upcoming_games
    teams.select { |t| t.next_game }
  end
end
