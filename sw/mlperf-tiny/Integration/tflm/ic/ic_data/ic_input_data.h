#ifndef IC_INPUT_DATA_H 
#define IC_INPUT_DATA_H 

#include <stdint.h>
#include <stddef.h>

#if defined(LONG_BENCHMARKS)

const size_t ic_data_sample_cnt = 25;

#else

const size_t ic_data_sample_cnt = 1;

#endif

extern const uint8_t* ic_input_data[];
extern const size_t ic_input_data_len[];

#endif /* IC_INPUT_DATA_H */ 

