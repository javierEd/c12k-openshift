class Post::ArchivoAdjunto
  include Mongoid::Document
  
  embedded_in :post
  
  belongs_to :archivo
  
  field :oculto, type: Boolean
  
end