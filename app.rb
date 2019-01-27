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
  require 'pry'
  require 'rubocop'
  aldo_reload 'database_persistence.rb'
  also_reload 'stylesheets/main.css'
  also_reload 'database_persistence.rb'
end

def image_path
  File.expand_path('../images', __FILE__)
end

before do
  #@session = SessionPersistence.new(session)
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

  def valid_form_data?(first, last, email, phone, message)
    invalid_fields = {}

    form_data = {
      :first_name  => valid_first_name?(first),
      :last_name => valid_last_name?(last),
      :email => valid_email?(email),
      :phone => valid_phone?(phone),
      :message => valid_message?(message)
    }

    form_data.each_key do |key|
      unless form_data[key] == true
        invalid_fields[key] = form_data[key]
      end
    end

    invalid_fields
  end

  def convert(phone_number)
    phone_number.gsub(/[^0-9]/, '')
  end
end

#404 pages
not_found do
  status 404

  erb :oops
end

get '/' do
  @title = 'FrankenKopter'

  erb :home, layout: :layout
end

get '/contact' do
  @title = 'FrankenKopter | Contact'

  erb :contact, layout: :layout
end

post '/contact' do
  first_name = params[:first_name]
  last_name = params[:last_name]
  email = params[:email]
  phone_number = params[:phone_number]
  message = params[:message]

  invalid_fields = valid_form_data?(first_name, last_name, email, phone_number,
                                    message)
  if invalid_fields.length.zero?
    @storage.add_email(first_name, last_name, email, convert(phone_number),
                       message)

    redirect '/'
  else
    redirect '/contact'
  end
end

get '/about' do
  @title = 'FrankenKopter | About'

  erb :about, layout: :layout
end
