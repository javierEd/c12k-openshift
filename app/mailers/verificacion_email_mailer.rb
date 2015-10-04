class VerificacionEmailMailer < ApplicationMailer
  
  def codigo_verificacion(email,codigo)
    @email = email
    @codigo = codigo
    mail(to: email, subject: 'Verificación de su cuenta de correo electronico asociada a '+titulo)
  end
  
end