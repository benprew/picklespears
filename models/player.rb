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
  many_to_many :teams, :join_table => :players_teams
  many_to_many :games, :join_table => :players_games
  many_to_many :leagues, join_table: :league_managers

  plugin :validation_helpers

  def validate
    super
    validates_presence [:name, :email_address]
    validates_unique :name
    validates_unique :email_address
#    validates_presence :password if new?
    errors.add :passwords, ' don\'t match' unless @password == @password_confirmation
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
    current_user = self.first(email_address: email)
    return nil if current_user.nil?
    return current_user if current_user.password_hash && BCrypt::Password.new(current_user.password_hash) == password
    nil
  end

  def set_attending_status_for_game(game, status)
    PlayersGame.unrestrict_primary_key
    PlayersGame.find_or_create(:player_id => self.id, :game_id => game.id){ |pg| pg.status = status }.save
    PlayersGame.restrict_primary_key
  end

  def attending_status(game)
    pg = PlayersGame.first(:player_id => self.id, :game_id => game.id)
    pg ? pg.status : "No Reply"
  end

  def is_on_team?(team)
    return PlayersTeam.first(:player_id => self.id, :team_id => team.id)
  end

  def self.create_test(attrs={})
    player = Player.new(
      name: 'test user',
      email_address: 'test_user@test.com',
      openid: 'test_user_id',
      password_hash: BCrypt::Password.create('secret'),
    )
    player.update(attrs) if attrs
    player.save
    return player
  end

  def md5_email
    return Digest::MD5.hexdigest(email_address)
  end

  def password_reset_link
    return "http://teamvite.com/player/reset/#{password_reset_hash}"
  end

  def is_league_manager?
    !leagues.empty?
  end

  def upcoming_teams_games
    teams_games = []
    teams.each do |t|
      teams_games += t.upcoming_games.map{ |g| [t, g] }
    end
    teams_games.sort{ |a, b| a[1].date <=> b[1].date }
  end
end
