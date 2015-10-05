class Inscripcion
  include Mongoid::Base
  include Humanizer
  
  require_human_on :create
  
  attr_accessor :edad, :categoria ,:ent_terminos, :ent_liberacion
  
  field :doc_id, type: String
  field :nombres, type: String
  field :apellidos, type: String
  field :genero, type: Integer
  field :fecha_nac, type: Date
  field :talla_camisa, type: String
  
  field :email, type: String
  field :tlf_movil, type: String
  field :tlf_fijo, type: String
  field :pais, type: String
  field :estado, type: String
  
  field :silla_ruedas, type: Boolean
  # field :edad, type: String
  # field :categoria, type: String
  
  field :tipo_transaccion, type: String
  field :fecha_transaccion, type: Date
  field :nro_transaccion, type: String
  field :adicional_transaccion, type: String
  
  validates_presence_of :doc_id
  validates_uniqueness_of :doc_id, :case_sensitive => false
  validates_presence_of :nombres
  validates_presence_of :apellidos
  validates_presence_of :genero
  validates_presence_of :fecha_nac
  
  validates_presence_of :talla_camisa
  
  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true
  validates_presence_of :tlf_movil
  validates_presence_of :pais
  validates_presence_of :estado
  
  validates_presence_of :tipo_transaccion
  validates_presence_of :fecha_transaccion
  validates_presence_of :nro_transaccion
  validates_uniqueness_of :nro_transaccion
  
  validates_acceptance_of :ent_terminos
  validates_acceptance_of :ent_liberacion
  
end