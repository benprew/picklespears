#!/usr/local/bin/ruby

require 'csv'

rows = CSV.read(ARGV[0]).map do |r|
  (date_str, home_team, away_team, division) = r

  date = DateTime.strptime(date_str, '%a %b %e %I:%M %p')

  [date, home_team, away_team, division]
end.sort { |a, b| a[0] <=> b[0] }

sorted = File.new('schedule.sorted.csv','w')

rows.each do |row|
  sorted.puts([row.shift.strftime('%a %b %e %I:%M %p'), row.flatten].join(","))
end
