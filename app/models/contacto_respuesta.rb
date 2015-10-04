class ContactoRespuesta
  include Mongoid::Base
  
  belongs_to :contacto
  
  field :mensaje, type: String
  
  validates_presence_of :mensaje
  
#   after_save :enviar_mensaje
#   
#   def enviar_mensaje
#     
#   end
  
end