# frozen_string_literal: true

require 'active_record/connection_adapters/abstract_adapter'

module TransactionIsolation
  module ActiveRecord
    module ConnectionAdapters # :nodoc:
      module AbstractAdapter
        VALID_ISOLATION_LEVELS = %i[read_uncommitted read_committed repeatable_read serializable].freeze

        # If true, #isolation_level(level) method is available
        def supports_isolation_levels?
          false
        end

        def isolation_level(level)
          raise NotImplementedError
        end

        private

        def validate_isolation_level(isolation_level)
          return if VALID_ISOLATION_LEVELS.include?(isolation_level)

          raise ArgumentError,
                "Invalid isolation level '#{isolation_level}'. Supported levels include #{VALID_ISOLATION_LEVELS.join(', ')}."
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.include TransactionIsolation::ActiveRecord::ConnectionAdapters::AbstractAdapter
