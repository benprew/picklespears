require 'player'

class Reminder < ActionMailer::Base
  def game_reminder(player, game)
    recipients player.email
    from "ben.prew@gmail.com"
    subject "game reminder from pickle spears"
    body :user => player, :game => game
  end 
end
