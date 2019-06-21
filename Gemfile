# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gemspec

# DECIDIM_VERSION = '>= 0.18.0'
DECIDIM_VERSION = '>= 0.17.0'

gem 'decidim', DECIDIM_VERSION

group :development, :test do
  gem 'byebug', '~> 10.0', platform: :mri
  gem "bootsnap", require: true
  gem 'faker', '~> 1.8'
  gem 'listen'
end

group :development do
  gem 'letter_opener_web', '~> 1.3.3'
  gem 'web-console', '~> 3.5'
end
