class Contenido::PostsController < ApplicationController
  
  before_action :authenticate_cuenta!
  before_action 'autenticar_permiso!("contenido","posts")'
  
  def index
    render :locals => { :posts => current_cuenta.persona.posts.where( :borrado.exists => false).sort(:_id => -1) }
  end
  
  def new
    @post = Post.new
  end
    
  def create
    if params[:post][:publicado] != '1'
      params[:post].delete(:publicado)
    end
    @post = Post.new(params[:post].merge( :tmp_vars => get_tmp_vars))
    if @post.save
      respond_with @post do |format|
        format.json {render :json => { _exito: true, _mensaje: 'post subido exitosamente.', _ubicacion: contenido_posts_path } }
      end
    else
      campos={}
      @post.errors.each do |error|
        campos[error]={_set: {error: @post.errors[error]} }
      end
      respond_with @post do |format|
        format.json {render :json => { _exito: false, _canterrores: @post.errors.count, _campos: campos} }
      end
    end
  end
  
  def edit
    @post = current_cuenta.persona.posts.where(:_id => params[:id],:borrado.exists => false).first
  end
    
  def update
    @post = current_cuenta.persona.posts.where(:_id => params[:id],:borrado.exists => false).first
    @post.tmp_vars = get_tmp_vars
    if params[:post][:publicado] != '1'
      @post.unset(:publicado)
    end
    if params[:post][:borrado] != '1'
      params[:post].delete(:borrado)
    end
    if @post.update_attributes(params[:post])
      respond_with @post do |format|
        format.json {render :json => { _exito: true, _mensaje: 'Post editado exitosamente.', _ubicacion: contenido_posts_path } }
      end
    else
      campos={}
      @post.errors.each do |error|
        campos[error]={_set: {error: @post.errors[error]} }
      end
      respond_with @post do |format|
        format.json {render :json => { _exito: false, _canterrores: @post.errors.count, _campos: campos} }
      end
    end
  end
  
end