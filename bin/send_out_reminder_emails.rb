#!/usr/local/ruby/bin/ruby

require 'team'
require 'date'
require 'reminder'

class ReminderRunner
  def _send_email_about_game(team, game)
    team.players.each do |player|
      Reminder.deliver_game_reminder(player, game)
    end
  end

  def run
    Team.find_all.each do |team|
      next_game = team.next_unreminded_game()
      next if next_game.date > Date.today() + 4
      _send_email_about_game(team, game)
      next_game.reminder_sent = 1
      next_game.save!
    end
  end
end

reminder_runner = ReminderRunner.new
reminder_runner.run

