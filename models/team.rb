require 'date'

class Team < Sequel::Model
  many_to_one :division
  one_to_many :games
  one_to_many :players_teams
  many_to_many :players, join_table: :players_teams
  many_to_many :games, join_table: :teams_games

  def upcoming_games
    games.select { |g| g.date.to_date >= Date.today }.sort { |a, b| a.date <=> b.date }
  end

  def next_game
    upcoming_games.first
  end

  def self.create_test(attrs = {})
    team = Team.new(division_id: 1, name: 'test team')
    team.save
    team.update(attrs) if attrs
    team.save
    team
  end

  def add_player(player)
    super
    send_welcome_to_team_email(player)
  end

  def send_welcome_to_team_email(player)
    {
      to: player.email_address,
      subject: "Teamvite: You've been added to #{name}",
      message: "Teamvite here, just letting you know that you have been added to a new rec. sports team.  You can see the team here (http://#{APP_DOMAIN})"
    }
  end

  def self.fuzzy_find(division, team_name, force_create = false)
    teams = Team.where(name: team_name).all.reject do |t|
      t.division.league != division.league
    end

    raise "ERR: too many teams name: #{team_name} teams: #{teams.map(&:name)}" if
      teams.length > 1

    if teams.length == 0
      if force_create
        warn "Creating Team: #{team_name}"
        Team.create(name: team_name, division_id: division.id)
      else
        raise "ERR: no team for #{team_name} #{division.name}" unless @force_team_create
      end
    else
      team = teams.first
      if team.division != division
        warn "MOV: team: #{team.name} from: #{team.division.name} to: #{division.name}"
        team.division = division
        team.save
      end
      teams.first
    end
  end

  def self.search_args(params)
    teams = []
    if params[:team]
      query = params[:team]
      teams = Team.filter(Sequel.like(:name, '%' + params[:team].upcase + '%')).order(Sequel.asc(:name)).all
    end

    { teams: teams, query: query }
  end

  def self.create_args(params)
    season = Season[params[:season_id]]
    { season: season }
  end
end
