Gem::Specification.new do |s|
  s.name        = 'gerablog'
  s.version     = '0.1.0'
  s.summary     = 'My own static site generator.'
  s.description = 'Write posts in Markdown, publish a static blog in HTML'
  s.authors     = ['Paulo Henrique Rodrigues Pinheiro']
  s.email       = 'paulohrpinheiro@gmail.com'
  s.homepage    = 'https://github.com/paulohrpinheiro/gerablog'
  s.files       = Dir['lib/**/*.rb', 'assets/**/*', 'templates/*']
  puts s.files
  s.license     = 'MIT'

  s.executables << 'gerablog'

  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'redcarpet', ['~> 3.3']
  s.add_runtime_dependency 'tenjin', ['~> 0.7']
  s.add_runtime_dependency 'parseconfig', ['~> 1.0']

  s.add_development_dependency 'rake', ['~> 0']
end
