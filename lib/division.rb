require 'rubygems'
require 'dm-core'
require 'team'

class Division
  include DataMapper::Resource

  has n, :teams, :order => [:name.asc]

  property :id, Integer, :serial => true
  property :name, String
  property :league, String
  
  attr_accessor :file

  def self.create_test(attrs={})
    division = Division.new( :name => 'test division' )
    division.update_attributes(attrs) if attrs
    division.save
    return division
  end
end
