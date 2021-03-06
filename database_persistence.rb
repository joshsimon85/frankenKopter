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
    last_name = data[:last_name]
    email = data[:email]
    body = data[:message]

    sql = <<~SQL
      INSERT INTO testimonials (first_name, last_name, email, body)
                        VALUES ($1, $2, $3, $4);
    SQL

    query(sql, first_name, last_name, email, body)
  end

  def emails
    results = query('SELECT * FROM emails;')

    results.map { |tuple| tuple_to_email_hash(tuple) }
  end

  def testimonials
    results = query('SELECT * FROM testimonials;')

    results.map { |tuple| tuple_to_testimonial_hash(tuple) }
  end

  def unread_emails
    results = query('SELECT * FROM emails WHERE viewed = false;')

    results.map { |tuple| tuple_to_email_hash(tuple) }
  end

  def unpublished_testimonials
    results = query('SELECT * FROM testimonials WHERE published = false;')

    results.map { |tuple| tuple_to_testimonial_hash(tuple) }
  end

  def fetch_testimonial(id)
    sql = 'SELECT * FROM testimonials WHERE id = $1;'

    result = query(sql, id)
    result.map { |tuple| tuple_to_testimonial_hash(tuple) }
  end

  def update_testimonial(id, message)
    sql = 'UPDATE testimonials SET body = $2 WHERE id = $1;'

    query(sql, id, message)
  end

  def publish_testimonial(id)
    sql = 'UPDATE testimonials SET published = true WHERE id = $1;'

    query(sql, id)
  end

  def delete_testimonial(id)
    sql = 'DELETE FROM testimonials WHERE id = $1;'

    query(sql, id)
  end

  def update_admin_password(username, password)
    sql = 'UPDATE admins SET password = $2 WHERE user_name = $1;'

    query(sql, username, password)
  end

  def delete_email(id)
    sql = 'DELETE FROM emails WHERE id = $1;'

    query(sql, id)
  end

  def mark_email_viewed(id)
    sql = 'UPDATE emails SET viewed = true WHERE id = $1;'

    query(sql, id)
  end

  def fetch_n_testimonials(number)
    sql = <<~SQL
      SELECT * FROM testimonials WHERE published = true ORDER BY id DESC
      LIMIT $1;
    SQL

    result = query(sql, number)
    result.map { |tuple| tuple_to_testimonial_hash(tuple) }
  end

  private

  def convert_to_string(bool)
    if bool == 'f'
      'false'
    else
      'true'
    end
  end

  def convert_date(date)
    date.split('.')[0].split(':')[0, 2].join(':')
  end

  def tuple_to_list_hash(tuple)
    {
      id: tuple['id'].to_i,
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      user_name: tuple['user_name'],
      password: tuple['password']
    }
  end

  def tuple_to_email_hash(tuple)
    {
      id: tuple['id'].to_i,
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      phone_number: tuple['phone_number'],
      email: tuple['email'],
      message: tuple['message'],
      viewed: convert_to_string(tuple['viewed']),
      sent: convert_date(tuple['sent'])
    }
  end

  def tuple_to_testimonial_hash(tuple)
    {
      id: tuple['id'].to_i,
      first_name: tuple['first_name'],
      last_name: tuple['last_name'],
      email: tuple['email'],
      body: tuple['body'],
      published: convert_to_string(tuple['published']),
      submitted: convert_date(tuple['sent'])
    }
  end
end
