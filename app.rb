# FrankenKopter
require 'sinatra'
require 'bcrypt'
require 'recaptcha'

require_relative 'database_persistence'
require_relative 'email.rb'

configure(:production) do
  require 'rack/ssl'
  use Rack::SSL

  Recaptcha.configure do |config|
    config.site_key = ENV['RECAP_SITE_KEY']
    config.secret_key = ENV['RECAP_SECRET_KEY']
  end
end

configure do
  enable :sessions
  set :session, ENV['SESSION_SECRET']
  set :erb, escape_html: true

  helpers Recaptcha::ClientHelper
  helpers Recaptcha::Verify
end

configure(:development, :test) do
  require 'dotenv/load'

  Recaptcha.configure do |config|
    config.site_key = ENV['RECAP_DEV_SITE_KEY']
    config.secret_key = ENV['RECAP_DEV_SECRET_KEY']
  end
end

configure(:development) do
  require 'sinatra/reloader'
  require 'rubocop'
  require 'pry'

  also_reload 'stylesheets/css/master.css'
  also_reload 'stylesheets/css/admin.css'
  also_reload 'database_persistence.rb'
  also_reload 'email.rb'
end

register do
  def auth(type)
    condition do
      redirect '/login' unless send("#{type}?")
    end
  end
end

before do
  @storage = DatabasePersistence.new(logger)
  @admin = session[:admin]
end

after do
  @storage.disconnect
end

helpers do
  def admin?
    @admin != nil
  end

  def valid_first_name?(first)
    first.match?(/[a-z]+/i)
  end

  def valid_last_name?(last)
    last.match?(/[a-z]+/i)
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def valid_phone_number?(phone)
    if phone == ''
      true
    elsif phone.match?(/[a-z]/i)
      false
    else
      true
    end
  end

  def valid_message?(message)
    message.match?(/[a-z]+/i) && message != ''
  end

  def create_methods(data)
    methods = []

    data.each_key do |key|
      methods.push("valid_#{key}?")
    end

    methods
  end

  def validate(data)
    invalid_data = false
    keys = data.keys
    methods = create_methods(data)

    methods.each_with_index do |method, index|
      key = keys[index]

      unless send(method, data[key])
        invalid_data = true
        text = key.to_s.sub(/_/, ' ')
        session_key = "#{key}_error".to_sym
        session[session_key] = "Please provide a valid #{text}"
      end
    end

    invalid_data
  end

  def encrypt_password(password)
    BCrypt::Password.create(password)
  end

  def valid_password?(stored_password, password)
    decrypted_password = BCrypt::Password.new(stored_password)
    decrypted_password == password
  end

  def valid_admin?(user_name, password)
    admin = @storage.find_admin(user_name)
    admin && valid_password?(admin[:password], password)
  end

  def send_contact_mail(data_hash)
    admin_email = SendgridWebMailer.new
    admin_email.create_contact_email(data_hash)
    admin_email.send
  end

  def send_testimonial_mail(data_hash)
    admin_email = SendgridWebMailer.new
    admin_email.create_testimonial_email(data_hash)
    admin_email.send
  end
end

not_found do
  status 404

  'page not found'
end

get '/' do
  @title = 'FrankenKopter | Home'
  @testimonials = @storage.fetch_n_testimonials(1)

  erb :home, layout: :layout
end

get '/contact' do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @title = 'FrankenKopter | Contact'

  erb :contact, layout: :layout
end

post '/contact/new' do
  data_hash = {
    first_name: params[:first_name].capitalize,
    last_name: params[:last_name].capitalize,
    email: params[:email],
    phone_number: params[:phone_number],
    message: params[:message]
  }

  invalid_data = validate(data_hash)

  if !invalid_data && verify_recaptcha
    @storage.add_email(data_hash)
    status = send_contact_mail(data_hash)
    session.clear
    if %w[202 200].include?(status)
      session[:success] = 'Your message has been successfully sent'
    else
      session[:error] = 'There was a problem sending your email, please try ' \
                        'again later'
    end

    redirect '/'
  else
    unless verify_recaptcha
      session[:recap_error] = 'Please prove you are a human'
    end

    data_hash.each_key do |key|
      session[key] = data_hash[key]
    end

    redirect '/contact'
  end
end

get '/about' do
  @title = 'FrankenKopter | About'

  erb :about, layout: :layout
end

get '/testimonial' do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @title = 'FrankenKopter | Testimonial'

  erb :testimonial, layout: :layout_testimonial
end

post '/testimonial/new' do
  data_hash = {
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    message: params[:message]
  }

  invalid_data = validate(data_hash)

  if !invalid_data && verify_recaptcha
    @storage.add_testimonial(data_hash)
    send_testimonial_mail(data_hash)
    session.clear
    session[:success] = 'Your testimonial has been successfully sent'

    redirect '/'
  else
    unless verify_recaptcha
      session[:recap_error] = 'Please prove you are a human'
    end

    data_hash.each_key do |key|
      session[key] = data_hash[key]
    end

    redirect '/testimonial'
  end
end

# admin pages
get '/admin', auth: :admin do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @title = 'FrankenKopter | Admin'
  @unread_test = @storage.unpublished_testimonials.length
  @unread_emails = @storage.unread_emails.length

  erb :admin, layout: :layout_admin
end

get '/login' do
  @title = 'FrakenKopter | Login'
  @admin = session[:admin]

  erb :admin_login, layout: :layout_admin
end

post '/login/authenticate' do
  if valid_admin?(params[:user_name], params[:password])
    admin = @storage.find_admin(params[:user_name])
    session[:admin] = { id: admin[:id], first_name: admin[:first_name] }

    redirect '/admin'
  else
    session[:user_name] = params[:user_name]
    session[:error] = 'Sorry that is an incorrect username or password'

    redirect '/login'
  end
end

get '/logout' do
  session[:admin] = nil

  redirect '/'
end

get '/admin/password_reset', auth: :admin do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @title = 'FrankenKopter | Password Reset'

  erb :admin_password_reset, layout: :layout_admin
end

post '/admin/password_reset/authenticate', auth: :admin do
  if valid_admin?(params[:user_name], params[:password]) &&
     params[:new_password] != '' &&
     params[:new_password] == params[:password_confirm]

    @storage.update_admin_password(params[:user_name],
                                   encrypt_password(params[:new_password]))
    session[:success] = 'Your password has been updated'

    redirect '/admin'
  elsif params[:new_password] == ''
    session[:error] = "Your new password can't be blank"

    redirect '/admin/password_reset'
  elsif params[:new_password] != params[:password_confirm]
    session[:error] = 'Your new passwords must match'

    redirect '/admin/password_reset'
  else
    session[:error] = 'Invalid username and/or password'

    redirect '/admin/password_reset'
  end
end

get '/admin/emails', auth: :admin do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @emails = @storage.emails

  erb :admin_emails, layout: :layout_admin
end

post '/admin/emails/destroy/:id', auth: :admin do
  @storage.delete_email(params[:id])
  session[:success] = 'Your email has been deleted!'

  redirect '/admin/emails'
end

post '/admin/emails/mark_viewed/:id', auth: :admin do
  @storage.mark_email_viewed(params[:id])
  session[:success] = 'Your email has been maked as viewed'

  redirect '/admin/emails'
end

ERR_MSG = 'Nothing was selected to preform bulk actions on'.freeze

post '/admin/testimonials/bulk_modify', auth: :admin do
  option = params['bulk_action']
  ids = params.values.slice(0..-2).map(&:to_i)

  if ids.empty?
    session[:error] = ERR_MSG
  elsif option == 'publish'
    ids.each { |id| @storage.publish_testimonial(id) }
    session[:success] = 'Your selected testimonials have been published'
  else
    ids.each { |id| @storage.delete_testimonial(id) }
    session[:success] = 'Your selected testimonials have been deleted'
  end

  redirect '/admin/testimonials'
end

post '/admin/emails/bulk_delete', auth: :admin do
  ids = params.values.slice(0..-2).map(&:to_i)

  if ids.empty?
    session[:error] = ERR_MSG
  else
    ids.each { |id| @storage.delete_email(id) }
    session[:success] = 'Your selected emails have been deleted'
  end

  redirect '/admin/emails'
end

post '/admin/emails/bulk_viewed', auth: :admin do
  ids = params.values.slice(0..-2).map(&:to_i)

  if ids.empty?
    session[:error] = ERR_MSG
  else
    ids.each { |id| @storage.mark_email_viewed(id) }
    session[:success] = 'Your selected emails have been marked as viewed'
  end

  redirect '/admin/emails'
end

get '/admin/testimonials', auth: :admin do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @title = 'FrankenKopter | Admin'
  @testimonials = @storage.testimonials

  erb :admin_testimonials, layout: :layout_admin
end

get '/admin/testimonials/edit/:id', auth: :admin do
  cache_control :public, 'no-cache, no-store, must-revalidate'

  @testimonial = @storage.fetch_testimonial(params[:id].to_i)[0]

  erb :admin_edit_testimonial, layout: :layout_admin
end

post '/admin/testimonials/edit/:id', auth: :admin do
  @storage.update_testimonial(params[:id], params[:message])
  session[:success] = 'Your testimonial has been updated!'

  redirect '/admin/testimonials'
end

post '/admin/testimonials/publish/:id', auth: :admin do
  @storage.publish_testimonial(params[:id])
  session[:success] = 'Your testimonial has been published'

  redirect '/admin/testimonials'
end

post '/admin/testimonials/destroy/:id', auth: :admin do
  @storage.delete_testimonial(params[:id])
  session[:success] = 'Your testimonial has been deleted'

  redirect '/admin/testimonials'
end
