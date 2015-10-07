class Comprobante
  include Mongoid::Base
  
  attr_accessor :aprobar, :ent_nro
  
  belongs_to :inscripcion
  
  field :nro, type: Integer
  
  validates_uniqueness_of :nro
  
  validates_acceptance_of :aprobar
  
  before_create :insertar_numero
  
  after_initialize :mostrar_numero
  
  def mostrar_numero
    self.ent_nro = (Comprobante.count + 1).to_s.rjust(4,"0")
  end
  
  def insertar_numero
    self.nro = Comprobante.count + 1
  end
  
end