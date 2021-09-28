require_relative 'team'

class Division < Sequel::Model
  one_to_many :teams
  many_to_one :league

  def self.create_test(attrs = {})
    division = Division.new(name: 'test division', league_id: 1)
    division.save
    if attrs
      division.update(attrs)
      division.save
    else
      division
    end
  end

  def teams_with_upcoming_games
    teams.select { |t| t.next_game }
  end

  def self.divisions(params)
    Division.order(:name).all.select { |d| d.teams_with_upcoming_games.length > 0 }
  end

  def self.index_args(params)
    division = Division[params[:id]]
    games = Game.where(teams: Team.where(division_id: division.id)).where { date >= Date.today }.order(:date).map { |g| [ g.teams.first, g ] }
    { 'division': division, 'divisions': self.divisions(params), 'division_games': games }
  end

  def self.list_args(params)
    { 'divisions': self.divisions(params) }
  end
end
