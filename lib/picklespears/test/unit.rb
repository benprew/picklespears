ENV['RACK_ENV'] = 'test'
if ENV['DATABASE_URL'] !~ /test$/
  test_db_url = ENV['DATABASE_URL'] + 'test'
  warn "Setting DATABASE_URL to #{test_db_url}"
  ENV['DATABASE_URL'] = test_db_url
end

require 'ostruct'

require 'minitest/autorun'
require 'minitest/hooks/test'
require 'rack/test'
require 'tilt/sass'
require 'sequel'
require 'capybara/dsl'

require 'picklespears'

warn 'creating test database schema'
DB << open(File.dirname(__FILE__) + '/../../../db/create.sql', 'r').read

DOMAIN = 'teamvite.home.arpa'.freeze
$VERBOSE = nil

Capybara.app = PickleSpears

module Rack
  module Test
    DEFAULT_HOST = DOMAIN
  end
end

class PickleSpears
  class Test
    class Unit < Minitest::Test
      include Rack::Test::Methods
      include Capybara::DSL
      include Minitest::Hooks

      def around
        DB.transaction(rollback: :always) do
          Sequel::Model.db << 'SET CONSTRAINTS ALL DEFERRED'
          super
        end
      end

      def app
        PickleSpears
      end

      def login(player, password)
        post '/player/login', email_address: player.email_address, password: password
      end
    end
  end
end
