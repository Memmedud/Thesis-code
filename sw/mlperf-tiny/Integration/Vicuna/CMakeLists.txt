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

# Builds the vicuna C runtime
add_library(vicuna_crt OBJECT
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/runtime.c
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/uart.c
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/crt0.S
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/vicuna_crt.c
)

target_include_directories(vicuna_crt PUBLIC ${CMAKE_SOURCE_DIR}/Integration/Vicuna)
target_sources(vicuna_crt PRIVATE
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/runtime.c
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/uart.c
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/crt0.S
  ${CMAKE_SOURCE_DIR}/Integration/Vicuna/vicuna_crt.c
)
