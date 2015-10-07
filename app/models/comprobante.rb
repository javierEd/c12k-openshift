class Comprobante
  include Mongoid::Base
  
  attr_accessor :aprobar, :ent_nro
  
  belongs_to :inscripcion
  
  field :elite, type: Boolean
  
  field :nro, type: Integer
  
  validates_uniqueness_of :nro
  
  validates_acceptance_of :aprobar
  
  before_create :insertar_numero
  
  after_initialize :mostrar_numero
  
  def mostrar_numero
    self.ent_nro = (Comprobante.where(elite: false).count + 51).to_s.rjust(4,"0")
  end
  
  def insertar_numero
    if self.elite
      self.nro = Comprobante.where(elite: true).count + 1
      if self.nro > 50
        self.nro = Comprobante.where(elite: false).count + 51
      end
    else
      self.nro = Comprobante.where(elite: false).count + 51
    end
  end
  
end