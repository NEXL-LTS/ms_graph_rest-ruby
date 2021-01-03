source 'https://rubygems.org'

# Specify your gem's dependencies in ms_graph_rest.gemspec
gemspec

gem 'byebug'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'
gem 'rubocop'
gem 'rubocop-rake'
gem 'rubocop-rspec'
gem 'simplecov'
gem 'webmock'

if ENV['GEM_VERSIONS'] == 'min'
  gem 'activesupport', '~> 3.2.0'
  gem 'faraday', '~> 0.10.0'
  gem 'hashie', '~> 3.1.0'
  gem 'multi_json', '~> 1.0.0'
end
