# frozen_string_literal: true

if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)

  module TransactionIsolation
    module ActiveRecord
      module ConnectionAdapters # :nodoc:
        module Mysql2Adapter
          def self.included(base)
            base.class_eval do
              alias_method :translate_exception_without_transaction_isolation_conflict, :translate_exception
              alias_method :translate_exception, :translate_exception_with_transaction_isolation_conflict
            end
          end

          def supports_isolation_levels?
            true
          end

          VENDOR_ISOLATION_LEVEL = {
            read_uncommitted: 'READ UNCOMMITTED',
            read_committed: 'READ COMMITTED',
            repeatable_read: 'REPEATABLE READ',
            serializable: 'SERIALIZABLE'
          }.freeze

          ANSI_ISOLATION_LEVEL = {
            'READ UNCOMMITTED' => :read_uncommitted,
            'READ COMMITTED' => :read_committed,
            'REPEATABLE READ' => :repeatable_read,
            'SERIALIZABLE' => :serializable
          }.freeze

          def current_isolation_level
            ANSI_ISOLATION_LEVEL[current_vendor_isolation_level]
          end

          # transaction_isolation was added in MySQL 5.7.20 as an alias for tx_isolation, which is now deprecated and is removed in MySQL 8.0. Applications should be adjusted to use transaction_isolation in preference to tx_isolation.
          def current_vendor_isolation_level
            isolation_variable = TransactionIsolation.config.mysql_isolation_variable
            select_value("SELECT @@session.#{isolation_variable}").gsub('-', ' ')
          end

          def isolation_level(level)
            validate_isolation_level(level)

            original_vendor_isolation_level = current_vendor_isolation_level if block_given?

            execute("SET SESSION TRANSACTION ISOLATION LEVEL #{VENDOR_ISOLATION_LEVEL[level]}")

            return unless block_given?

            begin
              yield
            ensure
              execute "SET SESSION TRANSACTION ISOLATION LEVEL #{original_vendor_isolation_level}"
            end
          end

          def translate_exception_with_transaction_isolation_conflict(*args)
            exception = args.first

            if isolation_conflict?(exception)
              ::ActiveRecord::TransactionIsolationConflict.new("Transaction isolation conflict detected: #{exception.message}")
            else
              translate_exception_without_transaction_isolation_conflict(*args)
            end
          end

          ruby2_keywords :translate_exception_with_transaction_isolation_conflict if respond_to?(:ruby2_keywords, true)

          def isolation_conflict?(exception)
            ['Deadlock found when trying to get lock',
             'Lock wait timeout exceeded'].any? do |error_message|
              exception.message =~ /#{Regexp.escape(error_message)}/i
            end
          end
        end
      end
    end
  end

  ActiveRecord::ConnectionAdapters::Mysql2Adapter.include TransactionIsolation::ActiveRecord::ConnectionAdapters::Mysql2Adapter

end
