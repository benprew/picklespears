require_relative 'team'

class Division
  include DataMapper::Resource

  has n, :teams, :order => [:name.asc]

  property :id, Serial
  property :name, String
  property :league, String

  attr_accessor :file

  def self.create_test(attrs={})
    division = Division.new( :name => 'test division' )
    division.save
    division.update(attrs) if attrs
    division.save
    return division
  end
end
