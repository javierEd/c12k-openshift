class Embed::RolPermiso
  include Mongoid::Document
 
  embedded_in :rol
  
  field :grupo, type: String
  field :controlador, type: String
  
end