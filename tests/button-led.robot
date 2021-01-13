*** Settings ***
Suite Setup                    Setup
Suite Teardown                 Teardown
Test Setup                     Reset Emulation
Resource                       ${RENODEKEYWORDS}

*** Variables ***
${CPU}                         stm32f4.repl
${GPIO_LEDS}                   stm32f4_leds.repl
${DELAY}                       1

*** Test Cases ***
Handle Button Press Toggle Blue LED

    Execute Command            mach create
    Execute Command            machine LoadPlatformDescription @platforms/cpus/${CPU}
    Execute Command            machine LoadPlatformDescription @${PWD_PATH}/tests/add-ccm.repl
    Execute Command            machine LoadPlatformDescription @${PWD_PATH}/tests/${GPIO_LEDS}
    Execute Command            sysbus LoadELF @${PWD_PATH}/build/blinky.elf

    Execute Command            emulation CreateLEDTester "LED6_tester" sysbus.gpioPortD.LED6
    Start Emulation

    Execute Command            sysbus.gpioPortA.UserButton Press
    Execute Command            LED6_tester AssertState true ${DELAY}
    Execute Command            sysbus.gpioPortA.UserButton Release
    Execute Command            LED6_tester AssertState false ${DELAY}
