module FormHelper
  
  def form_clase
    unless resource.errors.empty?
      "tiene_errores"
    else
      ""
    end
  end
  
  def form_resumen_errores
    if resource.errors.empty?
      html = <<-HTML
      <div id=\"errores_#{resource_name}" class="resumen_errores"></div>
      HTML
    else
      sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)
      html = <<-HTML
      <div id=\"errores_#{resource_name}" class="resumen_errores">
        #{sentence}
      </div>
      HTML
    end
    html.html_safe
  end
  
  def form_campo_error!(nombre)
    unless resource.errors[nombre].empty?
      "<div class=\"msg_error\">#{resource.errors[nombre].join("<br/>")}</div>".html_safe
    else
      "<div class=\"msg_error\"></div>".html_safe
    end
  end
  
  def form_campo_error?(nombre)
    unless resource.errors[nombre].empty?
      true
    else
      false
    end
  end
  
  def form_campo(form,nombre,campo,params={})
    if form_campo_error?(nombre)
      campo_completo= "<div id=\"campo_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}\" class=\"tiene_errores\">".html_safe
    else
      campo_completo= "<div id=\"campo_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}\">".html_safe
    end
    unless campo=='check_box'
      if params[:label]
        campo_completo+= form.label(nombre,params[:label]) + '<br/>'.html_safe
      else
        campo_completo+= form.label(nombre) + '<br/>'.html_safe
      end
    end
    case campo
      when 'text_field'
        campo_completo+=form.text_field nombre, params.except(:label)
      when 'text_area'
        campo_completo+=form.text_area nombre, params.except(:label)
      when 'password_field'
        campo_completo+=form.password_field nombre, params.except(:label)
      when 'select'
        campo_completo+=form.select nombre, params[:opciones], {}, params.except(:opciones,:label)
      when 'check_box'
        campo_completo+=form.check_box(nombre, params.except(:label), 1, 0)+ ( params[:label] ? form.label(nombre,params[:label]) : form.label(nombre) )
      when 'date_field'
        # params[:date_separator] = '/'
        # params[:prompt] = {day: 'día', month: 'mes', year: 'año'}
        if params[:default]
          params[:value] = params[:default].to_s(:es)
        end
        params[:placeholder] = 'DD/MM/YYYY'
        campo_completo+="<script>
            $(document).ready(function(){
              $('##{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}').datepicker({
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                monthNames: #{t('date.month_names')[1..12]},
                monthNamesShort: #{t('date.abbr_month_names')[1..12]}
              });
            ".html_safe
        if params[:desde]
          campo_completo+="$('##{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}').datepicker( 'option', 'minDate', '#{params[:desde]}' );".html_safe
        end
        if params[:hasta]
          campo_completo+="$('##{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}').datepicker( 'option', 'maxDate', '#{params[:hasta]}' );".html_safe
        end
        if params[:yearRange]
          campo_completo+="$('##{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}').datepicker( 'option', 'yearRange', '#{params[:yearRange]}' );".html_safe
        end
        campo_completo+="});</script>".html_safe
        campo_completo+=form.text_field nombre, params.except(:label)
      when 'id_field'
        params[:class] = 'id_field'
        campo_completo+=form.select(nombre.to_s+'_cat', params[:categorias],{}, params.except(:categorias,:autocomplete,:label))+'-'+form.text_field(nombre, params.except(:categorias,:label))
      when 'cktext_area'
        campo_completo+=form.cktext_area nombre, params.except(:label)
      when 'file_field'
        if params[:ajax]
          campo_completo+="<div id=\"archivos_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}\">".html_safe
          if resource.send(nombre) && resource.send(nombre).any?
            resource.send(nombre).each do |ent_archivo|
              campo_completo+="<div id=\"archivo_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}_#{ent_archivo[:id]}\" class=\"archivo_subido\">
                  <span id=\"label_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}_#{ent_archivo[:id]}\">archivo subido</span>:
                    <b><a href=\"/archivo/#{ent_archivo[:id]}\" target=\"_blank\">#{ent_archivo[:file_name]}
                    <i class=\"fa fa-external-link\"></i></a></b>
                    <span id=\"ext_#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}_#{ent_archivo[:id]}\">
                    | <a href=\"#{edit_mi_cuenta_archivo_path(ent_archivo[:id])}\" target=\"_blank\">editar</a>
                    | <a href=\"javascript:formjs.remover_archivo('#{form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}','#{ent_archivo[:id]}')\">remover</a></span>".html_safe
              campo_completo+= form.hidden_field(nombre, :id => form.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")+'_'+nombre.to_s+'_'+ent_archivo[:id], :value=> ent_archivo[:value], :multiple => true)
              campo_completo+="</div>".html_safe
            end
          end
          campo_completo+="</div>".html_safe
        end
        campo_completo+=form.file_field nombre, params.except(:label)
    end
    campo_completo+=form_campo_error!(nombre) + '</div>'.html_safe
  end
  
  def select_paises(recursivo=false)
    paises=[['Seleccione','']]
    AppConfig.aplicacion.paises.each do |pais|
      paises << [pais['nombre'],pais['codigo']]
    end
    return paises
  end
  
  def select_tallas_camisas
    selec=[['Seleccione','']]
    AppConfig.aplicacion.tallas_camisas.each do |talla|
      selec << [talla,talla]
    end
    return selec
  end
  
  def confirmar_salida
    '<script type="text/javascript">
      $(document).ready(function(){confirmar_salida();});
    </script>'
  end
  
  class SFormBuilder < ActionView::Helpers::FormBuilder
    
    include I18n
    include ActionView::Helpers::TagHelper
    include FontAwesome::Rails::IconHelper
    include Rails.application.routes.url_helpers
    
    def iniciar_sformjs
      "<script type=\"text/javascript\">
        $(document).ready(function(){
          _sform['#{self.object_name.to_s}'] = new sform('#{self.object_name.to_s}'); 
          return _sform['#{self.object_name.to_s}'].constructor();
        });
      </script>".html_safe
    end
    
    def resumen_errores
      "<div id=\"errores_#{self.object_name.to_s}\" class=\"resumen_errores\"></div>".html_safe
    end
    
    def campo(tipo, nombre, args={})
      if args[:id]
        id = args[:id]
      else
        id = nombre
      end
      campo = "<div class=\"".html_safe + (tipo == 'checkbox' ? 'checkbox' : (tipo == 'radio' ? 'radio' : 'form-group') ) + "\" id=\"campo_#{self.object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}\">".html_safe
      if args[:class]
        args[:class] += (tipo != 'checkbox' && tipo != 'radio' ? " form-control" : "" )
      else
        args[:class] = (tipo != 'checkbox' && tipo != 'radio' ? "form-control" : "" )
      end
      unless tipo == 'checkbox'
        if args[:label]
          campo += self.label(nombre, args[:label], class: "control-label") + '<br/>'.html_safe
        else
          campo += self.label(nombre, class: "control-label") + '<br/>'.html_safe
        end
      end
      case tipo
        when 'texto'
          campo += self.text_field nombre, args.except(:label)
        when 'numerico'
          campo += self.number_field nombre, args.except(:label)
        when 'contrasenia'
          campo += self.password_field nombre, args.except(:label)
	      when 'areatexto'
          campo += self.text_area nombre, args.except(:label)
        when 'selec'
          campo += self.select nombre, args[:opciones], {}, args.except(:opciones,:label)
        when 'checkbox'
          campo += '<label>'.html_safe + self.check_box(nombre, args.except(:label), (args[:value] ? args[:value] : 1), 0) + (args[:label] ? args[:label] : nombre) + '</label>'.html_safe
        when 'fecha'
          # args[:date_separator] = '/'
          # args[:prompt] = {day: 'día', month: 'mes', year: 'año'}
#           if args[:default]
#             args[:value] = args[:default].to_s(:es)
#           end
          args[:placeholder] = 'DD/MM/YYYY'
          campo += "<script>
              $(document).ready(function(){
                $('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').datepicker({
                  dateFormat: 'dd/mm/yy',
                  changeMonth: true,
                  changeYear: true,
                  monthNames: #{I18n.t('date.month_names')[1..12]},
                  monthNamesShort: #{I18n.t('date.abbr_month_names')[1..12]}
                });
              ".html_safe
          if args[:desde]
            campo += "$('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').datepicker( 'option', 'minDate', '#{I18n.localize args[:desde]}' );".html_safe
          end
          if args[:hasta]
            campo += "$('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').datepicker( 'option', 'maxDate', '#{I18n.localize args[:hasta]}' );".html_safe
          end
          if args[:yearRange]
            campo += "$('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').datepicker( 'option', 'yearRange', '#{args[:yearRange]}' );".html_safe
          end
          campo += "if($('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').attr('value')){$('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').datepicker( 'setDate', new Date($('##{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}').attr('value').replace(/-/g,'/')));}".html_safe
          campo += "});</script>".html_safe
          campo += self.text_field nombre, args.except(:label,:yearRange,:desde,:hasta)
        when 'ckareatexto'
          campo += self.cktext_area nombre, args.except(:label)
        when 'archivo'
          if args[:ajax]
            campo += "<div id=\"archivos_#{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}\">".html_safe
          if self.object.send(nombre) && self.object.send(nombre).any?
            self.object.send(nombre).each do |ent_archivo|
              campo += "<div id=\"archivo_#{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}_#{ent_archivo[:id]}\" class=\"archivo_subido\">
                  <span id=\"label_#{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}_#{ent_archivo[:id]}\">archivo subido</span>:
                    <b><a href=\"/archivo/#{ent_archivo[:id]}\" target=\"_blank\">#{ent_archivo[:file_name]}
                    <i class=\"fa fa-external-link\"></i></a></b>
                    <span id=\"ext_#{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}_#{ent_archivo[:id]}\">
                    | <a href=\"#{edit_contenido_archivo_path(ent_archivo[:id])}\" target=\"_blank\">editar</a>
                    | <a href=\"javascript:formjs.remover_archivo('#{self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{id}','#{ent_archivo[:id]}')\">remover</a></span>".html_safe
              campo += self.hidden_field(nombre, :id => self.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")+'_'+id.to_s+'_'+ent_archivo[:id], :value=> ent_archivo[:value], :multiple => true)
              campo += "</div>".html_safe
            end
          end
          campo += "</div>".html_safe
        end
        campo += self.file_field nombre, args.except(:label)
      end
      campo += "<div class=\"msg_error\"></div></div>".html_safe
    end
    
    def campo_texto(nombre, args = {})
      campo 'texto', nombre, args
    end
    
    def campo_numerico(nombre, args = {})
      campo 'numerico', nombre, args
    end
    
    def campo_contrasenia(nombre, args = {})
      campo 'contrasenia', nombre, args
    end
    
    def campo_areatexto(nombre, args = {})
	    campo 'areatexto', nombre, args
    end
    
    def campo_selec(nombre, args = {})
      campo 'selec', nombre, args
    end
    def campo_checkbox(nombre, args = {})
      campo 'checkbox', nombre, args
    end
    def campo_fecha(nombre, args = {})
      campo 'fecha', nombre, args
    end

    def campo_ckareatexto(nombre, args = {})
      campo 'ckareatexto', nombre, args
    end
    
    def campo_archivo(nombre, args = {})
      campo 'archivo', nombre, args
    end
    
    def boton_enviar(nombre = 'enviar', valor = 'Enviar', icono = nil,args = {})
      boton = "<div style=\"text-align: center\" id=\"campo_#{self.object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{nombre}\">".html_safe
      icono = icono ? fa_icon(icono.to_s + ' lg fw')+' ' : ''
      boton += self.button icono+valor.html_safe, data: { disable_with: 'enviando...' }, class: "btn btn-primary"
      boton += "</div>".html_safe
    end
    
  end
  
end
