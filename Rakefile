require 'rake'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << '.'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

task :cron do
  # daily
  `bin/reminder.sh`
end
