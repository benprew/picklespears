configure :production do
  DataMapper.setup(:default, 'mysql://picklespears:burn0ut!@localhost/picklespears')
end

configure :development do
  DataMapper.setup(:default, 'mysql://picklespears:burn0ut!@localhost/picklespearsdev')
end

configure :test do
  DataMapper.setup(:default, 'sqlite3:///tmp/test_db')
  DataMapper.auto_migrate!
end

