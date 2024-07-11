# frozen_string_literal: true

require 'active_record'
require_relative 'transaction_isolation/version'
require_relative 'transaction_isolation/configuration'

module TransactionIsolation
  # Must be called after ActiveRecord established a connection.
  # Only then we know which connection adapter is actually loaded and can be enhanced.
  # Please note ActiveRecord does not load unused adapters.
  def self.apply_activerecord_patch
    require_relative 'transaction_isolation/active_record/errors'
    require_relative 'transaction_isolation/active_record/base'
    require_relative 'transaction_isolation/active_record/connection_adapters/abstract_adapter'
    require_relative 'transaction_isolation/active_record/connection_adapters/mysql2_adapter'
    require_relative 'transaction_isolation/active_record/connection_adapters/postgresql_adapter'
    require_relative 'transaction_isolation/active_record/connection_adapters/sqlite3_adapter'
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    config = configuration
    yield(config)
  end

  def self.config
    config = configuration
    yield(config) if block_given?
    config
  end

  if defined?(::Rails)
    # Setup applying the patch after Rails is initialized.
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        begin
          if TransactionIsolation.config.detect_mysql_isolation_variable && ActiveRecord::Base.connection.adapter_name == 'Mysql2'
            mysql_version = ActiveRecord::Base.connection.select_value('SELECT version()')
            TransactionIsolation.config.mysql_isolation_variable = if mysql_version >= '8'
                                                                     'transaction_isolation'
                                                                   else
                                                                     'tx_isolation'
                                                                   end
          end

          TransactionIsolation.apply_activerecord_patch
        rescue ActiveRecord::NoDatabaseError
          # This is expected when running rake db:create
        end
      end
    end
  end
end
