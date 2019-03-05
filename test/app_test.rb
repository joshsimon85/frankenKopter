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
    { 'rack.session' => { admin: { first_name: 'admin' } } }
  end

  def create_testimonial
    post '/testimonial/new', first_name: 'test', last_name: 'test',
                             message: 'test'
  end

  def test_home
    get '/'

    assert_equal 200, last_response.status
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

  def test_get_testimonial
    get '/testimonial'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<title>FrankenKopter | Testimonial'
    assert_includes last_response.body, '<form class="testimonial"'
  end

  def test_invalid_testimonial
    post '/testimonial/new', first_name: '', last_name: '', email: '',
                             message: ''

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="testimonial"'
    assert_includes last_response.body, 'Please provide a valid first name'
    assert_includes last_response.body, 'Please provide a valid last name'
    assert_includes last_response.body, 'Please provide a valid email'
    assert_includes last_response.body, 'Please provide a valid message'
  end

  # admin page tests
  def test_get_admin_login
    get '/login'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_get_admin_page_no_credentials
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
    assert_includes last_response.body, '<a class="active" data-id="home"'

    get '/admin'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_admin
    get '/admin', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>FrankenKopter Admin Panel</h1>'
    assert_includes last_response.body, '<h2>Welcome Admin!</h2>'
  end

  def test_admin_emails
    get '/admin/emails', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Emails</h1>'
  end

  def test_non_admin_password_reset
    get '/admin/password_reset'

    assert_equal 302, last_response.status
    get last_response['Location']
    assert_includes last_response.body, '<form class="admin-login"'
  end

  def test_password_reset
    get '/admin/password_reset', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<h1>Password Reset</h1>'
  end

  def test_password_reset_valid
    post '/admin/password_reset/authenticate', { user_name: 'admin',
                                                 password: 'admin',
                                                 new_password: 'admin',
                                                 password_confirm: 'admin' },
                                                 admin_session

    assert_equal 302, last_response.status
    get last_response['location']
    assert_includes last_response.body, 'Your password has been updated'
  end

  def test_password_reset_invalid
    post '/admin/password_reset/authenticate', { user_name: 'admin',
                                                 password: 'null',
                                                 password_confirm: 'null',
                                                 new_password: 'null' },
                                                 admin_session

    assert_equal 302, last_response.status
    get last_response['location']
    assert_includes last_response.body, 'Invalid username and/or password'
  end

  def test_password_reset_empty_new_password
    post '/admin/password_reset/authenticate', { user_name: 'admin',
                                                 password: 'admin',
                                                 new_password: '' },
                                                 admin_session

    assert_equal 302, last_response.status
    get last_response['location']
    assert_includes last_response.body, 'Your new password can&#39;t be blank'
  end

  def test_edit_route
    get '/admin/testimonials/edit/1', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<dt class="centered">Testimonial</dt>'
  end

  def test_presence_delete_admin_popup
    get '/admin/testimonials/edit/1', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<div class="popup">'
  end
end
