class Contenido::BloquesController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido","bloques")'
  
  def index
    render :locals => { :bloques => Bloque.where( :borrado.exists => false).sort(:_id => -1) }
  end
  
  def new
    @bloque = Bloque.new
  end
  
  def create
    if params[:bloque][:publicado] != '1'
      params[:bloque].delete(:publicado)
    end
    @bloque = Bloque.new(params[:bloque].merge( :tmp_vars => get_tmp_vars))
    if @bloque.save
      respond_with @bloque do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Bloque subido exitosamente.', _ubicacion: contenido_bloques_path } }
      end
    else
      campos={}
      @bloque.errors.each do |error|
        campos[error]={_set: {error: @bloque.errors[error]} }
      end
      respond_with @bloque do |format|
        format.json {render :json => { _exito: false, _canterrores: @bloque.errors.count, _campos: campos} }
      end
    end
  end
  
  def edit
    @bloque = Bloque.where(:_id => params[:id],:borrado.exists => false).first
  end
  
  def update
    @bloque = Bloque.where(:_id => params[:id],:borrado.exists => false).first
    @bloque.tmp_vars = get_tmp_vars
    if params[:bloque][:publicado] != '1'
      @bloque.unset(:publicado)
    end
    if params[:bloque][:borrado] != '1'
      params[:bloque].delete(:borrado)
    end
    if @bloque.update_attributes(params[:bloque])
      respond_with @bloque do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Bloque editado exitosamente.', _ubicacion: contenido_bloques_path } }
      end
    else
      campos={}
      @bloque.errors.each do |error|
        campos[error]={_set: {error: @bloque.errors[error]} }
      end
      respond_with @bloque do |format|
        format.json {render :json => { _exito: false, _canterrores: @bloque.errors.count, _campos: campos} }
      end
    end
  end
  
end