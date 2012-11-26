require 'rails'
require 'moderated'

module Moderated
  if defined? Rails::Railtie

    class Railtie < Rails::Railtie
      
      initializer 'moderated.insert_into_active_record' do
        ActiveSupport.on_load(:active_record) do
          Moderated::Railtie.insert
        end
      end
    end
  end
  
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, Moderated::Glue)
    end
  end
end