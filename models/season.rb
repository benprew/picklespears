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

  def self.games_args(params)
    season = Season[params[:id]]
    division = Division[params[:division_id]]
    games = Game.where( id: DB[%q{ SELECT g.id FROM games g
      INNER JOIN teams_games tg ON (g.id = tg.game_id)
      INNER JOIN teams t on (tg.team_id = t.id)
      WHERE g.season_id = ? AND t.division_id = ?
      GROUP BY g.id }, season.id, division.id]).sort{ |a, b| a.date <=> b.date }

    return { games: games }
  end
end
