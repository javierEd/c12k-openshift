class GenericMailer < ApplicationMailer

  def generic_email(para, asunto, mensaje, opciones = {})
    if opciones[:adjuntos]
      opciones[:adjuntos].each do |adjunto|
        attachments[adjunto[:nombre]] = adjunto[:contenido]
      end
    end
    @mensaje = mensaje
    mail(to: para, subject: asunto)
  end
  
end
