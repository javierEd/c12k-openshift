class Embed::ElementoMenu
  include Mongoid::Document
  
  embedded_in :menu
  
  field :titulo, type: String
  field :enlace, type: String
  field :target, type: String
  field :posicion, type: Integer, default: 0
  
  validates_presence_of :titulo
  validates_presence_of :enlace
  
end