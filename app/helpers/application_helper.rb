module ApplicationHelper

  include RolInfo
  
  def titulo
    AppConfig.aplicacion.titulo.present? ? AppConfig.aplicacion.titulo.html_safe : 'Sistema de Reportes'.html_safe
  end
  
  def resumen
    AppConfig.aplicacion.resumen.present? ? AppConfig.aplicacion.resumen.html_safe : ''.html_safe
  end
  
  def banner_src
    AppConfig.aplicacion.banner_src.present? ? AppConfig.aplicacion.banner_src : false
  end
  
  def obt_menu_superior
    menu = Menu.where(ubicacion: 1).first
    if menu && menu.elementos.where(:borrado.exists => false)
      menu.elementos.where(:borrado.exists => false).sort(:posicion => 1)
    else
      []
    end  
  end
  
  def obt_menu_inferior
    menu = Menu.where(ubicacion: 2).first
    if menu && menu.elementos.where(:borrado.exists => false)
      menu.elementos.where(:borrado.exists => false).sort(:posicion => 1)
    else
      []
    end  
  end
  
  def bloque_existe?(ubicacion)
    return true if (ubicacion == 'sup' && Bloque.where(ubicacion: 'sup', :publicado => true, :borrado.exists => false).any?) ||
        (ubicacion == 'izq' && Bloque.where(ubicacion: 'izq', :publicado => true, :borrado.exists => false).any?) ||
        (ubicacion == 'pri' && Bloque.where(ubicacion: 'pri', :publicado => true, :borrado.exists => false).any?) ||
        (ubicacion == 'der' && Bloque.where(ubicacion: 'der', :publicado => true, :borrado.exists => false).any?) ||
        (ubicacion == 'inf' && Bloque.where(ubicacion: 'inf', :publicado => true, :borrado.exists => false).any?)
  end
  
  def obt_bloques(ubicacion)
    case ubicacion
      when 'sup'
        Bloque.where(ubicacion: 'sup', :publicado => true, :borrado.exists => false).sort(:posicion => 1)
      when 'izq'
        Bloque.where(ubicacion: 'izq', :publicado => true, :borrado.exists => false).sort(:posicion => 1)
      when 'pri'
        Bloque.where(ubicacion: 'pri', :publicado => true, :borrado.exists => false).sort(:posicion => 1)
      when 'der'
        Bloque.where(ubicacion: 'der', :publicado => true, :borrado.exists => false).sort(:posicion => 1)
      when 'inf'
        Bloque.where(ubicacion: 'inf', :publicado => true, :borrado.exists => false).sort(:posicion => 1)
    else
      Bloque.where().sort(:posicion => 1)
    end
  end
  
  def opciones_roles
    opciones = [['Seleccione', '']]
    Rol.all.each do |rol|
      opciones << [rol.nombre, rol._id]
    end
    return opciones
  end
  
end
