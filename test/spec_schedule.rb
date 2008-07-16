#!/usr/bin/env ruby

require 'test/spec'
require 'mocha'

context 'Schedule' do

  specify "show a default page" do

    get_it '/'
  end

end
