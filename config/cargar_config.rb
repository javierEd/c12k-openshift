require 'configurate'

rails_root = File.expand_path('../../', __FILE__)
rails_env = ENV['RACK_ENV']
rails_env ||= ENV['RAILS_ENV']
rails_env ||= 'development'

config_dir = File.join rails_root, 'config'

AppConfig ||= Configurate::Settings.create do
  add_provider Configurate::Provider::Dynamic
  add_provider Configurate::Provider::Env
  
  unless rails_env == "test" || File.exists?(File.join(config_dir, 'config.yml'))
    $stderr.puts "ERROR FATAL: Configuraci&oacute;n no encontrada. Copia el archivo config.yml.ejemplo a config.yml y editalo seg&uacute;n tus necesidades."
    exit!
  end
  
  add_provider Configurate::Provider::YAML,
               File.join(config_dir, 'config.yml'),
               namespace: rails_env, required: false unless rails_env == 'test'
  add_provider Configurate::Provider::YAML,
               File.join(config_dir, 'config.yml'),
               namespace: "configuracion", required: false
  add_provider Configurate::Provider::YAML,
               File.join(config_dir, 'pordefecto.yml'),
               namespace: rails_env
  add_provider Configurate::Provider::YAML,
               File.join(config_dir, 'pordefecto.yml'),
               namespace: "pordefecto"
  
  [ aplicacion.posts.directorio,
    aplicacion.posts.papelera,
    aplicacion.archivos.directorio,
    aplicacion.archivos.papelera ].each do |dir|
    dir = File.join(rails_root , dir)
    unless Dir.exist?(dir) && File.readable?(dir) && File.writable?(dir)
      $stderr.puts "La ruta "+dir+" no existe o no se tienen privilegios."
      exit!
    end
  end
  
end