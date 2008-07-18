require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
require 'team'

class Player < ActiveRecord::Base
  has_and_belongs_to_many :players

  def self.login( email_address, password )
    return Player.find(:find, :conditions => [ "email_address = ? AND password = ?", email_address, password ])
  end
end
