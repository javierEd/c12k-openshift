class Encuesta
  include Mongoid::Base
  
  field :titulo, type: String
  field :descripcion, type: String
  
  field :idioma, type: String
  
  has_and_belongs_to_many :etiquetas, inverse_of: nil
  
  def belongs_to_persona?
    true
  end
  
end