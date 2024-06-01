# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'transaction_isolation/version'

Gem::Specification.new do |s|
  s.name        = 'transaction_isolation_continued'
  s.version     = TransactionIsolation::VERSION
  s.authors     = ['Iago Pimenta']
  s.homepage    = 'https://github.com/qertoip/transaction_isolation'
  s.summary     = 'Set transaction isolation level in the ActiveRecord in a database agnostic way.'
  s.description = 'Set transaction isolation level in the ActiveRecord in a database agnostic way.
Works with MySQL, PostgreSQL and SQLite as long as you are using new adapters mysql2, pg or sqlite3.
Supports all ANSI SQL isolation levels: :serializable, :repeatable_read, :read_committed, :read_uncommitted.'
  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'minitest', '5.3.4'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_runtime_dependency 'activerecord', '>= 5.2'
end
