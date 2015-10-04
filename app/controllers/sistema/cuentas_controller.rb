class Sistema::CuentasController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("sistema","cuentas")'
  
  def index
    render :locals => { :cuentas => Cuenta.where(:administrador.exists => false) }
  end
  
  def new
    @cuenta = Cuenta.new
  end
  
  def create
    @cuenta = Cuenta.new(params[:cuenta].merge(tmp_vars: get_tmp_vars))
    if @cuenta.save
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Cuenta creada exitosamente.', _ubicacion: sistema_cuentas_path } }
      end
    else
      campos={}
      @cuenta.errors.each do |error|
        campos[error]={_set: {error: @cuenta.errors[error]} }
      end
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: false, _canterrores: @cuenta.errors.count, _campos: campos} }
      end
    end
  end
  
  def edit
    @cuenta = Cuenta.where(:id => params[:id]).first
  end
  
  def update
    @cuenta = Cuenta.where(:_id => params[:id]).first
    @cuenta.tmp_vars = get_tmp_vars
    if params[:cuenta][:password].blank?
      params[:cuenta].delete(:password)
      params[:cuenta].delete(:password_confirmation) if params[:cuenta][:password_confirmation].blank?
    end
    if params[:cuenta][:suspendido] != '1'
      params[:cuenta].delete(:suspendido)
    end
    if @cuenta.update_attributes(params[:cuenta])
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Cuenta editada exitosamente.', _ubicacion: administracion_cuentas_path } }
      end
    else
      campos={}
      @cuenta.errors.each do |error|
        campos[error]={_set: {error: @cuenta.errors[error]} }
      end
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: false, _canterrores: @cuenta.errors.count, _campos: campos} }
      end
    end
  end
  
end