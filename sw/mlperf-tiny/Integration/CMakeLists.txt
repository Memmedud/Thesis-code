#
# Copyright (C) 2021-2022 Chair of Electronic Design Automation, TUM.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the License); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an AS IS BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include(add_intg_test)

option(DISABLE_TFLM_INTG_TESTS "Enable tflm integration tests" OFF)

if (NOT SPIKE)
    if (NOT USE_VEXT)
        add_subdirectory(ibex)
    else()
        add_subdirectory(Vicuna)
    endif()
endif()

if(NOT DISABLE_TFLM_INTG_TESTS)
    add_subdirectory(tflm)
endif()


