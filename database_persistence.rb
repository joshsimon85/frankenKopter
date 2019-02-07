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
      PG.connect(dbname: 'franken_kopter')
    else
      PG.connect(dbname: 'test_franken_kopter')
    end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def add_email(data)
    first_name = data[:first_name]
    last_name = data[:last_name]
    phone_number = data[:phone_number]
    email = data[:email]
    message = data[:message]

    sql = <<~SQL
      INSERT INTO emails (first_name, last_name, phone_number, email, message)
         VALUES ($1, $2, $3, $4, $5);
    SQL

    query(sql, first_name, last_name, phone_number, email, message)
  end

  def find_admin(user_name)
    sql = 'SELECT * FROM admins WHERE user_name = $1;'

    result = query(sql, user_name)
    result.map { |tuple| tuple_to_list_hash(tuple) }.first
  end

  def add_testimonial(data)
    first_name = data[:first_name]
    email = data[:email]
    message = data[:message]

    sql = <<~SQL
      INSERT INTO testimonials (first_name, email, message)
         VALUES ($1, $2, $3);
    SQL

    query(sql, first_name, email, message)
  end

  private

  def tuple_to_list_hash(tuple)
    {
      id: tuple['id'].to_i,
      first_name: tuple['first_name'],
      user_name: tuple['user_name'],
      password: tuple['password']
    }
  end
end
