require 'ordered-active-record'

module OrderedActiveRecord
  if defined?(Rails::Railtie)
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'ordered-active-record.insert_into_active_record' do
        ActiveSupport.on_load(:active_record) do
          OrderedActiveRecord::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, OrderedActiveRecord)
    end
  end
end