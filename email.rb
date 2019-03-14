# Email class
require 'sendgrid-ruby'
require 'json'
require 'pry'

class SendgridWebMailer
  include SendGrid

  def initialize
    @sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def send(data, subject)
  #from = Email.new(email: data[:email], name: "#{data[:first_name]} #{data[:last_name]}")
    to = Email.new(email: 'kasey@frankenkopter.com')
    subject = subject
    content = Content.new(type: 'text/plain', value: data[:message])
    mail = Mail.new(from, subject, to, content)
    response = @sg.client.mail._('send').post(request_body: mail.to_json)
    binding.pry
  end
end
