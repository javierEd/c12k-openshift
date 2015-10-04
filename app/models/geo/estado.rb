class Geo::Estado
  include Mongoid::Base
  
  field :nombre, type: String
  
  has_many :municipios
  
end