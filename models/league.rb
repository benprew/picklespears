require_relative 'division'

class League < Sequel::Model
  one_to_many :divisions

  def self.create_test(attrs={})
    league = League.new( :name => 'test league' )
    league.save
    league.update(attrs) if attrs
    league.save
    return league
  end
end
