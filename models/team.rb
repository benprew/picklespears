require 'date'

class Team < Sequel::Model
  many_to_one :division
  one_to_many :games
  one_to_many :players_teams
  many_to_many :players, join_table: :players_teams
  many_to_many :games, join_table: :teams_games

  def upcoming_games
    games.select{ |g| g.date.to_date >= Date.today() }.sort { |a, b| a.date <=> b.date }
  end

  def next_game
    upcoming_games.first
  end

  def self.create_test(attrs={})
    team = Team.new(:division_id => 1, :name => 'test team')
    team.save
    team.update(attrs) if attrs
    team.save
    return team
  end

  def add_player(player)
    super
    send_welcome_to_team_email(player)
  end

  def send_welcome_to_team_email(player)
    info = {
      to: player.email_address,
      subject: "Teamvite: You've been added to #{name}",
      message: "Teamvite here, just letting you know that you have been added to a new rec. sports team.  You can see the team here (http://teamvite.com)",
    }
  end
end
