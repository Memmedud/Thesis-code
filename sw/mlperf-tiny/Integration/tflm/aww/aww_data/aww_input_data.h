#ifndef AWW_INPUT_DATA_H 
#define AWW_INPUT_DATA_H 

#include <stdint.h>
#include <stddef.h>

#if defined(LONG_BENCHMARKS)

const size_t aww_data_sample_cnt = 25;

#else

const size_t aww_data_sample_cnt = 1;

#endif

extern const uint8_t* aww_input_data[];
extern const size_t aww_input_data_len[];

#endif /* AWW_INPUT_DATA_H */ 

