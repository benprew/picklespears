class Hash
  def slice(*keys)
    h = {}
    keys.each{|k| h[k] = self[k]}
    h
  end
end

