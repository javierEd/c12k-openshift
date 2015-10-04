class Embed::DocId
  include Mongoid::Document
  
  attr_accessor :ent_doc_id
  
  embedded_in :persona
  
  field :cat, type: String
  field :nro, type: String
  field :ext, type: String

  validates_presence_of :cat
  validates_presence_of :nro
  validates_uniqueness_of :nro
  
  before_create :insertar_datos
  
  protected
  
  def insertar_datos
    arr_doc_id = self.ent_doc_id.split('-')
    
    p arr_doc_id
    
    self.cat = arr_doc_id[0]
    self.nro = arr_doc_id[1]
    self.ext = arr_doc_id[2] if arr_doc_id[2]
  end
  
end