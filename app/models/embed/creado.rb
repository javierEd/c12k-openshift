class Embed::Creado
  include Mongoid::Document
  
  embedded_in :cuenta
  embedded_in :persona
  embedded_in :locale
  embedded_in :email
  embedded_in :telefono
  
  field :fecha, type: DateTime, default: DateTime.now
  field :ip, type: String
  
end
