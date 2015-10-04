class ContenidoController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido")'
  
  def index
  
  end
  
end