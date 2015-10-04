class ContactoRespuestaMailer < ApplicationMailer

  def mensaje(para, asunto, mensaje)
    
    
    mail(to: email, subject: 'Re: '+titulo)
  end
  
end
