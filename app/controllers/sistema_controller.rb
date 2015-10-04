class SistemaController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("sistema")'
  
  def index
    
  end
  
end