require 'db'
require 'team'

class Division
  include DataMapper::Resource

  has n, :teams, :order => [:name.asc]

  property :id, Integer, :serial => true
  property :name, String
  property :league, String
  
  attr_accessor :file
end
