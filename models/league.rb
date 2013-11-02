require_relative 'division'

class League < Sequel::Model
  one_to_many :divisions

  def divisions_with_upcoming_games
    divisions.select { |d| d.teams_with_upcoming_games.length > 0 }
  end

  def self.create_test(attrs = {})
    league = League.new(name: 'test league')
    league.save
    league.update(attrs) if attrs
    league.save
  end
end
