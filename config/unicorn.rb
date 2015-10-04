require File.expand_path('../cargar_config', __FILE__)

worker_processes AppConfig.servidor.worker_processes.to_i

timeout AppConfig.servidor.timeout.to_i