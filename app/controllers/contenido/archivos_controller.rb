class Contenido::ArchivosController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido","archivos")'
  
  def index
    render :locals => { :archivos => current_cuenta.persona.archivos.where(:borrado.exists => false).sort(:_id => -1) }
  end

  def new
    @archivo = Archivo.new
  end
  
  def create
    @archivo = Archivo.new({:archivo => params[:archivo], :tmp_vars => get_tmp_vars})
    if @archivo.save
      respond_with @archivo do |format|
        format.json {render :json => { _exito: true, _mensaje: 'archivo subido.', _archivo: @archivo, _campo_id: params[:campo_id], _tmp_id: params[:tmp_id], _edit_url: edit_contenido_archivo_path(@archivo._id) } }
      end
    else
      respond_with @archivo do |format|
        format.json {render :json => { _exito: false, _mensaje: @archivo.errors[:archivo], _campo_id: params[:campo_id], _tmp_id: params[:tmp_id] } }
      end
    end
  end
  
  def edit
    @archivo = current_cuenta.persona.archivos.where(:_id => params[:id],:borrado.exists => false).first
  end
  
  def update
    @archivo = current_cuenta.persona.archivos.where(:_id => params[:id],:borrado.exists => false).first
    @archivo.tmp_vars = get_tmp_vars
    if params[:archivo][:borrado] != '1'
      params[:archivo].delete(:borrado)
    end
    if @archivo.update_attributes(params[:archivo])
      respond_with @archivo do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Archivo editado exitosamente.', _ubicacion: contenido_archivos_path } }
      end
    else
      campos={}
      @archivo.errors.each do |error|
        campos[error]={_set: {error: @archivo.errors[error]} }
      end
      respond_with @archivo do |format|
        format.json {render :json => { _exito: false, _canterrores: @archivo.errors.count, _campos: campos} }
      end
    end
  end
  
end