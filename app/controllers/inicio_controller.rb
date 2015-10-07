class InicioController < ApplicationController
  
  def index
    if params[:pag] && params[:pag].to_i > 0
      pag=params[:pag].to_i
    else
      pag=1
    end
    if pag == 1
      anterior = nil
    else
      anterior = pag - 1
    end
    posts = Post.where(:publicado => true, :borrado.exists => false, :bloqueado.exists => false)
    if posts.count.to_f/AppConfig.aplicacion.posts.por_pagina.to_f <= pag
      siguiente = nil
    else
      siguiente = pag + 1
    end
    etiquetas = Etiqueta.where(:borrado.exists => false, :bloqueado.exists => false).sort('_id' => -1).limit(10)
    render :locals => { :pagina => Alias.where(ruta: 'root').first, :posts => posts
                .sort(:fecha_publicado => -1).skip((pag-1)*AppConfig.aplicacion.posts.por_pagina.to_i).limit(AppConfig.aplicacion.posts.por_pagina.to_i),
      :anterior => anterior, :siguiente => siguiente, :etiquetas => etiquetas }
  end
  
  
  def perfil
    if persona = Persona.where(:username => params[:usuario], :borrado.exists => false, :suspendido.exists => false).only(:_id, :username).first
      if params[:pag] && params[:pag].to_i > 0
        pag=params[:pag].to_i
      else
        pag=1
      end
      if pag == 1
        anterior = nil
      else
        anterior = pag - 1
      end
      if persona.posts.where(:publicado => true, :borrado.exists => false, :bloqueado.exists => false).count.to_f/AppConfig.aplicacion.posts.por_pagina.to_f <= pag
        siguiente = nil
      else
        siguiente = pag + 1
      end
      render :locals => { :perfil => persona,
        :posts => persona.posts.where(:publicado => true, :borrado.exists => false, :bloqueado.exists => false)
                  .sort(:fecha_publicado => -1).skip((pag-1)*AppConfig.aplicacion.posts.por_pagina.to_i).limit(AppConfig.aplicacion.posts.por_pagina.to_i),
        :anterior => anterior, :siguiente => siguiente }
    end
  end
  
  def etiqueta
    if etiqueta = Etiqueta.where(:nombre => params[:consulta].strip.downcase).first
      if params[:pag] && params[:pag].to_i > 0
        pag=params[:pag].to_i
      else
        pag=1
      end
      if pag == 1
        anterior = nil
      else
        anterior = pag - 1
      end
      if Post.where(:etiqueta_ids => etiqueta._id,:publicado => true, :borrado.exists => false, :bloqueado.exists => false).count.to_f/AppConfig.aplicacion.posts.por_pagina.to_f <= pag
        siguiente = nil
      else
        siguiente = pag + 1
      end
      render :locals => { :etiqueta => etiqueta,
        :posts => Post.where(:etiqueta_ids => etiqueta._id,:publicado => true, :borrado.exists => false, :bloqueado.exists => false)
                  .sort(:fecha_publicado => -1).skip((pag-1)*AppConfig.aplicacion.posts.por_pagina.to_i).limit(AppConfig.aplicacion.posts.por_pagina.to_i),
        :anterior => anterior, :siguiente => siguiente }
    end
  end
  
  def buscar
    
  end
  
  def post
    if post = Post.where(:_id=> params[:id], :publicado => true, :borrado.exists => false, :bloqueado.exists => false).first
      arr_id_etiquetas = []
      post.etiquetas.each do |etiqueta|
        arr_id_etiquetas << etiqueta._id
      end
      relacionados = Post.where(:publicado => true, :borrado.exists => false, :bloqueado.exists => false, :_id.ne => post._id, :etiqueta_ids.in => arr_id_etiquetas )
      .sort(:fecha_publicado => -1).limit(AppConfig.aplicacion.posts.por_pagina.to_i)
      render :locals => { :post => post, :relacionados => relacionados }
    end
  end
  
  def archivo
    if archivo = Archivo.where(:_id => params[:id], :borrado.exists => false, :bloqueado.exists => false).first
      if params[:descargar]
        # response.headers['Content-Type'] = archivo.tipo
        # response.headers['Content-Disposition'] = 'attachment; filename="'+archivo.nombre+'"'
        # response.headers['Content-Length'] = archivo.tamanio
        # render :text => archivo.abrir
        send_file(AppConfig.aplicacion.archivos.directorio+"/"+archivo._id, filename: archivo.nombre, type: archivo.tipo, disposition: 'attachment')
      elsif params[:ver] && archivo.tipo == 'application/pdf'
        # response.headers['Content-Type'] = archivo.tipo
        # response.headers['Content-Disposition'] = 'inline; filename="'+archivo.nombre+'"'
        # response.headers['Content-Length'] = archivo.tamanio
        # render :text => archivo.abrir
        send_file(AppConfig.aplicacion.archivos.directorio+"/"+archivo._id, filename: archivo.nombre, type: archivo.tipo, disposition: 'inline')
      else
        tipos_aceptados = request.env['HTTP_ACCEPT'].split(",")
        if tipos_aceptados.include?("text/html") || tipos_aceptados.include?("application/xhtml+xml")
          render :locals => { archivo_url: '/archivo/'+archivo._id, archivo: archivo }
        else
          # response.headers['Content-Type'] = archivo.tipo
          # response.headers['Content-Disposition'] = 'inline; filename="'+archivo.nombre+'"'
          # response.headers['Content-Length'] = archivo.tamanio
          # render :text => archivo.abrir
          send_file(AppConfig.aplicacion.archivos.directorio+"/"+archivo._id, filename: archivo.nombre, type: archivo.tipo, disposition: 'inline')
        end
      end
    end 
  end
  
  def alias
    if a = Alias.where(ruta: params[:alias]).first
      if a.post
        arr_id_etiquetas = []
        a.post.etiquetas.each do |etiqueta|
          arr_id_etiquetas << etiqueta._id
        end
        relacionados = Post.where(:publicado => true, :borrado.exists => false, :bloqueado.exists => false, :_id.ne => a.post._id, :etiqueta_ids.in => arr_id_etiquetas )
        render 'post', :locals => { :post => a.post, :relacionados => relacionados }
      elsif a.archivo
        if params[:descargar]
          # response.headers['Content-Type'] = archivo.tipo
          # response.headers['Content-Disposition'] = 'attachment; filename="'+archivo.nombre+'"'
          # response.headers['Content-Length'] = archivo.tamanio
          # render :text => archivo.abrir
          send_file(AppConfig.aplicacion.archivos.directorio+"/"+a.archivo._id, filename: a.archivo.nombre, type: a.archivo.tipo, disposition: 'attachment')
        elsif params[:ver] && archivo.tipo == 'application/pdf'
          # response.headers['Content-Type'] = archivo.tipo
          # response.headers['Content-Disposition'] = 'inline; filename="'+archivo.nombre+'"'
          # response.headers['Content-Length'] = archivo.tamanio
          # render :text => archivo.abrir
          send_file(AppConfig.aplicacion.archivos.directorio+"/"+a.archivo._id, filename: a.archivo.nombre, type: a.archivo.tipo, disposition: 'inline')
        else
          tipos_aceptados = request.env['HTTP_ACCEPT'].split(",")
          if tipos_aceptados.include?("text/html") || tipos_aceptados.include?("application/xhtml+xml")
            render 'archivo', :locals => { archivo_url: '/archivo/'+a.archivo._id, archivo: a.archivo }
          else
            # response.headers['Content-Type'] = archivo.tipo
            # response.headers['Content-Disposition'] = 'inline; filename="'+archivo.nombre+'"'
            # response.headers['Content-Length'] = archivo.tamanio
            # render :text => archivo.abrir
            send_file(AppConfig.aplicacion.archivos.directorio+"/"+a.archivo._id, filename: a.archivo.nombre, type: a.archivo.tipo, disposition: 'inline')
          end
        end
      end
    end
  end
  
end