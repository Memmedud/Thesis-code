
#include "matrix_common.h"
#include "simple_system_common.h"
#include <stdlib.h>


// Check if two matrices are equal
void is_equal(const int32_t* c, const int32_t* c_ref, const unsigned long int n, const unsigned long int p) {
  if (sizeof(c) != sizeof(c_ref)) {
    puts("Matrices are not of equal size!\n");
    return;
  }

  for (int i = 0; i < n * p; ++i) {
    if (c[i] != c_ref[i]) {
      puts("Matrices are not equal!\n");
      return;
    }
  }

  puts("Matrices are identical!\n");
}

// Print a uint8 matrix
void print_matrix_byte(const int8_t* c, const unsigned long int n, const unsigned long int p) {
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < p; ++j) {
      putbyte(c[i * p + j]);
      putchar(' ');
      if (j == (p - 1))
      putchar('\n');
    }
  }
}

// Print a uint16 matrix
void print_matrix_half(const int16_t* c, const unsigned long int n, const unsigned long int p) {
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < p; ++j) {
      puthalf(c[i * p + j]);
      putchar(' ');
      if (j == (p - 1))
      putchar('\n');
    }
  }
}

// Print a uint32 matrix
void print_matrix_word(const int32_t* c, const unsigned long int n, const unsigned long int p) {
  for (int i = 0; i < n; ++i) {
    for (int j = 0; j < p; ++j) {
      puthex(c[i * p + j]);
      putchar(' ');
      if (j == (p - 1))
      putchar('\n');
    }
  }
}

#if defined(WIDTH8)
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_ref(int32_t* c, const int8_t* a, const int8_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < p; j++) {
        int32_t sum = 0;
        for (int k = 0; k < m; k++) {
          sum = sum + ((a[i * p + k]) * (b[k * m + j]));
        }
        c[i * p + j] = sum;
      }
    }
  }
#elif defined(WIDTH16)
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_ref(int32_t* c, const int16_t* a, const int16_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < p; j++) {
        int32_t sum = 0;
        for (int k = 0; k < m; k++) {
          sum = sum + ((a[i * p + k]) * (b[k * m + j]));
        }
        c[i * p + j] = sum;
      }
    }
  }
#elif defined(WIDTH32)
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul__ref(int32_t* c, const int32_t* a, const int32_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < p; j++) {
        int32_t sum = 0;
        for (int k = 0; k < m; k++) {
          sum = sum + ((a[i * p + k]) * (b[k * m + j]));
        }
        c[i * p + j] = sum;
      }
    }
  }
#endif