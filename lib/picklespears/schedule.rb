require 'time'
require 'set'

class Schedule

  GAME_LENGTH_IN_MINUTES = 50

  attr :time_slots, :current_week, :game_times, :games, :season

  def initialize(season, time_slots)
    @time_slots = time_slots
    @current_week = season.start_date
    @game_times = []
    @max_games_for_day = Hash.new(0)
    @games = []
    @team_weeks = Hash.new(Set.new)
    @season = season
  end

  def export_to_file(filename)
    File.open(filename, 'w') do |file|
      schedule.games.each do |game|
        file.puts [game.date.strftime(PickleSpears::DATE_FORMAT), game.team_ids.map { |id| Team[id].name }.flatten(1), Team[game.team_ids[0]].division.name ].join ","
      end
    end
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

  def next_for_week(date, game)
    raise "One or more teams are already playing in week: #{date}" if !same_week?(date, game.date) && teams_have_game_this_week(date, game.team_ids)
    game_time = @game_times.index { |gt| same_week?(date, gt.date) && gt.league_ids.include?(game.league_id) }
    return @game_times.delete_at(game_time) if game_time
  end

  def same_week?(week1, week2)
    week1.strftime('%W') == week2.strftime('%W')
  end

  def add_game!(game)
    game_time = self.next(game.team_ids, game.league_id)
    game_time.team_ids = game.team_ids
    game_time.league_id = game.league_id
    @team_weeks[game_time.date.strftime('%W')] += game.team_ids
    @games << game_time
  end

  def next(team_pairing, league_id)
    if @game_times.length < 1
      @current_week += 7
      @game_times = build_for_week(@current_week)
    end

    game_time_index = nil
    while (!game_time_index) do
      @game_times.each_index do |i|
        if @game_times[i].league_ids.include?(league_id) && !teams_have_game_this_week(@game_times[i].date, team_pairing)
          game_time_index = i
          break
        end
      end
      if !game_time_index
        @current_week += 7
        @game_times += build_for_week(@current_week)
      end
    end

    @game_times.delete_at(game_time_index)
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

  def index_for_date(date)
    @games.index { |g| g.date == date }
  end

  def game_for_date(date)
    @games[index_for_date(date)]
  end

  # swaps the game weeks, choosing the first available time in that
  # week for the game, this compresses the schedule and means that a
  # single mutation can remove a game following an empty game day,
  # instead of multiple mutations if we did a strict datetime swap
  def swap_game_weeks(game1_date)
    game1_index = index_for_date(game1_date)
    game2_index = nil

    # this is bad, we should be looking for games that will swap into
    # another week and fill an empty slot, not just swapping for empty
    # slots
    (0..@games.length - 1).to_a.shuffle.each do |index|
      warn "game1 index is null" unless game1_index
      warn "index is null" unless index
      if swappable?(@games[game1_index], @games[index])
        game2_index = index
        break
      end
    end

    raise "Could not find a game to swap for #{@games[game1_index]}" unless game2_index

    # schedule has a list of game_dates that it hasn't used, so we can ask it for the next game
    # swap needs to swap position AND game dates, not either/or
    new_other_slot =
      [next_for_week(@games[game1_index].date, @games[game2_index]), @games[game1_index]].delete_if { |o| o == nil }.min_by{ |t| t.date }

    # this is a little hinky, but should be fine after game swap
    if new_other_slot.date != @games[game1_index].date
      # puts "other: #{@games[other_game_index]} new date: #{new_other_date}"
      # puts "game1: #{@games[game_index]}"
      game = @games[game1_index]
      @games[game1_index] = OpenStruct.new( date: new_other_slot.date, league_ids: new_other_slot.league_ids, team_ids: game.team_ids )
      @game_times << OpenStruct.new( date: game.date, league_ids: game.league_ids )
    end

    swap_games!(game1_index, game2_index)
  end

  private

  def game_week_no(game)
    game.date.strftime('%W')
  end

  def slot_for_day(date)
    @time_slots.select{ |slot| slot[:slot_info].cwday == (date.wday + 1) }.first
  end

  def teams_have_game_this_week(date, teams)
    !(@games.select { |g| game_week_no(g) == date.strftime('%W') && g.date != date }.map { |g| g.team_ids }.flatten & teams).empty?
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

  def swappable?(game1, game2)
    game1 != game2 &&
      in_scheduled_time?(game1, game2) &&
      !teams_have_game_this_week(game2.date, game1.team_ids) &&
      !teams_have_game_this_week(game1.date, game2.team_ids)
  end

  def in_scheduled_time?(game1, game2)
    game2_time = game2.date.strftime("%H:%M")
    return @time_slots.select do |slot|
      sd = slot[:slot_info]
      game2_cwday = game2.date.wday
      game2_cwday = 7 if game2_cwday == 0

      slot[:league_ids].include?(game1.league_id) && slot[:league_ids].include?(game2.league_id) &&
      (0..sd.num_games).map { |i| add_num_games_to_start_time(sd.first_game_time, i).strftime("%H:%M") }.include?(game2_time) &&
      sd.cwday == game2_cwday
    end
  end

  def add_num_games_to_start_time(first_game_time, games_to_add)
    game_length_in_minutes = 50
    dt = DateTime.strptime("#{first_game_time}", '%H:%M')
    time = dt.to_time
    time + (60 * game_length_in_minutes * games_to_add)
  end

  def swap_games!(game1_index, game2_index)
    # league ids is property of the date slot, not of the teams playing
    tmp_league_ids = @games[game1_index].league_ids
    @games[game1_index].league_ids = @games[game2_index].league_ids
    @games[game2_index].league_ids = tmp_league_ids

    # league ids is property of the date slot, not of the teams playing
    tmp_date = @games[game1_index].date
    @games[game1_index].date = @games[game2_index].date
    @games[game2_index].date = tmp_date

    tmp_game = @games[game1_index]
    @games[game1_index] = @games[game2_index]
    @games[game2_index] = tmp_game
  end
end
