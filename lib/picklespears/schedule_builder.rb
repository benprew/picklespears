class ScheduleBuilder

  SCORE_FOR_GAME_ON_NON_PREFERRED_DAY = 20
  SCORE_FOR_EMPTY_GAME_TIME = 1000
  SCORE_FOR_GAME_ON_REQUESTED_DAY_OFF = 100
  # We don't want to give people too many 6:10 or midnight/11pm games, so we score those appropriately
  SCORE_FOR_CRAPPY_GAME_TIME = 10


  attr_reader :schedule, :score_by_games

  def initialize(schedule)
    @schedule = schedule
  end

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

  # mutate swaps a game around, but does not allow illegal states, such as 2 games in the same week, or a coed team playing in a time slot available only for mens/womens
  # mutate should only swap games in the half of the season that they're already in, so combine won't accidentally remove games
  # mutate hueristic for picking best games to swap
  def mutate
    # if there are no good games to swap, we've reached our ideal solution, so we do not want to mutate the chromosome
    return unless @score_by_games && @score_by_games.length > 0

    game_time_to_swap = @score_by_games.max_by { |g| g[1] }[0]

    game_to_mutate = @score_by_games.max_by { |g| g[1] }
    if !@schedule.scheduled_times[game_to_mutate[0]].team_ids
      require 'pp'
      pp @score_by_games
      p game_to_mutate
      game2 = @schedule.scheduled_times[game_time_to_swap]
      pp game2
      pp @schedule.scheduled_times[game2.date]
      raise "Invalid date"
    end

    @schedule.swap_game_weeks(game_time_to_swap)

    # recompute fitness
    @score_by_games = calc_score_by_games
  end

  protected

  def calc_score_by_games
    team_crappy_games = Hash.new([])
    games_on_day = Hash.new([])
#    game_times_score = {}
    games_score = []

    empty_games = @schedule.empty_game_dates

    @schedule.games.each do |game|
      num_empty_games_before_game = @schedule.empty_game_dates.select { |empty| empty < game.date }.length
#      games_score += [[ game.date, (SCORE_FOR_EMPTY_GAME_TIME * num_empty_games_before_game) ]] if num_empty_games_before_game > 0
      games_score += [ [game.date, SCORE_FOR_EMPTY_GAME_TIME] ] if num_empty_games_before_game > 0

      # empty_games.each_index do |empty_game_index|
      #   if game.date > empty_games[empty_game_index]
      #     game_times_score[game.date] = SCORE_FOR_EMPTY_TIME
      #     empty_games.delete_at(empty_game_index)
      #   end
      # end

      games_on_day[game.date.to_date] += [game]

      # score += SCORE_FOR_GAME_ON_NON_PREFERRED_DAY if game.teams.select { |t| t.non_preferred_days.include?(game.date.wday) }
      # score += SCORE_FOR_GAME_ON_REQUESTED_DAY_OFF if game.teams.select { |t| t.excluded_dates.include?(game.date.to_date) }

      game.team_ids.each do |t|
        if @schedule.first_game_of_day?(game.date) || @schedule.last_game_of_day?(game.date)

          game2 = @schedule.scheduled_times[game.date]
          if !game2.team_ids
            p game
            p game2
            raise "Somethings wrong!"
          end

          team_crappy_games[t] += [[game.date, SCORE_FOR_CRAPPY_GAME_TIME]]
        end
      end
    end

    team_crappy_games.each { |k, v| v.shift; games_score += v }

    return games_score
  end
end
