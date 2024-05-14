module TransactionIsolation
  class Configuration
    attr_accessor :mysql_isolation_variable
    attr_accessor :detect_mysql_isolation_variable

    def initialize
      @mysql_isolation_variable = 'tx_isolation'
      @detect_mysql_isolation_variable = true
    end

    def mysql_isolation_variable=( value )
      unless value.in? %w[transaction_isolation tx_isolation]
        raise ArgumentError, "Invalid MySQL isolation variable '#{value}'. Supported variables include 'transaction_isolation' and 'tx_isolation'."
      end

      @mysql_isolation_variable = value
    end
  end
end
