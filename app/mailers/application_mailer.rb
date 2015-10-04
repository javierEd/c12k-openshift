class ApplicationMailer < ActionMailer::Base
  default from: AppConfig.servidor.mail.sender_address
  layout 'mailer'
end
