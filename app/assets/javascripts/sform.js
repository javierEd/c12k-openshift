
function confirmar_salida(){
  function confirmExit(){
    return "Los datos que haya introducido podrían no guardarse.";
  }
  window.onbeforeunload = confirmExit;
  
  $(document).on( "page:before-change",function (){
    if(confirm("Los datos que haya introducido podrían no guardarse.\n ¿Estás seguro que deseas abandonar esta página")){
      window.onbeforeunload = false;
      $(document).off( "page:before-change");
      return true;
    }
    else
      return false;
  });
}

var _sform={};

function sform(form_id){
  
  this.form_id = form_id;
  
  this.form = $('form#'+form_id);
  
  this.timeout_campo = {}
  
  this.constructor = function(){
    
    // Agregar eventos
    $('input[id^='+this.form_id+'_][validar-con-ruta]')
      .on('keyup',eval("(function(){_sform['"+this.form_id+"'].validar_campo(this)})"));
    $('input[id^='+this.form_id+'_][validar-con-ruta]')
      .on('change',eval("(function(){_sform['"+this.form_id+"'].validar_campo(this,0)})"));
    $('select[id^='+this.form_id+'_][validar-con-ruta]')
      .on('change',eval("(function(){_sform['"+this.form_id+"'].validar_campo(this,0)})"));
    //if($('input#'+this.form_id+'_[obtener-valor-de-ruta]'))
    //    agregarBusqueda($('input#'+this.form_id+'_[obtener-valor-de-ruta]'));
    $('input[id^='+this.form_id+'_][type=file][ajax]')
      .on('change',eval("(function(){_sform['"+this.form_id+"'].subir_archivos(this)})"));
    $('input[id^='+this.form_id+'_][type=checkbox][confirmar]')
      .on('change',eval("(function(){if(this.checked&&!confirm($('#'+this.id).attr('confirmar')))this.checked=false;})"));
    
    return this.form
      .on("ajax:success", eval("(function(e,data,status,xhr){_sform['"+this.form_id+"'].alterar_form(data);})"))
      .on("ajax:error", function(){alert("no se ha recibido respuesta");});
  }
  
  this.validar_campo = function(campo, timeout){
    if(!timeout)
      timeout = 500;
    if(this.timeout_campo[campo.id] != campo.value){
      this.timeout_campo[campo.id] = campo.value;
      setTimeout('_sform[\''+this.form_id+'\'].request_campo(\''+campo.id+'\',\''+campo.value+'\')',timeout);
    }
  }
  
  this.request_campo=function(campo_id,campo_valor){
      
    if(this.timeout_campo[campo_id] === campo_valor){
          
          $('div#campo_'+campo_id).addClass('cargando');
          $('div#campo_'+campo_id).children('.msg_error').html('cargando...');
          
          var params='';
          if($('#'+campo_id).attr('params')){
              arr_params=$('#'+campo_id).attr('params').split(' ');
              for(var i in arr_params){
                  if($('#'+this.form_id+'_'+arr_params[i]).prop('value')!='')
                      if($('#'+this.form_id+'_'+arr_params[i]).attr('type') == 'checkbox'){
                        if($('#'+this.form_id+'_'+arr_params[i]).prop('checked'))
                          params+='1/';
                        else
                          params+='0/';
                      }
                      else
                        params+=$('#'+this.form_id+'_'+arr_params[i]).prop('value')+'/';
                  else
                      params+='nil/';
              }
          }
          else
              params= campo_valor ? campo_valor : 'nil' ;
          
          $.ajax({
              url:$('#'+campo_id).attr('validar-con-ruta')+'/'+params,
              async:true
          }).done(eval('(function(result){ $(\'div#campo_'+campo_id+'\').removeClass(\'cargando\'); $(\'div#campo_'+campo_id+'\').children(\'.msg_error\').html(\'\'); if(result){ if(result[\'_form\']){ _sform[\''+this.form_id+'\'].alterar_form(result[\'_form\']); } if(result[\'_campos\']){ _sform[\''+this.form_id+'\'].alterar_campos(result[\'_campos\']); } } })'));
    } 
  }

  this.alterar_form=function(data){
      this.form.find('div[id^=campo_]').removeClass('tiene_errores has-error');
      this.form.find('div[id^=campo_]').children('.msg_error').html('');
      
      if(data['_exito']){
          this.form.removeClass('tiene_errores');
          this.form.children('div.resumen_errores').html('');
          if(data['_mensaje'])
              alert(data['_mensaje']);
          else
              alert('formulario enviado exitosamente');
          if(data['_ubicacion']){
              window.onbeforeunload = false;
              $(document).off( "page:before-change");
              Turbolinks.visit(data['_ubicacion']);
          }
      }
      else{
          this.form.addClass('tiene_errores');
          this.form.children('div.resumen_errores').html('Se han encontrado '+data['_canterrores']+' errores');
          if(data['_campos'])
              this.alterar_campos(data['_campos']);
      }
  }
  
  this.alterar_campos=function(campos){
      for(var i in campos)
          this.alterar_campo(i,campos[i])
  }
  
  this.alterar_campo=function(id,cambios){
      if($('#'+id)){
          if(cambios['_set']){
              for(var i in cambios['_set']){
                  if(i=='error'){
                      $('div#campo_'+this.form_id+'_'+id).addClass('tiene_errores has-error');
                      $('div#campo_'+this.form_id+'_'+id).children('.msg_error').html(cambios['_set'][i]+'<br/>');
                  }
                  else if(i=='label'){
                      $('label[for='+this.form_id+'_'+id+']').html(cambios['_set'][i]);
                  }
                  else{
                      if($('#'+this.form_id+'_'+id).length){
                          if($('#'+this.form_id+'_'+id).is('select')&&i=='opciones'){
                              $('#'+this.form_id+'_'+id).find('option').remove().end();
                              for( var j in cambios['_set'][i])
                                  $('#'+this.form_id+'_'+id).append(new Option(j,cambios['_set'][i][j]));
                          }
                          else
                              $('#'+this.form_id+'_'+id).prop(i,cambios['_set'][i]);
                      }
                      else if($('[id^='+this.form_id+'_'+id+'_]').length&&($('[id^='+this.form_id+'_'+id+'_]').attr('type')=='radio'||$('[id^='+this.form_id+'_'+id+'_]').attr('type')=='checkbox')){
                          if(i=='value'){
                              $('[id^='+this.form_id+'_'+id+'_]').removeProp('checked');
                              $('#'+this.form_id+'_'+id+'_'+cambios['_set'][i]).prop('checked',true);
                          }
                          else
                              $('[id^='+this.form_id+'_'+id+'_]').prop(i,cambios['_set'][j]);
                      }
                  }
              }
          }
          if(cambios['_unset']){
              for(var i in cambios['_unset']){
                  if(i=='error'){
                      $('div#campo_'+this.form_id+'_'+id).removeClass('tiene_errores has-error');
                      $('div#campo_'+this.form_id+'_'+id).children('.msg_error').html('');
                  }
                  else{
                      if($('#'+this.form_id+'_'+id).length){
                          if($('#'+this.form_id+'_'+id).is('select')&&i=='opciones')
                              $('#'+this.form_id+'_'+id).find('option').remove().end();
                          else
                              $('#'+this.form_id+'_'+id).removeProp(i);
                      }
                      else if($('[id^='+this.form_id+'_'+id+'_]').length&&($('[id^='+this.form_id+'_'+id+'_]').attr('type')=='radio'||$('[id^='+this.form_id+'_'+id+'_]').attr('type')=='checkbox')){
                          if(i=='value')
                              $('[id^='+this.form_id+'_'+id+'_]').removeProp('checked');
                          else
                              $('[id^='+this.form_id+'_'+id+'_]').removeProp(i);
                      }
                  }
              }
          }
      }
  }
  
  this.archivo_tmp_id=0;
  
  this.subir_archivos = function(campo){
      for(var i = 0; i < campo.files['length']; i++){
          $('#archivos_'+campo.id).append('<div id="archivo_'+campo.id+'_'+this.archivo_tmp_id+'" class="subiendo_archivo">\n\
              <span id="label_'+campo.id+'_'+this.archivo_tmp_id+'">subiendo</span>: <b>'+campo.files[i]['name']+'</b>\n\
              | <span id="ext_'+campo.id+'_'+this.archivo_tmp_id+'">\n\
              <a href="javascript:_sform[\''+this.form_id+'\'].cancelar_archivos(\''+campo.id+'\',\''+this.archivo_tmp_id+'\')">cancelar</a></span>\n\
          </div>');
          var formdata = new FormData();
          formdata.append("archivo",campo.files[i]);
          formdata.append('campo_id',campo.id);
          formdata.append('tmp_id',this.archivo_tmp_id);
          $.ajax({
              url: '/contenido/archivos',
              method: 'POST',
              data: formdata,
              contentType: false,
              processData: false,
              cache: false
          }).done(function(data){
              if(data['_exito']){
                  $('#archivo_'+data['_campo_id']+'_'+data['_tmp_id']).prop('id','archivo_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid']);
                  $('#archivo_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid'])
                  .html('<span id="label_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid']+'">archivo subido</span>:\n\
                  <b><a href="/archivo/'+data['_archivo']['_id']['$oid']+'" target="_blank">'+data['_archivo']['archivo_file_name']+'\n\
                  <i class="fa fa-external-link"></i></a></b>\n\
                  <span id="ext_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid']+'">\n\
                  | <a href="'+data['_edit_url']+'" target="_blank">editar</a>\n\
                  | <a href="javascript:_sform[\''+this.form_id+'\'].remover_archivo(\''+data['_campo_id']+'\',\''+data['_archivo']['_id']['$oid']+'\')">remover</a></span>\n\
                  <input type="hidden" name="'+$('#'+data['_campo_id']).prop('name')+'" value="'+data['_archivo']['_id']['$oid']+'" />');
                  $('#archivo_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid']).removeClass('subiendo_archivo');
                  $('#archivo_'+data['_campo_id']+'_'+data['_archivo']['_id']['$oid']).addClass('archivo_subido');
              }
              else{
                  $('#label_'+data['_campo_id']+'_'+data['_tmp_id']).html('error al subir');
                  $('#ext_'+data['_campo_id']+'_'+data['_tmp_id']).html(data['_mensaje']);
              }
          })
          this.archivo_tmp_id++;
      }
      $('#'+campo.id).prop('value','')
  }
  
  this.cancelar_archivo = function(campo_id,tmp_id){
      // $('#archivo_'+campo_id+'_'+tmp_id).remove();
  }
  
  this.remover_archivo = function(campo_id,id){
      if(confirm('¿Esta se seguro que desea remover este archivo del post?'))
          $('#archivo_'+campo_id+'_'+id).remove();
  }
  
}
