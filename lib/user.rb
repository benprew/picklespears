class User
  attr_writer :name

  def initialize(name)
    @name = name
  end
  
  def logged_in?
    return false
  end

end
