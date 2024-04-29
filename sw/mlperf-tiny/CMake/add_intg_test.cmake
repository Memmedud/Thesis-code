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

# Simple macro that will register an integration test with CTest
macro(add_muriscv_nn_intg_test TEST_NAME)

  # Register test with CTest and provide command to execute
  if(NOT SPIKE)
    if(NOT USE_VEXT)
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s -T ${CMAKE_SOURCE_DIR}/Integration/ibex/link.ld")
      target_link_options(${TEST_NAME} PUBLIC -nostartfiles)
      target_link_libraries(${TEST_NAME} PUBLIC ibex)

      add_custom_command(TARGET ${TEST_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:${TEST_NAME}>"
                                            "$<TARGET_FILE:${TEST_NAME}>.bin" VERBATIM)

      add_custom_command(TARGET ${TEST_NAME} POST_BUILD
        COMMAND srec_cat "$<TARGET_FILE:${TEST_NAME}>.bin" -binary -offset 0x0000 -byte-swap 4 -o
                          "$<TARGET_FILE:${TEST_NAME}>.vmem" -vmem VERBATIM)

    else()
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -s -T ${CMAKE_SOURCE_DIR}/Integration/Vicuna/lld_link.ld")
      target_link_options(${TEST_NAME} PUBLIC -nostartfiles)
      target_link_libraries(${TEST_NAME} PUBLIC vicuna_crt)

      add_custom_command(TARGET ${TEST_NAME} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:${TEST_NAME}>"
                                          "$<TARGET_FILE:${TEST_NAME}>.bin" VERBATIM)

      add_custom_command(TARGET ${TEST_NAME} POST_BUILD
        COMMAND srec_cat "$<TARGET_FILE:${TEST_NAME}>.bin" -binary -offset 0x0000 -byte-swap 4 -o
                        "$<TARGET_FILE:${TEST_NAME}>.vmem" -vmem VERBATIM)

      add_custom_command(TARGET ${TEST_NAME} POST_BUILD
        COMMAND realpath "$<TARGET_FILE:${TEST_NAME}>.vmem" >
                        "$<TARGET_FILE:${TEST_NAME}>.path" VERBATIM)
    endif()
  else()
    add_test(NAME ${TEST_NAME}
      COMMAND ./${TEST_NAME}.elf
      WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
  endif()

  # TODO(fabianpedd): Reintroduce test timeout
  # if(${SIMULATOR} STREQUAL "ETISS")
  #   # TODO(fabianpedd): make ETISS tests fail after 2 second for now
  #   set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 2)
  # else()
  #   # Tests should not take longer than 15 seconds
  #   set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 15)
  # endif()

  # Create assembly dump from binary file
  add_custom_command(TARGET ${TEST_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -S "$<TARGET_FILE:${TEST_NAME}>" # or just -d
                              > "$<TARGET_FILE:${TEST_NAME}>.lst" VERBATIM)

  message(STATUS "Successfully added ${TEST_NAME}")

endmacro()
