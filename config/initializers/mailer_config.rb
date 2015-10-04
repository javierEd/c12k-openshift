#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require Rails.root.join('lib', 'messagebus', 'mailer')

ControlEventos::Application.configure do
  config.action_mailer.perform_deliveries = AppConfig.servidor.mail.enable?

  unless Rails.env == 'test' || !AppConfig.servidor.mail.enable?
    if AppConfig.servidor.mail.method == 'messagebus'

      if AppConfig.servidor.mail.message_bus_api_key.present?
        config.action_mailer.delivery_method = Messagebus::Mailer.new(AppConfig.servidor.mail.message_bus_api_key.get)
        config.action_mailer.raise_delivery_errors = true
      else
        puts "You need to set your messagebus api key if you are going to use the message bus service. no mailer is now configured"
      end
    elsif AppConfig.servidor.mail.method == "sendmail"
      config.action_mailer.delivery_method = :sendmail
      sendmail_settings = {
        location: AppConfig.servidor.mail.sendmail.location.get
      }
      sendmail_settings[:arguments] = "-i" if AppConfig.servidor.mail.sendmail.exim_fix?
      config.action_mailer.sendmail_settings = sendmail_settings
    elsif AppConfig.servidor.mail.method == "smtp"
      config.action_mailer.delivery_method = :smtp
      smtp_settings = {
        address:              AppConfig.servidor.mail.smtp.host.get,
        port:                 AppConfig.servidor.mail.smtp.port.to_i,
        domain:               AppConfig.servidor.mail.smtp.domain.get,
        enable_starttls_auto: false,
        openssl_verify_mode:  AppConfig.servidor.mail.smtp.openssl_verify_mode.get
      }

      if AppConfig.servidor.mail.smtp.authentication != "none"
        smtp_settings.merge!({
          authentication:       AppConfig.servidor.mail.smtp.authentication.gsub('-', '_').to_sym,
          user_name:            AppConfig.servidor.mail.smtp.username.get,
          password:             AppConfig.servidor.mail.smtp.password.get,
          enable_starttls_auto: AppConfig.servidor.mail.smtp.starttls_auto?
        })
      end

      config.action_mailer.smtp_settings = smtp_settings
    else
      $stderr.puts "WARNING: Mailer turned on with unknown method #{AppConfig.servidor.mail.method}. Mail won't work."
    end
  end
end
