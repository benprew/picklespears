ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'tilt/haml'
require 'tilt/sass'
require 'capybara'
require 'picklespears'
require 'ostruct'

DB << open(File.dirname(__FILE__) + '/../../../db/create.sql', 'r').read
DOMAIN = 'example.org'

Capybara.app = PickleSpears

class PickleSpears
  class Test
    class Unit < Minitest::Test

      include Rack::Test::Methods
      include Capybara::DSL

      def run(*args, &block)
        Sequel::Model.db.transaction(:rollback => :always) do
          Sequel::Model.db << "SET CONSTRAINTS ALL DEFERRED"
          super
        end
        return self
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
