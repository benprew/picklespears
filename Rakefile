require 'rake'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << '.'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

namespace :test do
  desc 'Drops and creates the test database'
  task :setup_db do
    `psql teamvitetest -f db/create.sql`
  end
end

task :cron do
  # daily
  `bin/reminder.sh`
end
