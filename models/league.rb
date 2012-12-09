require_relative 'division'

class League < Sequel::Model
  one_to_many :divisions
end
