#ifndef TOY_INPUT_DATA_H 
#define TOY_INPUT_DATA_H 

#include <stdint.h>
#include <stddef.h>

#if defined(LONG_BENCHMARKS)

const size_t toy_data_sample_cnt = 25;

#else

const size_t toy_data_sample_cnt = 1;

#endif

extern const uint8_t* toy_input_data[];
extern const size_t toy_input_data_len[];

#endif /* TOY_INPUT_DATA_H */ 

