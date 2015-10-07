class ComprobantesController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("inscritos","comprobantes")'
  
  #prawnto :prawn => { :top_margin => 75 }
  
  def new
    @inscripcion = Inscripcion.find(params[:inscrito_id])
    @comprobante = Comprobante.new
  end
  
  def create
    @inscripcion = Inscripcion.find(params[:inscrito_id])
    @comprobante = Comprobante.new(params[:comprobante].merge({:tmp_vars => get_tmp_vars, :inscripcion => @inscripcion}))
    if @comprobante.save
      GenericMailer.generic_email(@comprobante.inscripcion.email, AppConfig.aplicacion.titulo+' | Inscripción procesada',
                                  '¡Saludos '.html_safe+@comprobante.inscripcion.nombres.titleize+' '.html_safe+@comprobante.inscripcion.apellidos.titleize+"!<br/>
                                 <br/>
                                 Sus datos han sido procesados y aprobados.<br/>
                                 <br/>
                                 Recuerde descargar e imprimir el comprobante que se encuentra adjunto a este mensaje.".html_safe,
                                 :adjuntos => [{:nombre => 'comprobante.pdf', :contenido => comprobante(@comprobante)}] ).deliver_later
      respond_with @comprobante do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Datos enviados exitosamente.', _ubicacion: root_path } }
      end
    else
      campos={}
      @comprobante.errors.each do |error|
        campos[error]={_set: {error: @comprobante.errors[error]} }
      end
      respond_with @comprobante do |format|
        format.json {render :json => { _exito: false, _canterrores: @comprobante.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
  def mostrar_numero
    if params[:elite] == '1'
      nro = Comprobante.where(elite: true).count + 1
      if nro > 50
        nro = Comprobante.where(elite: false).count + 51
      end
    else
      nro = Comprobante.where(elite: false).count + 51
    end
    arr = {
      _campos: {
        ent_nro: { _set: { value: nro.to_s.rjust(4,"0") }  } 
      }
    }
    render :json => arr
  end
  
  def show
    send_data comprobante(Inscripcion.find(params[:inscrito_id]).comprobante), filename: 'comprobante.pdf', type: 'application/pdf'
  end
  
  protected
  
  def comprobante(comprobante)
    pdf = Prawn::Document.new
    pdf.image "public/inademus.jpg", :at => [0, 725], :scale => 0.16
    pdf.image "public/logo-reducido.jpg", :at => [410, 730], :scale => 0.21
    pdf.text "Alcaldía Bolivariana del Municipio Sucre", :align => :center, :size => 11
    pdf.text "Instituto Autónomo de Deporte del Municipio Sucre", :align => :center, :size => 11
    pdf.text "Cumaná - Estado Sucre", :align => :center, :size => 11
    pdf.text "Carrera 12K - Cumaná 500 Años", :align => :center, :size => 13, :style => :bold
    
    pdf.move_down 20
    
    pdf.text "COMPROBANTE DE INSCRIPCIÓN", :align => :center, :size => 14, :style => :bold
    
    pdf.move_down 10
    
    pdf.text "<font size='13'><color rgb='555555'>Nº del corredor:</color></font> <font size='24'><b>#{comprobante.nro.to_s.rjust(4,"0")}</b></font>", :align => :right, :inline_format => true
    
    pdf.move_down 20
    
    pdf.text "Datos del corredor".upcase, :style => :bold
    
    pdf.move_down 8
    
    pdf.text "Cédula de identidad o Pasaporte: <b>#{comprobante.inscripcion.doc_id.upcase}</b>", :inline_format => true
    pdf.text "Nombres: <b>#{comprobante.inscripcion.nombres.titleize}</b>", :inline_format => true
    pdf.text "Apellidos: <b>#{comprobante.inscripcion.apellidos.titleize}</b>", :inline_format => true
    pdf.text "Sexo: <b>#{(comprobante.inscripcion.genero == 1 ? 'Masculino' : 'Femenino')}</b>", :inline_format => true
    pdf.text "Fecha de Nacimiento: <b>#{comprobante.inscripcion.fecha_nac.strftime('%d/%m/%Y')}</b>", :inline_format => true
    pdf.text "Talla de camisa: <b>#{comprobante.inscripcion.talla_camisa}</b>", :inline_format => true
    
    pdf.text "Correo electrónico: <b>#{comprobante.inscripcion.email.downcase}</b>", :inline_format => true
    pdf.text "Teléfono movil: <b>#{comprobante.inscripcion.tlf_movil}</b>", :inline_format => true
    pdf.text "Teléfono fijo: <b>#{comprobante.inscripcion.tlf_fijo}</b>", :inline_format => true
    pdf.text "País: <b>#{AppConfig.aplicacion.paises.select{|k| k['codigo']==comprobante.inscripcion.pais}[0]['nombre']}</b>", :inline_format => true
    pdf.text "Estado: <b>#{comprobante.inscripcion.estado.titleize}</b>", :inline_format => true

    pdf.text "¿Posee alguna discapacidad?: <b>#{comprobante.inscripcion.discapacidad ? 'Si' : 'No'}</b>", :inline_format => true
    pdf.text "¿Posee silla de ruedas?: <b>#{comprobante.inscripcion.silla_ruedas ? 'Si' : 'No'}</b>", :inline_format => true
    
    if comprobante.inscripcion.discapacidad && comprobante.inscripcion.silla_ruedas
      categoria = 'Con silla de ruedas'
    elsif comprobante.inscripcion.silla_ruedas
      categoria = 'Sin silla de ruedas'
    else
      categoria = AppConfig.aplicacion.categorias.select{ |k| k['edad_minima'].to_i <= (2015 - comprobante.inscripcion.fecha_nac.year) && k['edad_maxima'].to_i >= (2015 - comprobante.inscripcion.fecha_nac.year) }[0]['nombre']
    end
    pdf.text "Categoria: <b>#{categoria}</b>", :inline_format => true
    
    pdf.move_down 20
    
    pdf.text "Datos del pago".upcase, :style => :bold
    
    pdf.move_down 8
    
    pdf.text "Tipo de transacción: <b>#{comprobante.inscripcion.tipo_transaccion.capitalize}</b>", :inline_format => true
    if comprobante.inscripcion.tipo_transaccion == 'transferencia'
      pdf.text "Banco de procedencia: <b>#{comprobante.inscripcion.desde_banco}</b>", :inline_format => true
    end
    pdf.text "Fecha de la transacción: <b>#{comprobante.inscripcion.fecha_transaccion.strftime('%d/%m/%Y')}</b>", :inline_format => true
    pdf.text "Nº de Deposito o Transferencia: <b>#{comprobante.inscripcion.nro_transaccion}</b>", :inline_format => true
    
    return pdf.render
  end
  
end