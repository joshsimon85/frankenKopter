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
    full_name = "#{data[:first_name]} #{data[:last_name]}"
    @email = Mail.new
    @email.template_id = 'd-2886d4615c1748529903831b2d65cdd3'
    @email.from = Email.new(email: data[:email], name: full_name)
    personalization = Personalization.new
    personalization.add_to(Email.new(email: 'kasey@frankenkopter.com',
                                     name: 'Kasey Koch'))
    personalization.add_dynamic_template_data({
                                                "content": data[:message],
                                                "first_name": data[:first_name],
                                                "last_name": data[:last_name],
                                                "phone_number": data[:phone_number]
                                              })
    @email.add_personalization(personalization)
  end

  def create_contact_email_response(data)
    full_name = "#{data[:first_name]} #{data[:last_name]}"
    @email = Mail.new
    @email.template_id = 'd-899bcf941951427393a067e1b2b06270'
    @email.from = Email.new(email: 'no-reply@frankenkopter', name: 'Kasey Koch')
    personalization = Personalization.new
    personalization.add_to(Email.new(email: data[:email],
                                     name: full_name))
    personalization.add_dynamic_template_data({
                                                "first_name": data[:first_name],
                                                "last_name": data[:last_name]
                                              })
    @email.add_personalization(personalization)
  end

  def create_testimonial_email(data)
    full_name = "#{data[:first_name]} #{data[:last_name]}"
    @email = Mail.new
    @email.template_id = 'd-5211527617634b83a07be52580f2ab5e'
    @email.from = Email.new(email: data[:email], name: full_name)
    personalization = Personalization.new
    personalization.add_to(Email.new(email: 'kasey@frankenkopter.com',
                                     name: 'Kasey Koch'))
    personalization.add_dynamic_template_data({
                                                "first_name": data[:first_name],
                                                "last_name": data[:last_name]
                                              })
    @email.add_personalization(personalization)
  end

  def create_testimonial_response(data)
    full_name = "#{data[:first_name]} #{data[:last_name]}"
    @email = Mail.new
    @email.template_id = 'd-4412c3c99eaf484085086f6cd85a72f9'
    @email.from = Email.new(email: 'no-reply@frankenkopter.com', name: 'Kasey Koch')
    personalization = Personalization.new
    personalization.add_to(Email.new(email: data[:email], name: full_name))
    personalization.add_dynamic_template_data({
                                                "first_name": data[:first_name],
                                                "last_name": data[:last_name]
                                              })
    @email.add_personalization(personalization)
  end

  def send
    response = @sg.client.mail._('send').post(request_body: @email.to_json)
    response.status_code
  end
end
