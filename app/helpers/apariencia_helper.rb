module AparienciaHelper
  
  def abrir_acordion(titulo = nil, args = {})
    "<script type=\"text/javascript\">
      $(function(){
        $('.acordion').accordion({ collapsible: true,
          active: false,
          heightStyle: \"content\",
          icons: { \"header\": \"ui-icon-plus\", \"activeHeader\": \"ui-icon-minus\" }}
        );
      })
    </script>
    <div class=\"acordion\">".html_safe
  end
  
  def abrir_seccion_acordion(titulo, args = {})
    "<h3>".html_safe+titulo+"</h3><div>".html_safe
  end
  
  def cerrar_seccion_acordion
    "</div>".html_safe
  end
  
  def cerrar_acordion
    "</div>".html_safe
  end
  
  def abrir_seccion(titulo = nil, args = {})
    if titulo
      titulo = "<h3 style=\"font-size: 18px; font-weight: bold; margin: 0 0 10px;\">".html_safe+titulo+"</h3>".html_safe
    end
    "<div class=\"seccion\" style=\"margin: 15px 0px; border: 1px #ccc solid; border-radius: 5px; padding: 7px\">".html_safe + titulo.to_s
  end
  
  def cerrar_seccion
    "</div>".html_safe
  end
  
  def seccion(titulo = nil, args = {}, &block)
    seccion = abrir_seccion(titulo, args)
    seccion += capture &block
    seccion += cerrar_seccion
  end
  
  def acordion(titulo = nil, args = {}, &block)
    acordion = abrir_acordion titulo, args
    acordion += capture AcordionBuilder.new, &block
    acordion += cerrar_acordion
  end
  
  def seccion_acordion(titulo, args = {}, &block)
    seccion = abrir_seccion_acordion titulo, args
    seccion += capture &block
    seccion += cerrar_seccion_acordion
  end
  
  def rejilla_botones(titulo=nil, args = {}, &block)
    rejilla = '<div class="rejilla_botones">'.html_safe
    rejilla += capture &block
    rejilla += '</div>'.html_safe
  end
  
  def boton_enlace(titulo, enlace, args = {})
    link_to( ( args[:icono] ? fa_icon( args[:icono] + ( args[:tamanio] == 'grande' ? ' 5x' : ' lg fw' ) ) : '' ) +' '+ titulo, enlace, args.except(:icono, :tamanio).merge( :class => 'btn btn-default'+( args[:tamanio] && args[:tamanio] == ' grande' ? ' boton_grande' : '' ) ) )
  end
  
  def rejilla(titulos, args = {}, &block)
    rejilla = '<div class="rejilla"><div class="rejilla-titulos">'.html_safe
    titulos.each do |titulo|
      rejilla += '<div>'.html_safe + titulo + '</div>'.html_safe
    end
    rejilla += '</div><div class="rejilla-filas">'.html_safe
    rejilla += capture RejillaBuilder.new, &block
    rejilla += '</div></div>'.html_safe
  end
  
  class AcordionBuilder < ActionView::Base
    
    include AparienciaHelper
    
    def seccion(titulo, args = {}, &block)
      seccion_acordion(titulo, args, &block)
    end
    
  end
  
  class RejillaBuilder < ActionView::Base
  
    def fila(celdas, args = {})
      fila = '<div>'.html_safe
      celdas.each do |celda|
        fila += '<div>'.html_safe + celda + '</div>'.html_safe
      end
      fila += '</div>'.html_safe
    end
    
  end
  
end
