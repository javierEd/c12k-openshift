class Etiqueta
  include Mongoid::Base
  
  field :nombre, type: String
  
  has_one :alias
  
  validates_uniqueness_of :nombre
  
end