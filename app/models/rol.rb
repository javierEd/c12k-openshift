class Rol
  include Mongoid::Base
  
  attr_accessor :ent_permisos
  
  
  field :nombre, type: String
  
  has_many :cuentas
  
  embeds_many :permisos, class_name: 'Embed::RolPermiso'
  
  validates_presence_of :nombre
  validates_uniqueness_of :nombre
  
  before_save :definir_permisos
  
  after_initialize :para_editar
  
  protected
  
  def definir_permisos
    self.permisos = []
    ent_permisos.each do |grupo,gvalor|
      gvalor.each do |controlador,cvalor|
        if cvalor == '1'
          self.permisos << Embed::RolPermiso.new(grupo: grupo, controlador: controlador)
        end
      end
    end
  end
  
  def para_editar
    if self.permisos && self.permisos.any?
      self.ent_permisos = {}
      self.permisos.each do |permiso|
        if !self.ent_permisos[permiso.grupo]
          self.ent_permisos[permiso.grupo] = {}
        end
        self.ent_permisos[permiso.grupo][permiso.controlador] = 1
      end
    end
  end
  
end