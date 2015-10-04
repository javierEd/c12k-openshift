 # To get information about the rols
module RolInfo

  # Return the name of the rol for the current user, or false if the user is not signed in
  # @return [String,Boolean]
  def current_cuenta_rol
    if cuenta_signed_in?
      current_cuenta.nombre_rol
    end
    false
  end
  
  # Return true if the rol for the current user is "administrador"
  # @return [Boolean,nil]
  def autenticar_administrador!
    if cuenta_signed_in? && current_cuenta.administrador
      true
    else
      redirect_to root_path
    end
  end
  
  def tiene_permiso?(grupo, controlador = nil)
    condiciones = { grupo: grupo }
    condiciones[:controlador] = controlador if controlador
    true if cuenta_signed_in? && (current_cuenta.administrador || current_cuenta.rol.permisos.where(condiciones ).exists? )
  end
  
  def autenticar_permiso!(grupo, controlador = nil)
    if tiene_permiso?(grupo, controlador)
      true
    else
      redirect_to root_path, alert: 'Usted no tiene permisos para acceder a esta sección.'
    end
  end
  
end