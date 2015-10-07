class Cuenta
  include Mongoid::Base
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :rememberable, :registerable, :validatable
  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable
  
  belongs_to :rol, autosave: true
  belongs_to :persona, autosave: true
  
  attr_accessor :login, :ent_doc_id, :ent_nombre, :ent_apellidos, :ent_fecha_nac, :ent_sexo, :ent_email, :ent_rol, :solo_password #, :ent_pais, :entidad_federal, :localidad, :direccion, :terminos
  
  ## Database authenticatable
  field :username,            type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time
  
  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String
  
  field :administrador, type: Boolean
  
  validates_presence_of :username
  validates_length_of :username, minimum: 5, maximum: 20, allow_blank: true
  validates_format_of :username, :with => /\A[A-Za-z0-9_\-.]+\z/i, allow_blank: true, message: 'posee caracteres invalidos'
  validates_exclusion_of :username, :in => AppConfig.aplicacion.username_blacklist
  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :ent_rol, unless: 'administrador || solo_password'
  
  validates_presence_of :ent_doc_id, unless: 'administrador || solo_password'
  validates_presence_of :ent_nombre, unless: 'administrador || solo_password'
  validates_presence_of :ent_apellidos, unless: 'administrador || solo_password'
  validates_presence_of :ent_email, unless: 'administrador || solo_password'
  
  # validates_uniqueness_of :administrador        # Solo puede haber un administrador
  
  before_create :insertar_datos, unless: 'administrador'
  
  def nombre_rol
    if self.administrador
      'Administrador'
    else
      self.rol.nombre
    end
  end
  
#   def email
#     unless self.administrador
#       self.persona.email
#     else
#       ''
#     end
#   end
  
  def email_required?
    false
  end
  
  def email_changed?
    false
  end
  
  def anonimo
    true
  end
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login).downcase
      where(conditions).where({:username => /^#{Regexp.escape(login)}$/i}).first
    else
      where(conditions).first
    end
  end
  
  def update_password(params, *options)
    solo_password = true
    
    current_password = params.delete(:current_password)

    result = if valid_password?(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end
  
  protected
  
  def insertar_datos
    self.rol = Rol.find(self.ent_rol)
    
    self.persona = Persona.new
    self.persona.tmp_vars = self.tmp_vars
    self.persona.username = self.username
    self.persona.ent_doc_id = self.ent_doc_id
    self.persona.nombre = self.ent_nombre
    self.persona.apellidos = self.ent_apellidos
    self.persona.fecha_nac = self.ent_fecha_nac
    self.persona.sexo = self.ent_sexo
    self.persona.ent_email = self.ent_email
  end
  
end
