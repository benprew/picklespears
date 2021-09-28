require 'rake'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  if ENV['DATABASE_URL'] !~ /test$/
    test_db_url = ENV['DATABASE_URL'] + "test"
    warn "Setting DATABASE_URL to #{test_db_url}"
    ENV['DATABASE_URL'] = test_db_url
  end
  t.libs << '.'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

task :cron do
  # daily
  `bin/reminder.sh`
end
