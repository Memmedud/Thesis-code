
#include <stdint.h>

#include "simple_system_regs.h"

// Generate matrices
void generate_matrices(int8_t* a, int8_t* b, const unsigned long int n, 
                       const unsigned long int m, const unsigned long int p);

// Check if two matrices are equal
void is_equal(const int32_t* c, const int32_t* c_ref, const unsigned long int n, const unsigned long int p);

// Print a uint8 matrix
void print_matrix_byte(const int8_t* c, const unsigned long int n, const unsigned long int p);

// Print a uint16 matrix
void print_matrix_half(const int16_t* c, const unsigned long int n, const unsigned long int p);

// Print a uint32 matrix
void print_matrix_word(const int32_t* c, const unsigned long int n, const unsigned long int p);

// C = AB with A = [n x m], B = [m x p], C = [n x p]
void matmul_int8_ref(int32_t* c, const int8_t* a, const int8_t* b,
                const unsigned long int n, const unsigned long int m,
                const unsigned long int p);

// C = AB with A = [n x m], B = [m x p], C = [n x p]
void matmul_int16_ref(int32_t* c, const int16_t* a, const int16_t* b,
                const unsigned long int n, const unsigned long int m,
                const unsigned long int p);

// C = AB with A = [n x m], B = [m x p], C = [n x p]
/*void matmul_int32_ref(int32_t* c, const int32_t* a, const int32_t* b,
                const unsigned long int n, const unsigned long int m,
                const unsigned long int p);*/