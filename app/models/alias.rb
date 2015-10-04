class Alias
  include Mongoid::Base
  
  field :ruta, type: String
  
  belongs_to :post
  belongs_to :archivo
  belongs_to :etiqueta
  
  validates_presence_of :ruta
  validates_format_of :ruta, :with => /\A[A-Za-z0-9_\-.]+\z/i, allow_blank: true, message: 'posee caracteres invalidos'
  validates_uniqueness_of :ruta, :case_sensitive => false
  
  field :oculto, type: Boolean
  
end