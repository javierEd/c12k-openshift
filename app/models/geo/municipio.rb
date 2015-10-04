class Geo::Municipio
  include Mongoid::Base
  
  field :nombre, type: String
  
  has_many :localidades
  
end