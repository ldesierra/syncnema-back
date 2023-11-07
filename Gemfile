source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"

gem "rails", "~> 7.0.7"

gem "pg", "~> 1.1"

gem "puma", "~> 5.0"

gem 'sidekiq'

gem "httparty"

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "bootsnap", require: false
gem 'sparql-client'
gem 'figaro'

gem 'elasticsearch-model', '~> 7.2.0'
gem 'elasticsearch-rails', '~> 7.2.0'
gem 'elasticsearch', '< 7.14'
gem 'disco'

gem "rack-cors"

gem 'byebug', platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
gem 'pry'
gem 'pry-rails'
gem 'pry-rescue'

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
end

