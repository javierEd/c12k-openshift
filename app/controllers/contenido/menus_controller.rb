class Contenido::MenusController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido","menus")'
  
  def index
    render :locals => { :menu_superior => Menu.where(:ubicacion => 1).first, :menu_inferior => Menu.where(:ubicacion => 2).first }
  end
  
end