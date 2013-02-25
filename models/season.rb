class Season < Sequel::Model
  one_to_many :games
  one_to_many :season_exceptions
  many_to_many :teams, join_table: :seasons_teams

  def leagues
    games.map { |g| g.teams.map{ |t| t.division.league } }.flatten.uniq
  end
end
