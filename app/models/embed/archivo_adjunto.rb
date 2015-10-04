class Embed::ArchivoAdjunto
  include Mongoid::Document
  
  embedded_in :bloque
  
  belongs_to :archivo
  
  field :oculto, type: Boolean
  
end