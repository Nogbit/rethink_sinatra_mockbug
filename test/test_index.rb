ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require File.expand_path '../../index.rb', __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "when marking someone as exportable" do
  it "should return without errors" do
    post "/update/exportable.json", :id => "jimbob_tester", :export => true
    puts "response = #{last_response}"
    data = JSON.parse(last_response.body)
    data[0].must_equal(0)
  end
end

