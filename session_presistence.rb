# session persistence
class SessionPersistence
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  def admin?
    !!session[:admin]
  end

  def admin
    session[:admin]
  end

  def store_admin_object(admin)
    session[:admin] = admin
  end

  def clear
    session.clear
  end

  def id
    session[:id]
  end

  def first_name
    session[:first_name]
  end

  def last_name
    session[:last_name]
  end

  def username
    session[:username]
  end
end
