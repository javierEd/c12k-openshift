class Banco
  include Mongoid::Base
  
  belongs_to :organizacion
  
end