# Load test coverage tool (must be loaded before any code)
require 'simplecov'
require "simplecov_json_formatter"
SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter

SimpleCov.start do
 add_filter '/test/'
end

# Load and initialize the application to be tested
require 'library_setup'

# Load test frameworks
require 'minitest/autorun'
