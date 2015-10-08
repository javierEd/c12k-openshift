class InscripcionesController < ApplicationController
  
  before_action :autenticar_cupos!
  
  def new
    @inscripcion = Inscripcion.new
  end
    
  def create
    @inscripcion = Inscripcion.new(params[:inscripcion].merge({:tmp_vars => get_tmp_vars}))
    if @inscripcion.save # verify_recaptcha(:model => @inscripcion, :message => "Respuesta invalida") && 
      GenericMailer.generic_email(@inscripcion.email, AppConfig.aplicacion.titulo+' | Datos enviados exitosamente',
                                  '¡Bienvenid'.html_safe+(@inscripcion.genero == 1 ? 'o'.html_safe : 'a'.html_safe)+' '.html_safe+@inscripcion.nombres.titleize+' '.html_safe+@inscripcion.apellidos.titleize+"!<br/>
                                 <br/>
                                 Gracias por inscribirte en la Carrera 12K - Cumaná 500 Años.<br/>
                                 <br/>
                                 <b>Datos del corredor:</b><br/>
                                 Cédula de identidad o Pasaporte: #{@inscripcion.doc_id.upcase}<br/>
                                 Nombres: #{@inscripcion.nombres.titleize}<br/>
                                 Apellidos: #{@inscripcion.apellidos.titleize}<br/>
                                 Sexo: #{(@inscripcion.genero == 1 ? 'Masculino'.html_safe : 'Femenino'.html_safe)}<br/>
                                 Fecha de nacimiento: #{@inscripcion.fecha_nac.strftime('%d/%m/%Y')}<br/>
                                 Talla de camisa: #{@inscripcion.talla_camisa}<br/>
                                 Correo electrónico: #{@inscripcion.email.downcase}<br/>
                                 Teléfono movil: #{@inscripcion.tlf_movil}<br/>
                                 País: #{AppConfig.aplicacion.paises.select{|k| k['codigo']==@inscripcion.pais}[0]['nombre']}<br/>
                                 Estado: #{@inscripcion.estado.titleize}<br/>
                                 Categoria: #{@inscripcion.categoria}<br/>
                                 <br/>
                                 <b>Datos del pago:</b><br/>
                                 Tipo de transacción: #{@inscripcion.tipo_transaccion.capitalize}<br/>
                                 #{(@inscripcion.tipo_transaccion == 'transferencia' ? 'Banco de procedencia: '.html_safe+@inscripcion.desde_banco+'<br/>'.html_safe : '' )}
                                 Fecha de la transacción: #{@inscripcion.fecha_transaccion.strftime('%d/%m/%Y')}<br/>
                                 Nº de Deposito o Transferencia: #{@inscripcion.nro_transaccion}<br/>
                                 Información adicional de la transacción: #{@inscripcion.adicional_transaccion}<br/>
                                 <br/>
                                 En breve verificaremos todos sus datos y recibirá la confirmación de su inscripción.<br/>".html_safe).deliver_later
      respond_with @inscripcion do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Datos enviados exitosamente.', _ubicacion: root_path } }
      end
    else
      campos={}
      @inscripcion.errors.each do |error|
        campos[error]={_set: {error: @inscripcion.errors[error]} }
      end
      respond_with @inscripcion do |format|
        format.json {render :json => { _exito: false, _canterrores: @inscripcion.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
  def mostrar_categoria
    if params[:nil]
      edad = 0;
      edad_real = edad
    else
      edad = 2015 - params[:anio].to_i
      edad_real = edad
      edad_real = edad - 1 if params[:mes].to_i > DateTime.now.mon || (params[:mes].to_i == DateTime.now.mon && params[:dia].to_i > DateTime.now.mday)
    end
    
    if params[:discapacidad] == '1' && params[:silla_ruedas] == '1'
      categoria = 'Con silla de ruedas'
      silla_ruedas = {}
    elsif params[:discapacidad] == '1'
      categoria = 'Sin silla de ruedas'
      silla_ruedas = { _unset: { disabled: 1 } }
    else
      categoria = AppConfig.aplicacion.categorias.select{ |k| k['edad_minima'].to_i <= edad && k['edad_maxima'].to_i >= edad }[0]['nombre']
      silla_ruedas = { _set: { disabled: true }, _unset: { checked: 1 } }
    end
    
    arr = {
      _campos: {
        silla_ruedas: silla_ruedas,
        edad: { _set: { value: edad_real } },
        categoria: { _set: { value: categoria } }
      }
    }
    render :json => arr
  end
  
  def tipo_transaccion
    if params[:tipo] == 'transferencia'
      desde_banco = { _unset: { readonly: 1 } }
    else
      desde_banco = { _set: { value: '', readonly: true } }
    end
    
    arr = {
      _campos: {
        desde_banco: desde_banco
      }
    }
    render :json => arr
  end
  
end