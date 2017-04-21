require 'rake/testtask'
require 'yaml'
require 'standalone_migrations'

StandaloneMigrations::Tasks.load_tasks

Rake::TestTask.new do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/*.rb', 'tests/*/*.rb']
  t.verbose = true
end