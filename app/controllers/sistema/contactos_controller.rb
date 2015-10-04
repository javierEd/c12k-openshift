class Sistema::ContactosController < ApplicationController

  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("sistema","contactos")'
  
  include ActionView::Helpers::UrlHelper
  
  def index
    if contactos = Contacto.all.sort('_id' => -1)
      filas = []
      contactos.each do |contacto|
        filas << [contacto.creado.fecha, contacto.remitente, contacto.asunto, link_to('Ver', sistema_contacto_path(contacto._id))]
      end
    else
      filas = nil
    end
    render :locals => { :contactos => filas }
  end
  
  def show
    @respuesta = ContactoRespuesta.new()
    render :locals => { :contacto => Contacto.find(params[:id]), respuestas: ContactoRespuesta.where(contacto_id: params[:id]).sort(_id: -1) }
  end
  
  def update
    @respuesta = ContactoRespuesta.new(params[:contacto_respuesta].merge({:tmp_vars => get_tmp_vars, contacto_id: params[:id]}))
    if @respuesta.save
      GenericMailer.generic_email(@respuesta.contacto.remitente, 'Re: '+@respuesta.contacto.asunto, @respuesta.mensaje).deliver_later
      respond_with @respuesta do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Mensaje enviado exitosamente.', _ubicacion: sistema_contactos_path } }
      end
    else
      campos={}
      @respuesta.errors.each do |error|
        campos[error]={_set: {error: @respuesta.errors[error]} }
      end
      respond_with @respuesta do |format|
        format.json {render :json => { _exito: false, _canterrores: @respuesta.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
end