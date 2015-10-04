class Post
  include Mongoid::Base
  
  attr_accessor :ent_post, :ent_archivos, :ent_etiquetas, :ent_alias
  
  field :titulo, type: String
  
  field :idioma, type: String, default: 'es'
  
  embeds_many :archivos_adjuntos, class_name: 'Post::ArchivoAdjunto'
  
  has_and_belongs_to_many :etiquetas, inverse_of: nil, autosave: true
  
  validates_presence_of :titulo
  validates_presence_of :ent_post
  
  field :publicado, type: Boolean
  field :fecha_publicado, type: DateTime
  
  field :pagina_simple, type: Boolean
  
  has_one :alias, autosave: true

  field :borrado, type: Boolean
  field :aprobado, type: Boolean
  field :bloqueado, type: Boolean
  
  def leer_post
    if self._id && File.exist?(AppConfig.aplicacion.posts.directorio+"/"+self._id)
      File.read(AppConfig.aplicacion.posts.directorio+"/"+self._id)
    end
  end
  
  def belongs_to_persona?
    true
  end
  
  before_create :insertar_datos
  
  after_initialize :para_editar
  
  before_update :actualizar_datos
  
  after_save :guardar_post
  
  protected
  
  def para_editar
    self.ent_post = leer_post if leer_post
    
    if self.etiquetas && self.etiquetas.any?
      self.ent_etiquetas=''
      self.etiquetas.each do |etiqueta|
        self.ent_etiquetas += etiqueta.nombre+','
      end
    end
    
    if self.archivos_adjuntos && self.archivos_adjuntos.any?
      self.ent_archivos=[]
      self.archivos_adjuntos.each do |obj_archivo|
        self.ent_archivos.push({ :id => obj_archivo.archivo_id, :file_name => obj_archivo.archivo.archivo_file_name, :value => obj_archivo.archivo_id })
      end
    end
    
    if self.alias && !self.alias.oculto
      self.ent_alias = self.alias.ruta
    end
  end
  
  def guardar_etiquetas
    self.etiquetas = []
    unless ent_etiquetas.blank? || ent_etiquetas.split(',').empty?
      ent_etiquetas.split(',').each do |etiqueta|
	if query_etiqueta = Etiqueta.where(:nombre => etiqueta.strip.downcase).first
	  self.etiquetas.push query_etiqueta
	else
	  unless etiqueta.blank?
	    self.etiquetas.push Etiqueta.new(:nombre => etiqueta.strip.downcase, :tmp_vars => tmp_vars)
	  end
	end
      end
    end
  end
  
  def guardar_adjuntos
    self.archivos_adjuntos = []
    unless ent_archivos.nil? || ent_archivos.empty?
      ent_archivos.each do |archivo|
        if self.archivos_adjuntos.select{|i| i[:archivo_id] == BSON::ObjectId.from_string(archivo)}[0].nil? && query_archivo = Archivo.where(:_id => archivo).first
          self.archivos_adjuntos.push Post::ArchivoAdjunto.new(:archivo => query_archivo)
        end
      end
    end
    
    # Busca archivos adjuntos dentro del contenido del post
    url = AppConfig.aplicacion.url.gsub(/[\/.]/,'/'=>'\\/','.'=>'[.]')
    pat = eval("/[\"']"+url+"\\/archivo\\/[0-9a-z]{24}[\"']|[\\/?\"']\\/archivo\\/[0-9a-z]{24}[\\/?\"']/i")
    ent_post.scan(pat).each do |archivo|
      archivo = archivo[-25..-2]
      if self.archivos_adjuntos.select{|i| i[:archivo_id] == BSON::ObjectId.from_string(archivo)}[0].nil? && query_archivo = Archivo.where(:_id => archivo).first
        self.archivos_adjuntos.push Post::ArchivoAdjunto.new(:archivo => query_archivo)
      end
    end
  end
  
  def guardar_alias
    unless ent_alias.empty?
      if self.alias
        self.alias.ruta = ent_alias
        self.alias.tmp_vars = self.tmp_vars
        if self.alias.oculto
          self.alias.oculto = false
        end
        self.alias.save
      else
        self.alias = Alias.new(ruta: ent_alias, tmp_vars: self.tmp_vars)
      end
    else
      if self.alias
        self.alias.tmp_vars = self.tmp_vars
        self.alias.oculto = true
      end
    end
  end
  
  def insertar_datos
    
    guardar_etiquetas
    
    guardar_adjuntos
    
    if self.publicado
      self.fecha_publicado = DateTime.now
    end
    
    guardar_alias
  end
  
  def actualizar_datos
    
    guardar_etiquetas
    
    guardar_adjuntos
    
    if self.publicado && self.fecha_publicado.nil?
      self.fecha_publicado = DateTime.now
    end
    
    guardar_alias
  end
  
  def guardar_post
    if self.borrado
      File.delete(AppConfig.aplicacion.posts.directorio+"/"+self._id)
      File.open(AppConfig.aplicacion.posts.papelera+"/"+self._id,'w') do |file_post|
        file_post.puts ent_post
      end
    else
      File.open(AppConfig.aplicacion.posts.directorio+"/"+self._id,'w') do |file_post|
        file_post.puts ent_post
      end
    end
  end
  
end