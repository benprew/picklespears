class Season < Sequel::Model
  one_to_many :games
  one_to_many :season_exceptions
  many_to_many :teams, join_table: :seasons_teams
  one_to_many :season_days_to_avoid
  one_to_many :season_preferred_days

  def leagues
    games.map { |g| g.teams.map{ |t| t.division.league } }.flatten.uniq
  end

  def preferred_days_for_team(team)
    SeasonPreferredDay.where(season_id: id, team_id: team.id)
  end

  def dates_to_avoid_for_team(team)
    SeasonDayToAvoid.where(season_id: id, team_id: team.id)
  end
end
