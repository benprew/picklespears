class SeasonDayToAvoid < Sequel::Model(:season_days_to_avoid)
  unrestrict_primary_key

  many_to_one :season
  many_to_one :team
end
