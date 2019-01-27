# session persistence
class SessionPersistence
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  def clear
    session.clear
  end

  def add_email_error
    session[:email_error] = 'Sorry that emial subks'
  end

  def email_error
    session[:email_error]
  end
end
