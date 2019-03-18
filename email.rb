# Email class
require 'sendgrid-ruby'
require 'json'

class SendgridWebMailer
  attr_accessor :email
  include SendGrid

  def initialize
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def create_contact_email(data)
    email_data = {
      "personalizations": [
        {
          "to": [
            {
              "email": 'kasey@frankenkopter.com',
              "name": 'Kasey Koch'
            }
          ],
          "subject": 'Frankenkopter New Contact Form Submission'
        }
      ],
      "from": {
        "email": data[:email],
        "name": "#{data[:first_name]} #{data[:last_name]}"
      },
      "content": [
        {
          "type": 'text/plain',
          "value": data[:message]
        }
      ]
    }

    #@email = JSON.generate(email_data)
  @email = Mail.new
  @email.template_id = 'd-2886d4615c1748529903831b2d65cdd3'
  @email.from = Email.new(email: data[:email])
  #subject = 'Dynamic Template Data Hello World from the SendGrid Ruby Library'
  #mail.subject = subject
  personalization = Personalization.new
  personalization.add_to(Email.new(email: 'kasey@frankenkopter.com', name: 'Kasey Koch'))
  personalization.add_dynamic_template_data({
    "variable" => [
      {"content" => "#{data[:message]}"}, {"first_name" => "#{data[:first_name]}"}, {"last_name" => data[:last_name]}, {"phone_number" => data[:phone_number]}
    ]
  })
  @email.add_personalization(personalization)
  end

  def create_contact_email_response(data)
    email_data = {
      "personalizations": [
        {
          "to": [
            {
              "email": data[:email],
              "name": "#{data[:first_name]} #{data[:last_name]}"
            }
          ],
          "subject": 'Frankenkopter Contact Form Submission'
        }
      ],
      "from": {
        "email": 'kasey@frankenkopter.com',
        "name": 'Frankenkopter'
      },
      "content": [
        {
          "type": 'text/html',
          "value": 'Thank you for you reaching out to ' \
          '<a href="www.frankenkopter.com">Frankenkopter</a>. We will get ' \
          'back to you within the next 48 hours.'
        }
      ]
    }

    @email = JSON.generate(email_data)
  end

  def send
    response = @sg.client.mail._('send').post(request_body: @email.to_json) #json.parse
  end
end
