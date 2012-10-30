require 'test/unit'
require 'rack/test'
require 'picklespears'
require 'ostruct'

DB << open(File.dirname(__FILE__) + '/../../../db/create.sql', 'r').read

# needed so I can call my class PS::Test::Unit -- below
class PickleSpears::Test
end

class PickleSpears::Test::Unit < Test::Unit::TestCase

  include Rack::Test::Methods

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

  # needed for a "default" test?
  def test_foo
  end
end
