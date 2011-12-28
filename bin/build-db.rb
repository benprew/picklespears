#!/usr/bin/env ruby

require 'open-uri'
require 'set'

require_relative '../picklespears'

class BuildDb

  def initialize(url='http://pdxindoorsoccer.com/Schedules/secondfall/')
    @@season_url = url
  end

  def run
    games = []

    Division.find_all().each do |division|
      file = division.name + ".txt"
      warn "working on #{file}"
      begin
        open(@@season_url + "/" + file) do |f|
          f.each do |line|
            line = _clean_line(line)
            data = _parse_schedule_line(line)
            next unless data
            data[:league] = division.league
            data[:division] = division.name
            data[:description] = "#{data[:home]} vs #{data[:away]}"
            games << data
          end
        end
      rescue OpenURI::HTTPError
        warn "Error opening file #{file} : #{$!}"
      end
    end

    File.open('pi_games.txt', 'w') do |f|
      f.puts *games.map { |g| [:league, :division, :home, :away, :time, :description].map { |i| g[i] }.join("|") }
    end
  end

  def _parse_schedule_line(line)
    return unless line.match /\w/
    m = /\w{3}\s+(\w{3})\s+(\d{1,2})\s+([0-9:]+|MIDNITE:?\d*|NOON:?\d*)\s*(AM|PM)?\s+(.*)VS(.*)/.match(line)
    if m && m[6]
      hour = m[3]
      am_pm = m[4]
      if hour == "NOON"
        hour = '12:00'
        am_pm = 'PM'
      end
      if hour == 'MIDNITE'
        hour = '11:59'
        am_pm = 'PM'
      end
      time = Time.parse(m[1] + " " + m[2] + " #{hour} #{am_pm}")
      # the Dec/Jan boundary without a year means we may try to create a jan game in the wrong year
      time = Time.mktime(time.year + 1, time.month, time.day, time.hour, time.min) if time.to_date < Date.today() - 120
      return {
        :home => m[5].strip,
        :away => m[6].strip,
        :time => time
      }
    else
      warn "Unable to parse line" + line
      return nil
    end
  end

  def _clean_line(line)
  	line.strip.gsub(/\s+/, ' ').upcase.gsub(/[^A-Z0-9:&!.\/ ]/, '')
  end

end

BuildDb.new().run();
