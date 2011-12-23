require 'digest/md5'
require_relative 'team'
require_relative 'game'
require_relative 'players_game'
require_relative 'players_team'

class Player < Sequel::Model
  one_to_many :players_teams
  one_to_many :players_games
  many_to_many :teams, :join_table => :players_teams
  many_to_many :game, :join_table => :players_games

  def join_team(team)
    PlayersTeam.new(:player_id => self.id, :team_id => team.id).save
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
      :name => 'test user',
      :email_address => 'test_user@test.com'
    )
    player.update(attrs) if attrs
    player.save
    return player
  end

  def md5_email
    return Digest::MD5.hexdigest(email_address)
  end

  def fupdate(attrs)
    begin
      self.update(attrs)
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
