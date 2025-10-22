# frozen_string_literal: true

# TruffleRuby-specific Java backend via Polyglot
# TruffleRuby runs on GraalVM and supports polyglot interop

# Check if we're on TruffleRuby
return unless RUBY_ENGINE == 'truffleruby'

# Check if Java speedup is explicitly disabled
if ENV['DISABLE_MATRYOSHKA_NATIVE'] || ENV['DISABLE_MATRYOSHKADEMO_NATIVE']
  return
end

begin
  # TruffleRuby uses Polyglot API for Java interop
  require 'polyglot'

  # Add compiled classes directory to classpath
  classes_dir = File.expand_path('../../ext/jvm/classes', __dir__)

  if File.directory?(classes_dir)
    # Import Java class using Polyglot
    java_class = Polyglot.eval('java', 'io.matryoshka.demo.PrimeCounter')

    module MatryoshkaDemo
      module TruffleSpeedup
        module ClassMethods
          def count_primes(limit)
            Polyglot.eval('java', 'io.matryoshka.demo.PrimeCounter').countPrimes(limit)
          end

          def nth_prime(n)
            Polyglot.eval('java', 'io.matryoshka.demo.PrimeCounter').nthPrime(n)
          end
        end

        def self.prepended(base)
          base.singleton_class.prepend(ClassMethods)
        end
      end

      PrimeCounter.prepend(TruffleSpeedup)

      # Debug: confirm TruffleRuby Java backend loaded
      if ENV['DEBUG_MATRYOSHKA']
        warn "MatryoshkaDemo: TruffleRuby Java backend loaded (Polyglot)"
      end
    end
  end

rescue LoadError, NameError => e
  # Polyglot not available or Java class not found
  # Silently fall back to pure Ruby
  if ENV['DEBUG_MATRYOSHKA']
    warn "MatryoshkaDemo: TruffleRuby Java backend failed to load: #{e.message}"
    warn "Falling back to pure Ruby"
  end
end
