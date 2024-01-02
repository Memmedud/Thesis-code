/*
 * SPDX-FileCopyrightText: Copyright 2023 Arm Limited and/or its affiliates <open-source-office@arm.com>
 * Copyright (c) 2019 Nuclei Limited. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the License); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* ----------------------------------------------------------------------
 * Project:      NMSIS NN Library
 * Title:        riscv_convolve_get_buffer_sizes_s16.c
 * Description:  Collection of get buffer size functions for the various s16 convolution layer functions.
 *
 * $Date:        30 January 2023
 * $Revision:    V.1.0.0
 *
 * Target :  RISC-V Cores
 *
 * -------------------------------------------------------------------- */

#include "riscv_nnfunctions.h"

/**
 *  @ingroup NNConv
 */

/**
 * @addtogroup GetBufferSizeNNConv
 * @{
 */

__STATIC_INLINE int32_t riscv_convolve_fast_s16_get_buffer_size_dsp(const nmsis_nn_dims *input_dims,
                                                                  const nmsis_nn_dims *filter_dims)
{
    return (2 * input_dims->c * filter_dims->w * filter_dims->h) * (int32_t)sizeof(int16_t);
}

int32_t riscv_convolve_fast_s16_get_buffer_size(const nmsis_nn_dims *input_dims, const nmsis_nn_dims *filter_dims)
{
#if defined(RISCV_MATH_DSP)
    return riscv_convolve_fast_s16_get_buffer_size_dsp(input_dims, filter_dims);
#else
    (void)input_dims;
    (void)filter_dims;
    return 0;
#endif
}

int32_t riscv_convolve_s16_get_buffer_size(const nmsis_nn_dims *input_dims, const nmsis_nn_dims *filter_dims)
{
    (void)input_dims;
    (void)filter_dims;
    return 0;
}

/*
 * Get the required buffer size for riscv_convolve_wrapper_s16. This is the recommended function convolve wrapper s16
 * function.
 *
 * Refer to header file for details.
 *
 */
int32_t muriscv_nn_convolve_wrapper_s16_get_buffer_size(const nmsis_nn_conv_params *conv_params,
                                                 const nmsis_nn_dims *input_dims,
                                                 const nmsis_nn_dims *filter_dims,
                                                 const nmsis_nn_dims *output_dims)
{

#if defined(RISCV_MATH_DSP)
    return riscv_convolve_wrapper_s16_get_buffer_size_dsp(conv_params, input_dims, filter_dims, output_dims);
#else
    (void)conv_params;
    (void)output_dims;

    // MVE and scalar implementation have same buffer requirements
    return riscv_convolve_s16_get_buffer_size(input_dims, filter_dims);
#endif
}

int32_t riscv_convolve_wrapper_s16_get_buffer_size_dsp(const nmsis_nn_conv_params *conv_params,
                                                     const nmsis_nn_dims *input_dims,
                                                     const nmsis_nn_dims *filter_dims,
                                                     const nmsis_nn_dims *output_dims)
{
    (void)output_dims;

    if (filter_dims->w * filter_dims->h * input_dims->c < 512 &&
        (conv_params->dilation.w == 1 && conv_params->dilation.h == 1))
    {
        return riscv_convolve_fast_s16_get_buffer_size_dsp(input_dims, filter_dims);
    }
    else
    {

        return riscv_convolve_s16_get_buffer_size(input_dims, filter_dims);
    }
}

/**
 * @} end of GetBufferSizeNNConv group
 */
