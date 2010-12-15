module RoundRobinSchedule

  def build_games(teams, matches_to_play)
    rounds = []
    games_per_team = Hash.new(0)

    _teams = []
    _teams.replace(teams)
    _teams << nil if _teams.length % 2

    while _teams.length > 1 do
      mid = _teams.length / 2
      top = _teams[0, mid]
      bottom = _teams[mid, _teams.length]
 
      round = (top.zip bottom).select { |g| !g.include? nil }
      rounds += [ round ]
      _teams = [ top.shift ] + _rotate_clockwise(top, bottom)

      round.each { |g| g.each { |t| games_per_team[t] += 1 } }
      _teams = _teams.select { |t| games_per_team[t] < matches_to_play }
      _teams = _teams.select { |t| t != nil } if _teams.length % 2 != 0
    end

    rounds
  end

  def _rotate_clockwise(top, bottom)
    top.unshift bottom.shift
    bottom.push top.pop
    top + bottom
  end
end
