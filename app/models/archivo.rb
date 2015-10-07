class Archivo
  include Mongoid::Base
  include Mongoid::Paperclip
  
  attr_accessor :ent_archivos, :ent_alias
  
  has_and_belongs_to_many :etiquetas, inverse_of: nil
  
  has_mongoid_attached_file :archivo,
    :url => "/archivo/:id",
    :path => AppConfig.aplicacion.archivos.directorio+"/:id"
  
  validates_attachment_presence :archivo
  do_not_validate_attachment_file_type :archivo
  
  field :publicado, type: Boolean
  field :fecha_publicado, type: DateTime
  
  has_one :alias, autosave: true
  
  field :borrado, type: Boolean
  field :aprobado, type: Boolean
  field :bloqueado, type: Boolean
  
  def nombre
    self.archivo_file_name
  end
  
  def nombre=(nombre)
    self.archivo_file_name=nombre
  end
  
  def tipo
    if self.archivo_content_type == 'application/force-download'
      MimeMagic.by_magic(File.open(AppConfig.aplicacion.archivos.directorio+"/"+self._id)).to_s
    else
      self.archivo_content_type
    end
  end
  
  def tamanio
    self.archivo_file_size
  end
  
  def abrir
    open(AppConfig.aplicacion.archivos.directorio+"/"+self._id, "rb").read
  end
  
  def belongs_to_persona?
    true
  end
  
  before_create :insertar_datos
  
  before_update :actualizar_datos
  
  protected
  
  def insertar_datos    

  end
  
  def actualizar_datos
    if self.borrado
      
      Post.where('archivos_adjuntos.archivo_id' => self._id).each do |post_a|
        post_a.tmp_vars = tmp_vars
        post_a.archivos_adjuntos.delete_all(:archivo_id => self._id)
        post_a.save
      end
      
      if File.exist? AppConfig.aplicacion.archivos.directorio+"/"+self._id
	File.rename(AppConfig.aplicacion.archivos.directorio+"/"+self._id,AppConfig.aplicacion.archivos.papelera+"/"+self._id)
      end
    end
  end
  
end