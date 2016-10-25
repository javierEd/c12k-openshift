class Inscripcion
  include Mongoid::Base
  # include Humanizer
  
  # require_human_on :create
  
  attr_accessor :edad, :categoria ,:ent_terminos, :ent_liberacion
  
  field :doc_id, type: String
  field :nombres, type: String
  field :apellidos, type: String
  field :genero, type: Integer
  field :fecha_nac, type: Date
  field :talla_camisa, type: String
  field :discapacidad, type: Boolean
  field :silla_ruedas, type: Boolean
  
  field :email, type: String
  field :tlf_movil, type: String
  field :tlf_fijo, type: String
  field :pais, type: String
  field :estado, type: String
  
  field :tipo_transaccion, type: String
  field :desde_banco, type: String
  field :fecha_transaccion, type: Date
  field :nro_transaccion, type: String
  field :adicional_transaccion, type: String
  
  validates_presence_of :doc_id
  validates_format_of :doc_id, :with => /\A[a-zA-Z0-9]{1,}\z/, allow_blank: true, message: 'Solo se permiten letras y números'
  validates_uniqueness_of :doc_id, :case_sensitive => false
  validates_presence_of :nombres
  validates_presence_of :apellidos
  validates_presence_of :genero
  validates_inclusion_of :genero, :in => [ 1, 2 ], allow_blank: true
  validates_presence_of :fecha_nac
  # validates_format_of :fecha_nac, :with => /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/, allow_blank: true
  
  validates_presence_of :talla_camisa
  validates_inclusion_of :talla_camisa, :in => AppConfig.aplicacion.tallas_camisas, allow_blank: true
  
  validates_presence_of :discapacidad, :if => 'silla_ruedas'
  
  
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  validates_presence_of :tlf_movil
  validates_format_of :tlf_movil, :with => /\A[0-9]{1,}\z/, allow_blank: true, message: 'Solo se permiten números'
  validates_format_of :tlf_fijo, :with => /\A[0-9]{1,}\z/, allow_blank: true, message: 'Solo se permiten números'
  
  validates_presence_of :pais
  # validates_inclusion_of :pais, :in => AppConfig.aplicacion.paises, allow_blank: true
  validates_presence_of :estado
  
  validates_presence_of :tipo_transaccion
  validates_presence_of :desde_banco, if: 'tipo_transaccion == "transferencia"'
  validates_presence_of :fecha_transaccion
  # validates_format_of :fecha_transaccion, :with => /\A[0-9]{2}\/[0-9]{2}\/[0-9]{4}\z/, allow_blank: true
  validates_presence_of :nro_transaccion
  validates_format_of :nro_transaccion, :with => /\A[0-9]{1,}\z/, allow_blank: true, message: 'Solo se permiten números'
  validates_uniqueness_of :nro_transaccion
  
  validates_acceptance_of :ent_terminos
  validates_acceptance_of :ent_liberacion
  
  validate :validar_edad
  
  has_one :comprobante
  
  def validar_edad
    if fecha_nac && Date.parse(fecha_nac.to_s).year > 1999
      errors.add(:fecha_nac, "Debes tener 16 años o al menos cumplirlos en lo que queda de año")
    end
  end
  
end