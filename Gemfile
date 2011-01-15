source "http://rubygems.org"
gem "i18n"
gem "data_mapper"
gem "sinatra"
gem "haml"
gem "pony"
gem "ruby-openid"
gem "rack-openid"
gem "maruku"

group :production do
  gem "dm-postgres-adapter"
end

group :development do
  gem "dm-postgres-adapter"

  # for heroku
  gem "heroku"
  gem "taps"
  gem "sequel"
  gem "pg"
end

group :test do
  gem "rack-test"
  gem "dm-sqlite-adapter"
end
