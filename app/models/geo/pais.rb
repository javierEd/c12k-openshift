class Geo::Pais
  include Mongoid::Base
  
  field :nombre, type: String
  
  has_many :estados
  
end