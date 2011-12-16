#!/usr/bin/env ruby

require 'open-uri'
require 'set'

require_relative '../picklespears'

class BuildDb

  def initialize(url='http://pdxindoorsoccer.com/Schedules/secondfall/')
    @@season_url = url
  end

  def run
    outfile = File.new('pi_games.txt', 'w')
    Division.find_all().each do |division|
      file = division.name + ".txt"
      warn "working on #{file}"
      begin
        open(@@season_url + "/" + file) do |f|
          f.each do |line|
            line = _clean_line(line)
            data = _parse_schedule_line(line)
            next unless data
            outfile.write [division.league, division.name, data[:home], data[:away], data[:time], "#{data[:home]} vs #{data[:away]}"].join("|") + "\n"
          end
        end
      rescue OpenURI::HTTPError
        warn "Error opening file #{file} : #{$!}"
      end
    end
    outfile.close
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
      return {
        :home => m[5].strip,
        :away => m[6].strip,
        :time => Time.parse(m[1] + " " + m[2] + " #{hour} #{am_pm}")
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
