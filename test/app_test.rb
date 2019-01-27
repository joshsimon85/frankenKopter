# frankenKopter_test.rb
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!
require 'fileutils'
require 'rack/test'

require_relative '../app'

class FrankenKopterTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home
    get '/'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Freakish Performance'
  end

  def test_about
    get '/about'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>About Us</h1>'
  end

  def test_contact
    get '/contact'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form class="contact"'
  end
end
