require 'test/unit'
require 'picklespears'
require 'rack/test'

DataMapper.auto_migrate!

# needed so I can call my class PS::Test::Unit -- below
class PickleSpears::Test
end

class PickleSpears::Test::Unit < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    repository.adapter.execute('begin transaction')
  end

  def teardown
    repository.adapter.execute('rollback')
  end

  def app
    Sinatra::Application
  end

  # needed for a "default" test?
  def test_foo
  end
end
