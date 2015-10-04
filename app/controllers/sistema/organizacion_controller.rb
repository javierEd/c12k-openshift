class Sistema::OrganizacionController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("sistema","organizacion")'
  
  def index
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
end