class Bloque
  include Mongoid::Base
  
  attr_accessor :ent_archivos
  
  field :ubicacion, type: String # sup: Superior, izq: Izquierdo, der: Derecho, inf: Inferior
  
  field :titulo, type: String
  field :mostrar_titulo, type: Boolean
  
  field :contenido, type: String
  
  embeds_many :archivos_adjuntos, class_name: 'Embed::ArchivoAdjunto'

  field :publicado, type: Boolean
  field :fecha_publicado, type: DateTime
  
  field :transparente, type: Boolean
  
  field :posicion, type: Integer, default: 0

  validates_presence_of :ubicacion
  validates_presence_of :titulo
  validates_presence_of :contenido
  
  before_create :insertar_datos
  
  after_initialize :para_editar
  
  before_update :actualizar_datos
  
  protected
  
  def para_editar
    if self.archivos_adjuntos && self.archivos_adjuntos.any?
      self.ent_archivos=[]
      self.archivos_adjuntos.each do |obj_archivo|
        self.ent_archivos.push({ :id => obj_archivo.archivo_id, :file_name => obj_archivo.archivo.archivo_file_name, :value => obj_archivo.archivo_id })
      end
    end
  end
  
  def guardar_adjuntos
    self.archivos_adjuntos = []
    unless ent_archivos.nil? || ent_archivos.empty?
      ent_archivos.each do |archivo|
        if self.archivos_adjuntos.select{|i| i[:archivo_id] == BSON::ObjectId.from_string(archivo)}[0].nil? && query_archivo = Archivo.where(:_id => archivo).first
          self.archivos_adjuntos.push Embed::ArchivoAdjunto.new(:archivo => query_archivo)
        end
      end
    end
    
    # Busca archivos adjuntos dentro del contenido del bloque
    url = AppConfig.aplicacion.url.gsub(/[\/.]/,'/'=>'\\/','.'=>'[.]')
    pat = eval("/[\"']"+url+"\\/archivo\\/[0-9a-z]{24}[\"']|[\\/?\"']\\/archivo\\/[0-9a-z]{24}[\\/?\"']/i")
    self.contenido.scan(pat).each do |archivo|
      archivo = archivo[-25..-2]
      if self.archivos_adjuntos.select{|i| i[:archivo_id] == BSON::ObjectId.from_string(archivo)}[0].nil? && query_archivo = Archivo.where(:_id => archivo).first
        self.archivos_adjuntos.push Embed::ArchivoAdjunto.new(:archivo => query_archivo)
      end
    end
  end
  
  def insertar_datos
  
    guardar_adjuntos
    
    if self.publicado
      self.fecha_publicado = DateTime.now
    end
    
  end
  
  def actualizar_datos
    
    guardar_adjuntos
    
    if self.publicado && self.fecha_publicado.nil?
      self.fecha_publicado = DateTime.now
    end
    
  end
  
end