# SO-polynomial-degree
polynomial-degree function implementation in assembly with signature: `int polynomial_degree(int const *y, size_t n);`.

Function arguments are:
- y - pointer to an array of integers y<sub>0</sub>, y<sub>1</sub>, ... , y<sub>n-1</sub>
- n - array length

Function result is the lowest degree of a polynomial in one variable w(x) with real coefficients that w(x + kr) = y<sub>k</sub> for some real number x, real nonzero number r and k = 0, 1, ... , n-1.

We assume that w(x) = 0 has degree -1.
