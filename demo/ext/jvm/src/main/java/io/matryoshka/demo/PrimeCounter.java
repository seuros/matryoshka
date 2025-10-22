package io.matryoshka.demo;

import java.util.BitSet;

/**
 * Fast prime counter using Sieve of Eratosthenes with BitSet.
 * JRuby backend for MatryoshkaDemo gem.
 */
public class PrimeCounter {

    /**
     * Count prime numbers up to limit using Sieve of Eratosthenes.
     * Memory efficient: BitSet uses 1 bit per number.
     *
     * @param limit Upper bound (inclusive)
     * @return Number of primes <= limit
     */
    public static long countPrimes(long limit) {
        if (limit < 2) {
            return 0;
        }

        // BitSet: true = prime, false = composite
        int size = (int) limit + 1;
        BitSet isPrime = new BitSet(size);
        isPrime.set(2, size); // Set all to true initially

        // 0 and 1 are not prime
        isPrime.clear(0);
        isPrime.clear(1);

        // Sieve
        int sqrtLimit = (int) Math.sqrt(limit);
        for (int i = 2; i <= sqrtLimit; i++) {
            if (isPrime.get(i)) {
                // Mark multiples as composite
                for (long j = (long) i * i; j <= limit; j += i) {
                    isPrime.clear((int) j);
                }
            }
        }

        return isPrime.cardinality();
    }

    /**
     * Find the nth prime number (1-indexed).
     * Uses prime counting approximation to estimate upper bound.
     *
     * @param n Which prime to find (1st, 2nd, 3rd, etc.)
     * @return The nth prime number
     */
    public static long nthPrime(long n) {
        if (n <= 0) {
            throw new IllegalArgumentException("n must be positive");
        }
        if (n == 1) return 2;
        if (n == 2) return 3;
        if (n == 3) return 5;

        // Estimate upper bound using prime number theorem
        long estimate = estimateNthPrimeUpperBound(n);

        // Generate primes up to estimate
        BitSet isPrime = generateSieve(estimate);

        // Find the nth prime
        long count = 0;
        for (int i = 2; i <= estimate; i++) {
            if (isPrime.get(i)) {
                count++;
                if (count == n) {
                    return i;
                }
            }
        }

        // Should never reach here with correct estimate
        throw new RuntimeException("Failed to find nth prime");
    }

    /**
     * Estimate upper bound for nth prime using approximation:
     * p_n < n * (ln(n) + ln(ln(n))) for n >= 6
     */
    private static long estimateNthPrimeUpperBound(long n) {
        if (n < 6) {
            return 15;
        }

        double logN = Math.log(n);
        double logLogN = Math.log(logN);
        return (long) (n * (logN + logLogN) * 1.3); // 1.3 safety margin
    }

    /**
     * Generate sieve up to limit and return BitSet of primes.
     */
    private static BitSet generateSieve(long limit) {
        int size = (int) limit + 1;
        BitSet isPrime = new BitSet(size);
        isPrime.set(2, size);
        isPrime.clear(0);
        isPrime.clear(1);

        int sqrtLimit = (int) Math.sqrt(limit);
        for (int i = 2; i <= sqrtLimit; i++) {
            if (isPrime.get(i)) {
                for (long j = (long) i * i; j <= limit; j += i) {
                    isPrime.clear((int) j);
                }
            }
        }

        return isPrime;
    }
}
