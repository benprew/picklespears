require 'rubygems'
require 'dm-core'
require 'team'
require 'game'
require 'players_game'
require 'players_team'

class Player
  include DataMapper::Resource

  has n, :players_teams
  has n, :teams, :through => :players_teams
  has n, :players_games
  has n, :games, :through => :players_games

  property :id, Integer, :serial => true
  property :name, String, :nullable => false, :index => :unique
  property :email_address, String, :nullable => false, :index => :unique
  property :phone_number, String
  property :is_sub, Boolean
  property :password, String, :nullable => false
  property :birthdate, String
  property :zipcode, String
  property :gender, String
  property :image, Object

  def self.login( email_address, password )
    return Player.first(:email_address => email_address, :password => password)
  end

  def join_team(team)
    PlayersTeam.new(:player_id => self.id, :team_id => team.id).save
  end

  def set_attending_status_for_game(game, status)
    pg = PlayersGame.first(:player_id => self.id, :game_id => game.id) || PlayersGame.new(:player_id => self.id, :game_id => game.id)

    pg.update_attributes(:status => status)
    pg.save
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
      :name => 'test user',
      :email_address => 'test_user@test.com',
      :password => 'test'
    )
    player.attributes = attrs if attrs
    player.save
    return player
  end

  def fupdate(attrs)
    if attrs[:password] == ''
      attrs.delete('password')
      attrs.delete(:password)
    end

    if attrs[:password] && (attrs[:password] != attrs[:password2])
      raise "Passwords do not match"
    end

    attrs.delete('password2')
    attrs.delete(:password2)

    begin
      self.update_attributes(attrs)
    rescue StandardError => err
      if /Duplicate entry/.match(err)
        raise "Player name '#{attrs[:name]}' already exists, please choose another"
      elsif /may not be/.match(err)
        raise err
      else
        raise "Unknown error occured, please contact 'ben.prew@gmail.com' #{err}"
      end
    end

    return true
  end

end
