ENV['RACK_ENV'] = 'test'

require 'test/unit'
require 'rack/test'
require 'capybara'
require 'picklespears'
require 'ostruct'

DB << open(File.dirname(__FILE__) + '/../../../db/create.sql', 'r').read

Capybara.app = PickleSpears

# needed so I can call my class PS::Test::Unit -- below
class PickleSpears::Test
end

class PickleSpears::Test::Unit < Test::Unit::TestCase

  include Rack::Test::Methods
  include Capybara::DSL

  def run(*args, &block)
    Sequel::Model.db.transaction(:rollback => :always) do
      Sequel::Model.db << "SET CONSTRAINTS ALL DEFERRED"
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
