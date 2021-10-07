# frozen_string_literal: true

require 'digest/md5'
require_relative 'team'
require_relative 'game'
require_relative 'players_game'
require_relative 'players_team'
require_relative 'league'

class Player < Sequel::Model
  attr_writer :password_confirmation

  one_to_many :players_teams
  one_to_many :players_games
  many_to_many :teams, join_table: :players_teams
  many_to_many :games, join_table: :players_games
  many_to_many :leagues, join_table: :league_managers

  plugin :validation_helpers

  def validate
    super
    validates_presence %i[name email_address]
    validates_unique :name
    validates_unique :email_address
    #    validates_presence :password if new?
    errors.add :passwords, ' don\'t match' if @password != @password_confirmation
  end

  def send_welcome_email
    true
    # TODO
  end

  def password=(pass)
    @password = pass
    self.password_hash = BCrypt::Password.create(@password)
  end

  def self.authenticate(email, password)
    current_user = first(email_address: email)
    if current_user.nil?
      nil
    elsif current_user.password_hash && BCrypt::Password.new(current_user.password_hash) == password
      current_user
    end
  end

  def set_attending_status_for_game(game, status)
    pg = PlayersGame.find_or_create(player_id: id, game_id: game.id)
    pg.status = status
    pg.save
  end

  def attending_status(game)
    pg = PlayersGame.first(player_id: id, game_id: game.id)
    pg&.status || 'No Reply'
  end

  def is_on_team?(team)
    PlayersTeam.first(player_id: id, team_id: team.id)
  end

  def self.create_test(attrs = {})
    player = Player.new(
      name: 'test user',
      email_address: 'test_user@test.com',
      openid: 'test_user_id',
      password_hash: BCrypt::Password.create('secret')
    )
    player.save
    player.update(attrs) if attrs
    player.save
  end

  def md5_email
    Digest::MD5.hexdigest(email_address)
  end

  def password_reset_link
    "http://#{APP_DOMAIN}/player/reset/#{password_reset_hash}"
  end

  def is_league_manager?
    !leagues.empty?
  end

  def upcoming_teams_games
    teams_games = []
    teams.each do |t|
      teams_games += t.upcoming_games.map { |g| [t, g] }
    end
    teams_games.sort { |a, b| a[1].date <=> b[1].date }
  end

  def self.join_team_args(params)
    teams = []
    if params[:team]
      teams = Team.filter(Sequel.ilike(:name, "%#{params[:team]}%"))
                  .order(Sequel.asc(:name))
                  .all
    end
    { teams: teams }
  end
end
