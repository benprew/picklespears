# unicorn -c config/unicorn.rb -E production -D
# set path to app that will be used to configure unicorn,
# note the trailing slash in this example

@app_root = "/var/www/teamvite/current/"

user 'teamvite'
worker_processes 2
working_directory @app_root

preload_app true

timeout 30

# Set process id path
pid "#{@app_root}tmp/pids/teamvite.pid"

# Set log file paths
stderr_path "#{@app_root}log/teamvite.stderr.log"
stdout_path "#{@app_root}log/teamvite.stdout.log"

before_fork do |server, worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = @app_root + '/tmp/pids/teamvite.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  # the master process doesn't need to hold open a connection
  DB.disconnect
end

after_fork do |server, worker|
  DB = Sequel.connect(ENV['DATABASE_URL'])
  # if test?
  #   DB = Sequel.sqlite
  # elsif production?
  #   DB = Sequel.connect(SqlDb.build_connect_string_for(:production))
  #   DB.logger = Logger.new(STDOUT)
  # else
  #   DB = Sequel.connect(SqlDb.build_connect_string_for(:development))
  #   DB.logger = Logger.new(STDOUT)
  # end
end
