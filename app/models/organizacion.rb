class Organizacion
  include Mongoid::Base
  
  field :nombre, type: String
  
  field :tipo, type: String
  
end