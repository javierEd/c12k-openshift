class MiCuenta::ContraseniaController < ApplicationController
  
  before_action :authenticate_cuenta!
  
  def edit
    @cuenta = current_cuenta
  end
  
  def update
    @cuenta = current_cuenta
    if @cuenta.update_password(params.require(:cuenta).permit(:current_password, :password, :password_confirmation).merge(tmp_vars: get_tmp_vars) )
      sign_in @cuenta, :bypass => true
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Contraseña cambiada exitosamente.', _ubicacion: root_path } }
      end
    else
      campos={ }
      @cuenta.errors.each do |error|
        campos[error]={_set: {error: @cuenta.errors[error]} }
      end
      respond_with @cuenta do |format|
        format.json {render :json => { _exito: false, _canterrores: @cuenta.errors.count, _campos: campos
          }
        }
      end
    end
  end
    
end