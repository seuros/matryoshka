#![no_std]

#[cfg(feature = "std")]
extern crate std;

extern crate alloc;
use alloc::vec::Vec;

/// Bitset-based Sieve of Eratosthenes
/// Uses 1 bit per number for memory efficiency
struct BitSieve {
    bits: Vec<u8>,
    size: usize,
}

impl BitSieve {
    /// Create a new sieve for numbers up to `limit`
    fn new(limit: usize) -> Self {
        let num_bytes = (limit + 1 + 7) / 8; // Ceiling division by 8
        let mut bits = Vec::with_capacity(num_bytes);
        bits.resize(num_bytes, 0xFF); // All bits set (all potentially prime)

        let mut sieve = Self {
            bits,
            size: limit + 1,
        };

        // 0 and 1 are not prime
        sieve.clear(0);
        sieve.clear(1);

        sieve
    }

    /// Check if a number is marked as prime
    #[inline]
    fn is_set(&self, n: usize) -> bool {
        if n >= self.size {
            return false;
        }
        let byte_idx = n / 8;
        let bit_idx = n % 8;
        (self.bits[byte_idx] & (1 << bit_idx)) != 0
    }

    /// Mark a number as composite (not prime)
    #[inline]
    fn clear(&mut self, n: usize) {
        if n >= self.size {
            return;
        }
        let byte_idx = n / 8;
        let bit_idx = n % 8;
        self.bits[byte_idx] &= !(1 << bit_idx);
    }

    /// Run the sieve algorithm
    fn run_sieve(&mut self) {
        let limit = self.size - 1;
        let sqrt_limit = isqrt(limit);

        let mut i = 2;
        while i <= sqrt_limit {
            if self.is_set(i) {
                // Mark all multiples of i as composite
                let mut j = i * i;
                while j <= limit {
                    self.clear(j);
                    j += i;
                }
            }
            i += 1;
        }
    }

    /// Count how many primes are in the sieve
    fn count_primes(&self) -> usize {
        let mut count = 0;
        // Only count bits within our actual size limit
        for i in 0..self.size {
            if self.is_set(i) {
                count += 1;
            }
        }
        count
    }

    /// Find the nth prime (1-indexed)
    fn nth_prime(&self, n: usize) -> Option<usize> {
        if n == 0 {
            return None;
        }

        let mut count = 0;
        for i in 0..self.size {
            if self.is_set(i) {
                count += 1;
                if count == n {
                    return Some(i);
                }
            }
        }
        None
    }
}

/// Integer square root (no_std compatible)
#[inline]
fn isqrt(n: usize) -> usize {
    if n < 2 {
        return n;
    }

    let mut x = n;
    let mut y = (x + 1) / 2;

    while y < x {
        x = y;
        y = (x + n / x) / 2;
    }

    x
}

/// Count prime numbers up to and including `limit`
pub fn count_primes(limit: usize) -> usize {
    if limit < 2 {
        return 0;
    }

    let mut sieve = BitSieve::new(limit);
    sieve.run_sieve();
    sieve.count_primes()
}

/// Find the nth prime number (1-indexed)
/// Returns None if n is 0 or if the estimate is too low
pub fn nth_prime(n: usize) -> Option<usize> {
    if n == 0 {
        return None;
    }

    // Estimate upper bound for nth prime using integer approximation
    // For small n, use lookup; for large n, use p_n < n * (ln(n) + ln(ln(n)))
    // We approximate without floating point for no_std compatibility
    let limit = estimate_nth_prime_upper_bound(n);

    let mut sieve = BitSieve::new(limit);
    sieve.run_sieve();
    sieve.nth_prime(n)
}

/// Estimate an upper bound for the nth prime number
/// Uses integer-only approximation to avoid floating point
fn estimate_nth_prime_upper_bound(n: usize) -> usize {
    if n < 6 {
        return 15;
    }

    // For n >= 6, use approximation: p_n < n * (ln(n) + ln(ln(n)))
    // We use integer approximations: ln(x) ≈ log2(x) * 0.693
    // Simplified: p_n < n * log2(n) for a safe upper bound
    let log2_n = (usize::BITS - n.leading_zeros()) as usize;

    // Add extra margin for safety
    n * log2_n * 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_count_primes_small() {
        assert_eq!(count_primes(0), 0);
        assert_eq!(count_primes(1), 0);
        assert_eq!(count_primes(2), 1);
        assert_eq!(count_primes(3), 2);
        assert_eq!(count_primes(10), 4);
    }

    #[test]
    fn test_count_primes_100() {
        assert_eq!(count_primes(100), 25);
    }

    #[test]
    fn test_count_primes_1000() {
        assert_eq!(count_primes(1000), 168);
    }

    #[test]
    fn test_count_primes_10000() {
        assert_eq!(count_primes(10_000), 1229);
    }

    #[test]
    fn test_nth_prime_small() {
        assert_eq!(nth_prime(1), Some(2));
        assert_eq!(nth_prime(2), Some(3));
        assert_eq!(nth_prime(3), Some(5));
        assert_eq!(nth_prime(4), Some(7));
        assert_eq!(nth_prime(5), Some(11));
    }

    #[test]
    fn test_nth_prime_100() {
        assert_eq!(nth_prime(100), Some(541));
    }

    #[test]
    fn test_nth_prime_1000() {
        assert_eq!(nth_prime(1000), Some(7919));
    }

    #[test]
    fn test_nth_prime_invalid() {
        assert_eq!(nth_prime(0), None);
    }
}
