class Email
  include Mongoid::Base
  
  field :email, type: String
  field :principal, type: Boolean
  
  field :activo, type: Boolean
  
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  
#   after_save :enviar_codigo_verificacion
  
  def belongs_to_persona?
    true
  end
  
  protected
  
#   def enviar_codigo_verificacion
#     VerificacionEmailMailer.codigo_verificacion(self.email, self._id)
#   end
  
end