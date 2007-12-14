class Team
  attr_accessor :name, :division

  def eql?(other)
    @name == other.name
  end

  def hash
    @name.hash
  end
end
