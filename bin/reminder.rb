#!/usr/bin/env ruby

require 'player'
require 'team'
require 'date'
require 'game'
require 'sinatra'
require 'sinatra/test/methods'
require 'pickle-spears'

class Reminder
  def self._send_email_about_game(team, game)
    warn "sending email about #{game.description}"
    team.players.each do |player|
      get_it '/player/send_game_reminder', 'player_id=#{player.id};game_id=#{game.id}'
    end
  end

  def self.run()
    Team.all.each do |team|
      next_game = team.next_unreminded_game()
      next if !next_game || next_game.date <= Date.today() + 4
      _send_email_about_game(team, next_game)
      next_game.reminder_sent = 1
      next_game.save
    end
  end
end
