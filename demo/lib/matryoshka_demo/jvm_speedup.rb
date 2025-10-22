# frozen_string_literal: true

# JRuby-specific Java backend
# Only loads on JRuby, provides native JVM performance

# Check if we're on JRuby
return unless RUBY_ENGINE == 'jruby'

# Check if JVM speedup is explicitly disabled
if ENV['DISABLE_MATRYOSHKA_NATIVE'] || ENV['DISABLE_MATRYOSHKADEMO_NATIVE']
  return
end

begin
  require 'java'

  # Add compiled classes directory to classpath
  classes_dir = File.expand_path('../../ext/jvm/classes', __dir__)
  $CLASSPATH << classes_dir if File.directory?(classes_dir)

  # Import Java class
  java_import 'io.matryoshka.demo.PrimeCounter'

  module MatryoshkaDemo
    module JvmSpeedup
      module ClassMethods
        def count_primes(limit)
          Java::IoMatryoshkaDemo::PrimeCounter.countPrimes(limit)
        end

        def nth_prime(n)
          Java::IoMatryoshkaDemo::PrimeCounter.nthPrime(n)
        end
      end

      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end
    end

    PrimeCounter.prepend(JvmSpeedup)

    # Debug: confirm JVM backend loaded
    if ENV['DEBUG_MATRYOSHKA']
      warn "MatryoshkaDemo: JVM backend loaded (JRuby)"
    end
  end

rescue LoadError, NameError => e
  # Java class not found or compilation failed
  # Silently fall back to pure Ruby
  if ENV['DEBUG_MATRYOSHKA']
    warn "MatryoshkaDemo: JVM backend failed to load: #{e.message}"
    warn "Falling back to pure Ruby"
  end
end
