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
