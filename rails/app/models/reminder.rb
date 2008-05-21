require 'player'
require 'team'
require 'date'
require 'game'

class Reminder < ActionMailer::Base
  def game_reminder(player, game)
    unless player.email_address then
      warn "no email addy for #{player.name}"
      return
    end
    recipients player.email_address
    from "ben.prew@throwingbones.com"
    subject "game reminder from pickle spears"
    body :user => player, :game => game
  end 

  def self._send_email_about_game(team, game)
    team.players.each do |player|
      Reminder.deliver_game_reminder(player, game)
    end
  end

  def self.run()
    Team.find_all.each do |team|
      next_game = team.next_unreminded_game()
      next if !next_game || next_game.date > Date.today() + 4
      _send_email_about_game(team, next_game)
      next_game.reminder_sent = 1
      next_game.save!
    end
  end

end
