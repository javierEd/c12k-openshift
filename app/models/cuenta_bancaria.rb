class CuentaBancaria
  include Mongoid::Base
  
  field :nro, type: String
  field :tipo, type: String
  field :descripcion, type: String
  
  belongs_to :persona
  belongs_to :organizacion
  
end