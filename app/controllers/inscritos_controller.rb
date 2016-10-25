class InscritosController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("inscritos")'
  
  def index
    render locals: { inscritos: Inscripcion.all.sort('_id' => -1), nro_inscritos: Inscripcion.count, nro_comprobantes: Comprobante.count }
  end
  
end