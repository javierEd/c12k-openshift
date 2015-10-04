class Contenido::ElementosController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido","elementos")'
  
  def new
    @elemento_menu = Embed::ElementoMenu.new
  end
  
  def create
    @elemento_menu = Embed::ElementoMenu.new(params[:embed_elemento_menu])
    menu = Menu.where(ubicacion: params[:menu_id]).first
    unless menu
      menu = Menu.new(ubicacion: params[:menu_id])
    end
    menu.tmp_vars = get_tmp_vars
    menu.elementos << @elemento_menu
    if menu.save
      respond_with @elemento_menu do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Elemento subido exitosamente.', _ubicacion: contenido_menus_path } }
      end
    else
      campos={}
      @elemento_menu.errors.each do |error|
        campos[error]={_set: {error: @elemento_menu.errors[error]} }
      end
      respond_with @elemento_menu do |format|
        format.json {render :json => { _exito: false, _canterrores: @elemento_menu.errors.count, _campos: campos} }
      end
    end
  end
  
  def edit
    menu = Menu.where(ubicacion: params[:menu_id]).first
    @elemento_menu = menu.elementos.where(_id: params[:id]).first
  end
  
  def update
    menu = Menu.where(ubicacion: params[:menu_id]).first
    menu.tmp_vars = get_tmp_vars
    @elemento_menu = menu.elementos.where(_id: params[:id]).first
    if params[:embed_elemento_menu][:borrado] != '1'
      params[:embed_elemento_menu].delete(:borrado)
    end
    if @elemento_menu.update_attributes(params[:embed_elemento_menu])
      respond_with @elemento_menu do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Elemento editado exitosamente.', _ubicacion: contenido_menus_path } }
      end
    else
      campos={}
      @elemento_menu.errors.each do |error|
        campos[error]={_set: {error: @elemento_menu.errors[error]} }
      end
      respond_with @elemento_menu do |format|
        format.json {render :json => { _exito: false, _canterrores: @elemento_menu.errors.count, _campos: campos} }
      end
    end
  end
  
end