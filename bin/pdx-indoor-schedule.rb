#!/usr/bin/env ruby

require 'open-uri'
require 'uri'
require 'set'

URL='http://pdxindoorsoccer.com/wp-content/schedules'

SEASONS = %w[
  spring
  summer
  1fall
  2fall
  winter
]

LEAGUES = %w[men women coed]
DIVISIONS = 1..6
SUBDIVISIONS = ['', 'A', 'B', 'C']

class BuildDb
  def initialize(season)
    raise "invalid season #{season}" unless SEASONS.include?(season)
    @@season_url = "#{URL}/#{season}"
  end

  def run
    fh = File.open('pi_games.txt', 'w')
    header = %i[league division home away time description]

    LEAGUES.each do |league|
      DIVISIONS.each do |division|
        SUBDIVISIONS.each do |sub_div|
          begin
            file = "/#{league}/DIV #{division}#{sub_div}.TXT"
            warn @@season_url + file
            url = URI.escape(@@season_url + file)
            open(url, read_timeout: 2) do |f|
              f.each do |line|
                line = _clean_line(line)
                data = _parse_schedule_line(line)
                next unless data
                data[:league] = league
                data[:division] = "#{league[0]}#{division}#{sub_div.downcase}"
                data[:description] = "#{data[:home]} vs #{data[:away]}"
                fh.puts header.map { |i| data[i] }.join("|")
              end
            end
          rescue OpenURI::HTTPError, Net::ReadTimeout
            warn "Error opening file #{file} : #{$!}"
          end
        end
      end
    end

    fh.close
  end

  def _parse_schedule_line(line)
    return unless line.match(/\w/)
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
      # warn "Unable to parse line" + line
      return nil
    end
  end

  def _clean_line(line)
    line.strip.gsub(/\s+/, ' ').upcase.gsub(/[^A-Z0-9:&!.\/ ]/, '')
  end

end

BuildDb.new(ARGV[0]).run();
