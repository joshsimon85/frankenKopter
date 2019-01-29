# FrankenKopter
require 'sinatra'
require 'bcrypt'

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

before do
  @storage = DatabasePersistence.new(logger)
end

after do
  @storage.disconnect
end

helpers do
  def valid_first_name?(first)
    first.match?(/[a-z]+/i)
  end

  def valid_last_name?(last)
    last.match?(/[a-z]+/i)
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def valid_phone?(phone)
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

  def validate(data)
    invalid_data = false

    unless valid_first_name?(data[:first_name])
      invalid_data = true
      session[:first_name_error] = 'Please provide a valid first name'
    end

    unless valid_last_name?(data[:last_name])
      invalid_data = true
      session[:last_name_error] = 'Please provide a valid last name'
    end

    unless valid_phone?(data[:phone_number])
      invalid_data = true
      session[:phone_number_error] = 'Please provide a valid phone number'
    end

    unless valid_email?(data[:email])
      invalid_data = true
      session[:email_error] = 'Please provide a valid email'
    end

    unless valid_message?(data[:message])
      invalid_data = true
      session[:message_error] = 'Please provide a message'
    end

    invalid_data
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
