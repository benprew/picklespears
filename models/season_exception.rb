class SeasonException < Sequel::Model
  many_to_one :season
end
