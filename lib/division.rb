require 'db'
require 'rubygems'
gem 'activerecord'
require 'activerecord'

class Division < ActiveRecord::Base
  has_many :teams, :order => 'name'
  attr_accessor :file
end
