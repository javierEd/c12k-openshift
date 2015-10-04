class PersonasController < ApplicationController
  
  before_action :authenticate_cuenta!
  
  def buscarxciorif
    
    if /\A[VEJG]-[0-9]{1,8}(-[0-9]|){1}\z/.match(params[:ciorif])
      if persona = Persona.buscarxciorif(params[:ciorif])
        arr = { 
          _campos: {
            ent_doc_id: { _unset: { error: 1  } },
            ent_nombre: { _set: { value: persona[:nombre] } },
            ent_apellidos: { _set: { value: persona[:apellidos] } },
            ent_fecha_nac: { _set: { value: '' } },
            ent_sexo: { _set: { value: '' } },
            ent_email: { _set: { value: '' } }
          }
        }
      else
        arr = {  
          _campos: {
            ent_doc_id: { _unset: { error: 1  } },
            ent_nombre: { _set: { value: '' } },
            ent_apellidos: { _set: { value: '' } },
            ent_fecha_nac: { _set: { value: '' } },
            ent_sexo: { _set: { value: '' } },
            ent_email: { _set: { value: '' } }
          }
        }
      end
    else
      arr = { 
        _campos: {
          ent_doc_id: { _set: { error: (params[:ciorif]) ? 'no es v&aacute;lido' : 'no puede estar en blanco'  } },
          ent_nombre: { _set: { value: '' } },
          ent_apellidos: { _set: { value: '' } },
          ent_fecha_nac: { _set: { value: '' } },
          ent_sexo: { _set: { value: '' } },
          ent_email: { _set: { value: '' } }
        }
      }
    end
    render :json => arr
  end
  
end