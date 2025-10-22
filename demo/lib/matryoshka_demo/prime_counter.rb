# frozen_string_literal: true

module MatryoshkaDemo
  # Pure Ruby implementation of Sieve of Eratosthenes
  # This is the fallback when native extension is unavailable
  class PrimeCounter
    # Count all prime numbers up to the given limit
    # @param limit [Integer] upper bound (inclusive)
    # @return [Integer] count of primes
    def self.count_primes(limit)
      return 0 if limit < 2

      # Create array: true = potentially prime
      is_prime = Array.new(limit + 1, true)
      is_prime[0] = false
      is_prime[1] = false

      # Sieve of Eratosthenes
      i = 2
      while i * i <= limit
        if is_prime[i]
          # Mark multiples as composite
          j = i * i
          while j <= limit
            is_prime[j] = false
            j += i
          end
        end
        i += 1
      end

      # Count remaining primes
      is_prime.count(true)
    end

    # Find the nth prime number (1-indexed)
    # @param n [Integer] which prime to find (1 = first prime = 2)
    # @return [Integer] the nth prime
    def self.nth_prime(n)
      return nil if n < 1

      # Estimate upper bound for nth prime
      # Using approximation: nth prime ≈ n * ln(n) for n > 5
      if n < 6
        primes = [2, 3, 5, 7, 11]
        return primes[n - 1]
      end

      limit = (n * (Math.log(n) + Math.log(Math.log(n)))).to_i
      limit = [limit, 2 * n].max # Safety margin

      # Generate primes up to limit
      is_prime = Array.new(limit + 1, true)
      is_prime[0] = false
      is_prime[1] = false

      count = 0
      i = 2
      while i <= limit
        if is_prime[i]
          count += 1
          return i if count == n

          # Mark multiples as composite
          j = i * i
          while j <= limit
            is_prime[j] = false
            j += i
          end
        end
        i += 1
      end

      nil # Should not reach here with proper limit estimation
    end
  end
end
