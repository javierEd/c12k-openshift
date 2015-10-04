class Contacto
  include Mongoid::Base
  include Humanizer
  
  require_human_on :create
  
  has_many :respuestas, class_name: 'ContactoRespuesta'
  
  field :nombre, type: String
  field :email, type: String
  field :asunto, type: String
  field :mensaje, type: String
  
  field :leido, type: Boolean
  field :borrado, type: Boolean
  
  validate :validar_usuario
  validates_presence_of :asunto
  validates_presence_of :mensaje
  
  def validar_usuario
    unless tmp_vars[:cuenta_signed_in]
      if self.nombre.length == 0 
        errors.add(:nombre, 'Este campo es requerido')
      end
      if self.email.length == 0
        errors.add(:email, 'Este campo es requerido')
      elsif ! self.email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        errors.add(:email, 'Formato invalido')
      end
    end
  end
  
  def remitente
    if self.persona
      remitente = self.persona.nombre + ' <' + self.persona.email + '>'
    elsif self.nombre && self.email
      remitente = self.nombre + ' <' + self.email + '>'
    else
      remitente = 'N/D'
    end
  end
  
  def belongs_to_persona?
    true
  end
  
  before_create :enviar_mensaje
  
  def enviar_mensaje
    
  end
  
end