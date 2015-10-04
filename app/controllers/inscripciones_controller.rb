class InscripcionesController < ApplicationController
  
  def index
    
  end
  
  def new
    @inscripcion = Inscripcion.new
  end
    
  def create
    @inscripcion = Inscripcion.new(params[:inscripcion].merge({:tmp_vars => get_tmp_vars}))
    if @inscripcion.save
      GenericMailer.generic_email(@inscripcion.email, AppConfig.aplicacion.titulo+' - Datos enviados exitosamente',
                                  '¡Bienvenid'.html_safe+(@inscripcion.genero == 1 ? 'o'.html_safe : 'a'.html_safe)+' '.html_safe+@inscripcion.nombres+' '.html_safe+@inscripcion.apellidos+'!<br/>
                                 <br/>
                                 Gracias por inscribirte en la carrera 12K Cumaná 500 Años.<br/>
                                 En breve verificaremos todos sus datos y recibirá la confirmación de su inscripción.<br/>'.html_safe).deliver_later
      respond_with @inscripcion do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Datos enviados exitosamente.', _ubicacion: root_path } }
      end
    else
      @inscripcion.change_humanizer_question(params[:inscripcion][:humanizer_question_id])
      campos={ :humanizer_answer => { _set: {  } } }
      @inscripcion.errors.each do |error|
        campos[error]={_set: {error: @inscripcion.errors[error]} }
      end
      @inscripcion.change_humanizer_question(params[:inscripcion][:humanizer_question_id])
      campos[:humanizer_answer][:_set][:label] = @inscripcion.humanizer_question
      campos[:humanizer_answer][:_set][:value] = ''
      campos[:humanizer_question_id]= { :_set => {:value => @inscripcion.humanizer_question_id } }
      respond_with @inscripcion do |format|
        format.json {render :json => { _exito: false, _canterrores: @inscripcion.errors.count, _campos: campos
          }
        }
      end
    end
  end
  
  def mostrar_categoria
    # edad = Date.new(2015,12,31) - Date.new(params[:anio].to_i,params[:mes].to_i,params[:dia].to_i)
    if params[:nil]
      edad = 0;
    else
      edad = 2015 - params[:anio].to_i
    end
    if params[:silla_ruedas] == '1'
      categoria = 'Con silla de ruedas'
    else
      categoria = AppConfig.aplicacion.categorias.select{ |k| k['edad_minima'].to_i <= edad && k['edad_maxima'].to_i >= edad }[0]['nombre']
      #categoria = 'Sin silla de ruedas'
    end
    edad_real = edad
    # edad_real = edad - 1 if params[:mes].to_i > Month.now || 
    arr = {
      _campos: {
        edad: { _set: { value: edad_real } },
        categoria: { _set: { value: categoria } }
      }
    }
    render :json => arr
  end
  
end