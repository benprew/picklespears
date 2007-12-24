require 'db_table'

class Team < DbTable
  attr_accessor :name, :division

  def initialize()
    @@table_filename = 'teams.o'
    super()
  end

  def eql?(other)
    @name == other.name
  end

  def hash
    @name.hash
  end

end
