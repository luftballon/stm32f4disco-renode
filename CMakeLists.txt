
#-DCMAKE_TOOLCHAIN_FILE=arm-none-eabi-gcc.cmake
#include(./arm-none-eabi-gcc.cmake)
cmake_minimum_required(VERSION 3.17)
project(blinky)

enable_language(C ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

set(SRC_FILES
        STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f407xx.s
        STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c
        Source/main.c
        Source/rcc.c
        )

set(EXECUTABLE ${PROJECT_NAME}.elf)
add_executable(${EXECUTABLE} ${SRC_FILES})

target_include_directories(${EXECUTABLE} PRIVATE Include/)
include_directories(STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Include/
        STM32CubeF4/Drivers/CMSIS/Core/Include/)

target_compile_definitions(${EXECUTABLE} PRIVATE
    STM32F407xx
    HSE_VALUE=8000000
)

target_compile_options(${EXECUTABLE} PRIVATE
        -mcpu=cortex-m4
        -mthumb
        -mfpu=fpv4-sp-d16
        -mfloat-abi=hard

        -fdata-sections
        -ffunction-sections
#        -fno-pie

        -Wall

        $<$<CONFIG:Debug>:-Og>
        $<$<CONFIG:Release>:-Os>
        )

target_link_options(${EXECUTABLE} PRIVATE
        -T${CMAKE_SOURCE_DIR}/STM32F407VGTx_FLASH.ld
        -mcpu=cortex-m4
        -mthumb
        -mfpu=fpv4-sp-d16
        -mfloat-abi=hard
        -specs=nano.specs
#        -specs=nosys.specs
        -lc
        -lm
        -lnosys
        -Wl,-Map=${PROJECT_NAME}.map,--cref
        -Wl,--gc-sections
        -u SysTick_Handler
        )

# Print executable size
add_custom_command(TARGET ${EXECUTABLE}
        POST_BUILD
        COMMAND arm-none-eabi-size ${EXECUTABLE})

# Create hex file
add_custom_command(TARGET ${EXECUTABLE}
        POST_BUILD
        COMMAND arm-none-eabi-objcopy -O ihex ${EXECUTABLE} ${PROJECT_NAME}.hex
        COMMAND arm-none-eabi-objcopy -O binary ${EXECUTABLE} ${PROJECT_NAME}.bin
        COMMAND arm-none-eabi-objdump -d ${EXECUTABLE} > ${PROJECT_NAME}.s)

