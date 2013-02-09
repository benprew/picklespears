require 'time'

class Schedule

  GAME_LENGTH_IN_MINUTES = 50

  attr :time_slots, :current_week, :game_times, :scheduled_times

  def initialize(season_start_date, time_slots)
    @time_slots = time_slots
    @current_week = season_start_date
    @game_times = build_for_week(@current_week)
    @max_games_for_day = Hash.new(0)
    @scheduled_times = {}
  end

  def games
    @scheduled_times.select { |k, v| v.team_ids }.sort_by { |arr| arr[0] }.map{ |a| game = a[1]; game.date = a[0]; game }
  end

  def first_game_of_day?(date)
    slot = slot_for_day(date)

    date.strftime("%H:%M") == slot[:slot_info].first_game_time
  end

  def last_game_of_day?(date)
    # special case for midnight games
    date -= 1 if date.strftime('%H:%M') == '00:00'

    slot = slot_for_day(date)

    time = Time.strptime("#{date.to_date} #{slot[:slot_info].first_game_time} GMT", '%Y-%m-%d %H:%M %Z').utc
    date == time + (60 * Schedule::GAME_LENGTH_IN_MINUTES * slot[:slot_info].num_games)
  end

  def next_for_week(week, game)
    raise "One or more teams are already playing in week: #{week}" if !same_week?(week, game.date) && teams_have_game_this_week(week.strftime('%W'), game.team_ids)
    game_time = @game_times.select { |gt| same_week?(week, gt.date.to_date) && gt.league_ids.include?(game.league_id) }.first
    game_time && game_time.date
  end

  def same_week?(week1, week2)
    week1.strftime('%W') == week2.strftime('%W')
  end

  def add_game!(game)
    @scheduled_times[self.next(game.team_ids, game.league_id)] = game.dup
  end

  def next(team_pairing, league_id)
    if @game_times.length < 1
      @current_week += 7
      @game_times = build_for_week(@current_week)
      @game_times.each { |gt| raise "Duplicate time" if @scheduled_times[gt.date]; @scheduled_times[gt.date] = gt }
    end

    game_time_index = nil
    while (!game_time_index) do
      @game_times.each_index do |i|
        week_no = @game_times[i].date.strftime('%W')
        if @game_times[i].league_ids.include?(league_id) && !teams_have_game_this_week(week_no, team_pairing)
          game_time_index = i
          break
        end
      end
      if !game_time_index
        @current_week += 7
        new_times = build_for_week(@current_week)
        new_times.each { |gt| raise "Duplicate time: #{gt.date} keys: #{@scheduled_times.keys}" if @scheduled_times[gt.date]; @scheduled_times[gt.date] = gt }
        @game_times += new_times
      end
    end

    @game_times.delete_at(game_time_index).date
  end

  def max_games_for_day(day)
    if @max_games_for_day[day] == 0
      build_for_week(day - (day.cwday - 1)).each do |time|
        @max_games_for_day[time.game_date.to_date] += 1
      end
    end
    @max_games_for_day[day]
  end

  def add_scheduled_exception
    raise "TODO: Not implemented"
  end

  private

  def slot_for_day(date)
    @time_slots.select{ |slot| slot[:slot_info].cwday == (date.wday + 1) }.first
  end

  def teams_have_game_this_week(week_no, teams)
    !@scheduled_times.select { |k, v| v.team_ids && k.strftime('%W') == week_no && !(v.team_ids & teams).empty? }.empty?
  end

  def build_for_week(week)
    @time_slots.map do |slot_hash|
      day = slot_hash[:slot_info]
      league_ids = slot_hash[:league_ids]
      build_game_times(week, day.cwday - 1, day.num_games, day.first_game_time, league_ids)
    end.flatten
  end

  def build_game_times(week_start, weekday_offset, num_games_for_day, first_game_time, league_ids, game_length_in_minutes=50)
    start_date = week_start + weekday_offset
    num_games_for_day -= 1
    return (0..num_games_for_day).map do |i|
      time = Time.strptime("#{start_date} #{first_game_time} GMT", '%Y-%m-%d %H:%M %Z').utc
      OpenStruct.new({
          date: time + (60 * game_length_in_minutes * i),
          league_ids: league_ids,
      })
    end
  end

#### FROM SCHEDULE_BUILDER

  def swappable?(game1, game2)
    in_scheduled_time?(game1, game2) && !other_games_in_week?(game1, game2.date.to_date - game2.date.wday)
  end

  def in_scheduled_time?(game1, game2)
    game2_time = game2.date.strftime("%H:%M")
    return @schedule.time_slots.select do |slot|
      sd = slot[:slot_info]
      slot[:league_ids].include?(game1.league_id) && slot[:league_ids].include?(game2.league_id) &&
      (0..sd.num_games).map { |i| add_num_games_to_start_time(sd.first_game_time, i).strftime("%H:%M") }.include?(game2_time) &&
      sd.cwday == game2.date.cwday
    end
  end

  def add_num_games_to_start_time(first_game_time, games_to_add)
    game_length_in_minutes = 50
    dt = DateTime.strptime("#{first_game_time}", '%H:%M')
    time = dt.to_time
    time + (60 * game_length_in_minutes * games_to_add)
  end

  def other_games_in_week?(game, week)
    # if we are looking at the same week as this game, we can swap them
    return false if game.date.to_date - game.date.wday == week

    game.team_ids.each do |team_id|
      @games.each do |g|
        next unless g.date.to_date - g.date.wday == week
        return true if g.team_ids.include?(team_id)
      end
    end

    return false
  end

  # swaps the game weeks, choosing the first available time in that
  # week for the game, this compresses the schedule and means that a
  # single mutation can remove a game following an empty game day,
  # instead of multiple mutations if we did a strict datetime swap
  def swap_game_weeks(game_index, range)
    other_game_index = nil

    # this should include available slots, as we will want to swap into an empty slot as often as possible
    (@schedule.game_times + @games.shuffle).each do |slot|
      if @schedule.swappable?(@games[game_index], slot)
        other_game_index = slot?
        break
      end
    end

    raise "Could not find a game to swap for #{@games[game_index]}" unless other_game_index

    # schedule has a list of game_times that it hasn't used, so we can ask it for the next game
    # swap needs to swap position AND game dates, not either/or
    new_other_time =
      [@schedule.next_for_week(@games[game_index].date, @games[other_game_index]), @games[game_index].date].delete_if { |o| o == nil }.min

    if new_other_time != @games[game_index].date
      # puts "other: #{@games[other_game_index]} new time: #{new_other_time}"
      # puts "game1: #{@games[game_index]}"
      prior_len = @schedule.game_times.length
      @schedule.game_times.reject! { |gt| gt.game_date == new_other_time }
      raise "Did not delete #{new_other_time} from #{@schedule.game_times}" if prior_len == @schedule.game_times.length
    else
      # puts "# game times: #{@schedule.game_times.length}"
    end

    # this is a little hinky, but should be fine after game swap
    @games[game_index].date = new_other_time

    swap_game!(game_index, other_game_index)
  end

  def swap_game!(game1_index, game2_index)

    game1 = @games[game1_index]
    game2 = @games[game2_index]

    # swap dates
    tmp_date = @games[game1_index].date
    @games[game1_index].date = @games[game2_index].date
    @games[game2_index].date = tmp_date

    # swap locations
    @games[game2_index] = game1
    @games.delete_at(game1_index)

    # insert in the correct position, TODO: use bsearch if slow
    index_to_reinsert = -1
    @games.each_index do |i|
      if @games[i].date > game2.date
        puts "#{@games[i].date} #{game2.date}"
        index_to_reinsert = i
        break
      end
    end

    @games.insert(index_to_reinsert, game2)
  end

end
