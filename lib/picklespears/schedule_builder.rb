module ScheduleBuilder

  SCORE_FOR_GAME_ON_NON_PREFERRED_DAY = 20
  SCORE_FOR_EMPTY_GAME_TIME = 100
  SCORE_FOR_GAME_ON_REQUESTED_DAY_OFF = 10000
  # We don't want to give people too many 6:10 or midnight/11pm games, so we score those appropriately
  SCORE_FOR_CRAPPY_GAME_TIME = 10


  attr_reader :score_by_games

  def stats
    [ "No Stats" ]
  end

  def recombine(c2)
    return c2 # don't do recombination at this time
  end

  def fitness
    @score_by_games = calc_score_by_games unless @score_by_games
    return 1.0 / @score_by_games.reduce(1) { |sum, g| sum += g[1] }
  end

  # mutate - hueristic for picking best games to swap
  # mutate swaps a game around, but does not allow illegal states, such as 2 games in the same week, or a coed team playing in a time slot available only for mens/womens
  # mutate should only swap games in the half of the season that they're already in, so combine won't accidentally remove games
  def mutate
    # if there are no good games to swap, we've reached our ideal solution, so we do not want to mutate the chromosome
    return unless @score_by_games && @score_by_games.length > 0

    game_info = @score_by_games.max_by { |g| g[1] }

    if !index_for_date(game_info[0])
      @score_by_games = calc_score_by_games
      game_info = @score_by_games.max_by { |g| g[1] }
    end

    game_time_to_swap = game_info[0]
    swap_game_weeks(game_time_to_swap)

    # recompute fitness
    @score_by_games = calc_score_by_games
  end

  def calc_score_by_games
    team_crappy_games = Hash.new([])
    games_on_day = Hash.new([])
    games_score = []

    @games.each do |game|
      num_empty_games_before_game = @game_times.select { |empty| empty.date < game.date }.length
      games_score << [ game.date, (SCORE_FOR_EMPTY_GAME_TIME * num_empty_games_before_game) ] if num_empty_games_before_game > 0

      games_on_day[game.date.to_date] += [game]

      # TODO: Make these not hit the db, possibly store on team object itself
      games_score << [game.date,  SCORE_FOR_GAME_ON_NON_PREFERRED_DAY] if !game.team_ids.select { |t| !@season.preferred_days_for_team(Team[t]).include?(game.date.wday) }.empty?
      games_score << [game.date,  SCORE_FOR_GAME_ON_REQUESTED_DAY_OFF] if !game.team_ids.select { |t| @season.dates_to_avoid_for_team(Team[t]).include?(game.date.to_date) }.empty?

      game.team_ids.each do |t|
        if first_game_of_day?(game.date) || last_game_of_day?(game.date)
          team_crappy_games[t] += [[game.date, SCORE_FOR_CRAPPY_GAME_TIME]]
        end
      end
    end

    team_crappy_games.each { |k, v| v.shift; games_score += v }

    return games_score
  end
end
