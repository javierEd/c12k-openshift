class Menu
  include Mongoid::Base
  
  embeds_many :elementos, class_name: 'Embed::ElementoMenu'
  
  field :ubicacion, type: Integer        # 1: superior, 2: inferior
  
  validates_uniqueness_of :ubicacion
  
end