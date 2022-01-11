require_relative 'lib/ms_graph_rest/version'

Gem::Specification.new do |spec|
  spec.name          = 'ms_graph_rest'
  spec.version       = MsGraphRest::VERSION
  spec.authors       = ['Grant Petersen-Speelman']
  spec.email         = ['grant@nexl.io']
  spec.license       = 'MIT'

  spec.summary       = 'A ruby client to interact with Microsoft Graph API'
  spec.description   = 'A ruby client to interact with Microsoft Graph API'
  spec.homepage      = 'https://github.com/NEXL-LTS/ms_graph_rest-ruby'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/NEXL-LTS/ms_graph_rest-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/NEXL-LTS/ms_graph_rest-ruby/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'camel_snake_struct', '>= 0.1.0', '< 2.0'
  spec.add_dependency 'faraday', '>= 1.0.0', '< 2.0'
  spec.add_dependency 'hashie', '>= 3.1.0', '< 5.0'
  spec.add_dependency 'multi_json', '>= 1.4.0', '< 2.0'
  spec.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
