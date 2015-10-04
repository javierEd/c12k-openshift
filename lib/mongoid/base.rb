module Mongoid

  module Base
    extend ActiveSupport::Concern
    
    included do
      
      include Mongoid::Document
      
      attr_accessor :tmp_vars, :anonimo
      
      embeds_one :creado, class_name: 'Embed::Creado'
      embeds_one :editado, class_name: 'Embed::Creado'
      
      belongs_to :cuenta
      belongs_to :persona
      
      field :borrado, type: Boolean
      
      def belongs_to_cuenta?
        false
      end
      
      def belongs_to_persona?
        false
      end
      before_create do |document|
        
        if tmp_vars[:cuenta_signed_in]
          if belongs_to_cuenta? && !document.cuenta
            document.cuenta = tmp_vars[:cuenta]
          end

          if belongs_to_persona? && !document.persona
            document.persona = tmp_vars[:cuenta].persona
          end
        end
        fecha_actual = DateTime.now
        document.creado = Embed::Creado.new
        document.creado.fecha = fecha_actual
        document.creado.ip = tmp_vars[:remote_ip]
	
	document.editado = Embed::Creado.new
        document.editado.fecha = fecha_actual
	document.editado.ip = tmp_vars[:remote_ip]
      end
      
      before_update do |document|
        unless anonimo
          document.editado.fecha = DateTime.now
          document.editado.ip = tmp_vars[:remote_ip]
        end
      end
      
    end
  
  end
end