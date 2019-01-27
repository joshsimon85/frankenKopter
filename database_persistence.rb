require 'pg'

# DB API class
class DatabasePersistence
  def initialize(logger)
    @db = connect_to_database
    @logger = logger
  end

  def connect_to_database
    if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    elsif Sinatra::Base.development?
      PG.connect(dbname: 'frankenKopter')
    end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def add_email(first_name, last_name, phone_number, email, message)
    sql = <<~SQL
    INSERT INTO emails (first_name, last_name, phone_number, email, message)
         VALUES ($1, $2, $3, $4, $5);
    SQL

    query(sql, first_name, last_name, phone_number, email, message)
  end

  private

  def tuple_to_list_hash(tuple)
    { id: tuple['id'].to_i,
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      phone_number: tuple['phone_number'],
      email: tuple['email'],
      sent: tuple['sent']
    }
  end
end
