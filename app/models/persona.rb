class Persona
  include Mongoid::Base
  
  attr_accessor :ent_doc_id, :ent_email
  
  has_one :cuenta
  
  field :username, type: String
  field :nombre_mostrar, type: String
  
  embeds_many :docs_id, class_name: 'Embed::DocId'
  field :nombre, type: String
  field :apellidos, type: String
  field :fecha_nac, type: Date
  field :sexo, type: Integer, default: 0 # O: no especifica, 1: hombre, 2: mujer
  
  has_many :emails, autosave: true
  # has_many :telefonos, autosave: true
  
  has_many :posts
  has_many :archivos
  
  belongs_to :pais
  belongs_to :estado
  belongs_to :municipio
  belongs_to :localidad
  belongs_to :parroquia
  
  field :direccion, type: String

  before_create :insertar_datos
  
  def email
    self.emails.where(principal => true)
  end
  
  def self.buscarxciorif(ciorif)
    ciorif = ciorif.split('-')
    
    datos_locales = where('docs_id.cat' => ciorif[0], 'docs_id.nro' => ciorif[1]).first
    
    if datos_locales
      
      return { nombre: datos_locales[:nombre], apellidos: datos_locales[:apellidos]}
      
    else
    
      datos = Net::HTTP.get(URI.parse("http://www.cne.gob.ve/web/registro_civil/buscar_rep.php?nac=#{ciorif[0]}&ced=#{ciorif[1]}")).match(/<b>[a-z A-Z]*<\/b>/)
      
      if datos
        
        arr_nombre = datos.to_s[3..-5].split(' ')
        
        if arr_nombre.length > 2
          nombre = ''
          for i in 0..(arr_nombre.length - 3)
            nombre += arr_nombre[i]
            if i < arr_nombre.length - 3
              nombre += ' '
            end
          end
          apellidos = arr_nombre[-2]+' '+arr_nombre[-1]
        else
          nombre = arr_nombre[0]
          apellidos = arr_nombre[1]
        end
        return { nombre: nombre , apellidos: apellidos }
        
      end
    
    end
    
    return false
  end
  
  protected
  
  def insertar_datos
    arr_doc_id = self.ent_doc_id.split('-')
    
    self.docs_id = [Embed::DocId.new(ent_doc_id: self.ent_doc_id, cat: arr_doc_id[0], nro: arr_doc_id[1] )]
    
    self.emails = [Email.new(email: self.ent_email, principal: true, tmp_vars: self.tmp_vars)]
  end
  
end