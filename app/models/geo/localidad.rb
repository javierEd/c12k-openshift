class Geo::Localidad
  include Mongoid::Base
  
  field :nombre, type: String
  
  has_many :parroquias
  
end