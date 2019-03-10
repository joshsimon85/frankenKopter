# Email class
require 'sendgrid-ruby'

class SendgridWebMailer
  include SendGrid

  def self.send_email(from, subject, content)
    from = Email.new(email: from)
    to = Email.new(email: 'kasey@frankenkopter.com')
    subject = subject
    content = Content.new(type: 'text/plain', value: content)
    mail = Mail.new(from, subject, to, content)
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    sg.client.mail._('send').post(request_body: mail.to_json)
  end
end
