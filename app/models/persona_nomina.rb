class PersonaNomina
  include Mongoid::Base
  
  belongs_to :persona
  belongs_to :nomina
  
end