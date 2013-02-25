class SeasonPreferredDay < Sequel::Model
  unrestrict_primary_key

  many_to_one :season
  many_to_one :team
end
