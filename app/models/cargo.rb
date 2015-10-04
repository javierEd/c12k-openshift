class Cargo
  include Mongoid::Base
  
  field :nombre, type: String
  field :descripcion, type: String
  
  belongs_to :nomina
  
end