class GenericMailer < ApplicationMailer

  def generic_email(para, asunto, mensaje)
    @mensaje = mensaje
    mail(to: para, subject: asunto)
  end
  
end
