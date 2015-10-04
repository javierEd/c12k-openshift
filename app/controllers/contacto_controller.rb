class ContactoController < ApplicationController
  
  def new
    @contacto = Contacto.new
  end
  
  def create
    @contacto = Contacto.new(params[:contacto].merge({:tmp_vars => get_tmp_vars}))
    if @contacto.save
      GenericMailer.generic_email(@contacto.remitente, AppConfig.aplicacion.titulo+' - Mensaje de contacto enviado', 'Gracias por escribirnos. Su mensaje será revisado y en breve recibirá una respuesta.<br/><br/>Remitante: '.html_safe+@contacto.remitente+'<br/>Asunto: '.html_safe+@contacto.asunto+'<br/>Mensaje:<br/>'.html_safe + @contacto.mensaje).deliver_later
      respond_with @contacto do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Mensaje enviado exitosamente.', _ubicacion: root_path } }
      end
    else
      @contacto.change_humanizer_question(params[:contacto][:humanizer_question_id])
      campos={ :humanizer_answer => { _set: {  } } }
      @contacto.errors.each do |error|
        campos[error]={_set: {error: @contacto.errors[error]} }
      end
      @contacto.change_humanizer_question(params[:contacto][:humanizer_question_id])
      campos[:humanizer_answer][:_set][:label] = @contacto.humanizer_question
      campos[:humanizer_answer][:_set][:value] = ''
      campos[:humanizer_question_id]= { :_set => {:value => @contacto.humanizer_question_id } }
      respond_with @contacto do |format|
        format.json {render :json => { _exito: false, _canterrores: @contacto.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
end