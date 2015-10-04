class Sistema::RolesController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("sistema","roles")'
  
  def index
    render :locals => { :roles => Rol.all }
    p params[:controller]
  end
  
  def new
    @rol = Rol.new
  end
  
  def create
    @rol = Rol.new(params[:rol].merge({:tmp_vars => get_tmp_vars}))
    if @rol.save
      respond_with @rol do |format|
          format.json {render :json => { _exito: true, _mensaje: 'Rol creado exitosamente.', _ubicacion: sistema_roles_path } }
        end
    else
      campos={}
      @rol.errors.each do |error|
        campos[error]={_set: {error: @rol.errors[error]} }
      end
      respond_with @rol do |format|
        format.json {render :json => { _exito: false, _canterrores: @rol.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
  def edit
    @rol = Rol.find(params[:id])
  end
  
  def update
    @rol = Rol.find(params[:id])
    @rol.tmp_vars = get_tmp_vars
    if @rol.update_attributes(params[:rol])
      respond_with @rol do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Rol editado exitosamente.', _ubicacion: sistema_roles_path } }
      end
    else
      campos={}
      @rol.errors.each do |error|
        campos[error]={_set: {error: @rol.errors[error]} }
      end
      respond_with @rol do |format|
        format.json {render :json => { _exito: false, _canterrores: @rol.errors.count, _campos: campos} }
      end
    end
  end
  
end