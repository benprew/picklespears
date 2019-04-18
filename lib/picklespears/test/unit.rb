ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'tilt/haml'
require 'tilt/sass'
require 'capybara/dsl'
require 'picklespears'
require 'ostruct'

DB << open(File.dirname(__FILE__) + '/../../../db/create.sql', 'r').read
DOMAIN = 'example.org'
$VERBOSE=nil

Capybara.app = PickleSpears

class PickleSpears
  class Test
    class Unit < Minitest::Test

      include Rack::Test::Methods
      include Capybara::DSL

      def run(*args, &block)
        result = nil
        Sequel::Model.db.transaction(:rollback => :always) do
          Sequel::Model.db << "SET CONSTRAINTS ALL DEFERRED"
          result = super
        end
        # minitest 5.11+ #run needs to return a Result object
        return result
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
