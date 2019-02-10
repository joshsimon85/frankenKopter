# FrankenKopter
require 'sinatra'
require 'bcrypt'
require 'pony'

require_relative 'database_persistence'

configure do
  enable :sessions
  set :session, 'secret'
  set :erb, escape_html: true
end

configure(:development) do
  require 'sinatra/reloader'
  require 'rubocop'
  require 'pry'
  also_reload 'stylesheets/css/master.css'
  also_reload 'database_persistence.rb'
end

register do
  def auth(type)
    condition do
      redirect '/login' unless send("is_#{type}?")
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
  def is_admin?
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

  def convert(phone_number)
    phone_number.gsub(/[^0-9]/, '')
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
end

not_found do
  status 404

  erb :oops
end

get '/' do
  @title = 'FrankenKopter | Home'

  erb :home, layout: :layout
end

get '/contact' do
  @title = 'FrankenKopter | Contact'

  erb :contact, layout: :layout
end

post '/contact/new' do
  data_hash = {
    first_name: params[:first_name],
    last_name: params[:last_name],
    email: params[:email],
    phone_number: params[:phone_number],
    message: params[:message]
  }

  invalid_data = validate(data_hash)

  if !invalid_data
    @storage.add_email(data_hash)
    session.clear
    session[:success] = 'Your message has been successfully sent'

    redirect '/'
  else
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

get '/admin', :auth => :admin do
  @title = 'FrankenKopter | Admin'
  @testimonials = @storage.testimonials

  erb :admin, layout: :layout_admin
end

get '/login' do
  @title = 'FrakenKopter | Login'

  erb :admin_login, layout: :layout_admin
end

post '/login/authenticate' do
  if valid_admin?(params[:user_name], params[:password])
    admin = @storage.find_admin(params[:user_name])
    session[:admin] = { id: admin[:id], firt_name: admin[:first_name] }

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

get '/testimonial' do
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

  if !invalid_data
    @storage.add_testimonial(data_hash)
    session.clear
    session[:success] = 'Your testimonial has been successfully sent'

    redirect '/'
  else
    data_hash.each_key do |key|
      session[key] = data_hash[key]
    end

    redirect '/testimonial'
  end
end
