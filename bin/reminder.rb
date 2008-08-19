#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../sinatra/lib'

require 'rubygems'
require 'dm-core'
require 'player'
require 'team'
require 'date'
require 'game'

class Reminder
  def self._send_email_about_game(team, game)
    warn "sending email about #{game.description}"
    team.players.each do |player|
      `wget http://picklespears.com/player/send_game_reminder?player_id=#{player.id};game_id=#{game.id}`
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
