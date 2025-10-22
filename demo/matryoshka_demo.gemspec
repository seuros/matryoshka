# frozen_string_literal: true

require_relative 'lib/matryoshka_demo'

Gem::Specification.new do |spec|
  spec.name = 'matryoshka_demo'
  spec.version = MatryoshkaDemo::VERSION
  spec.authors = ['Matryoshka Contributors']
  spec.email = ['demo@example.com']

  spec.summary = 'Demo gem showcasing the Matryoshka FFI Hybrid pattern'
  spec.description = 'Prime number calculator with pure Ruby fallback and optional Rust FFI speedup'
  spec.homepage = 'https://github.com/seuros/matryoshka_gem'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir.glob(%w[
    lib/**/*.rb
    ext/**/*.{rb,rs,toml}
    README.md
  ]).select { |f| File.exist?(f) }

  spec.require_paths = ['lib']

  # Native extension (skipped on platforms without C extension support)
  unless RUBY_ENGINE == 'jruby' || RUBY_ENGINE == 'truffleruby'
    spec.extensions = ['ext/matryoshka_demo_native/extconf.rb']
  end

  # Build dependencies
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rb_sys', '~> 0.9'
end
