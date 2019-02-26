# frankenKopter_test.rb
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use!
require 'fileutils'
require 'rack/test'

require_relative '../app'
require_relative '../database_persistence'

class FrankenKopterTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def admin_session
    { 'rack.session' => { admin: 'admin' } }
  end

  def create_testimonial
    post '/testimonial/new', first_name: 'test', last_name: 'test',
                             message: 'test'
  end

  def test_home
    get '/'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Freakish Performance'
    assert_includes last_response.body, '<a class="active" data-id="home"'
  end

  def test_about
    get '/about'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>About Us</h1>'
    assert_includes last_response.body, '<a class="active" data-id="about"'
  end

  def test_contact
    get '/contact'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form class="contact"'
    assert_includes last_response.body, '<a class="active" data-id="contact"'
  end

  def test_all_invalid_contact
    post '/contact/new', first_name: '', last_name: '', email: '',
                         phone_number: 'a', message: ''

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'Please provide a valid first name'
    assert_includes last_response.body, 'Please provide a valid last name'
    assert_includes last_response.body, 'Please provide a valid email'
    assert_includes last_response.body, 'Please provide a valid phone number'
    assert_includes last_response.body, 'Please provide a message'
  end

  def test_all_valid_contact
    post '/contact/new', first_name: 'josh', last_name: 'simon',
                         email: 'test@test.com', phone_number: '',
                         message: 'Testing'

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'FrankenKopter | Home'
  end

  def test_invalid_first_last_names_contact
    post '/contact/new', first_name: '1', last_name: '?', email: '',
                         phone_number: '', message: ''

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'Please provide a valid first name'
    assert_includes last_response.body, 'Please provide a valid last name'
  end

  def test_valid_empty_phone_number
    post '/contact/new', first_name: '', last_name: '', email: '',
                         phone_number: '', message: ''

    assert_equal 302, last_response.status

    get last_response['Location']
    refute_includes last_response.body, 'Please provide a valid phone number'
  end

  def test_invalid_email
    post '/contact/new', first_name: '', last_name: '', email: 'test.com',
                         phone_number: '', message: ''

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'Please provide a valid email'
  end

  def test_get_admin_login
    get '/login'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_get_admin_page
    get '/admin'

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_invalid_admin_login
    post '/login/authenticate', user_name: 'admin', password: 'none'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_valid_admin_login
    post '/login/authenticate', user_name: 'admin', password: 'admin'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<li><a href="/logout">Log Out</a></li>'
  end

  def test_logout
    post '/login/authenticate', user_name: 'admin', password: 'admin'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<li><a href="/logout">Log Out</a></li>'

    get '/logout'
    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<h1>Freakish Performance'

    get '/admin'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_get_testimonial
    get '/testimonial'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<title>FrankenKopter | Testimonial'
    assert_includes last_response.body, '<form class="testimonial"'
  end

  def test_invalid_testimonial
    post '/testimonial/new', first_name: '', last_name: '', email: '', message: ''

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="testimonial"'
    assert_includes last_response.body, 'Please provide a valid first name'
    assert_includes last_response.body, 'Please provide a valid last name'
    assert_includes last_response.body, 'Please provide a valid email'
    assert_includes last_response.body, 'Please provide a valid message'
  end

  def test_valid_testimonial
    skip "need to figure out a way to delete after creating"
    post '/testimonial/new', first_name: 'admin', last_name: 'admin',
                             email: 'test@test.com', message: 'lorem ipsum'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<li><a class="active" data-id="home"'
  end

  def test_admin
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Testimonials</h1>'
  end

  def test_edit_route
    get 'testimonials/edit/1', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form action="/testimonials/edit/1"' +
                                         ' method="post"'
  end

  def test_delete_route
    skip 'need to find a way to find this ones id for deleting after creation maybe make the id not unique in testing so we can pass a value each time'
    create_testimonial
  end
end
