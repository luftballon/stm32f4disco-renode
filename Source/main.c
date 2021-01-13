#include "stm32f407xx.h"
#include "rcc.h"

__IO uint32_t msTicks;


void SysTick_Handler(void) {
    ++msTicks;
}

void EXTI0_IRQHandler(void) {
    EXTI ->PR |= EXTI_PR_PR0;
    GPIOD ->ODR ^= GPIO_ODR_OD15;
    while((EXTI->PR & EXTI_PR_PR0) != 0);
}

int main() {
    RCC_init();
    (void) SysTick_Config(SystemCoreClock/100);

    RCC ->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
    RCC ->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;

    // LED
    GPIOD ->MODER |= (GPIO_MODER_MODER15_0 | GPIO_MODER_MODER15_0);

    // User Button PA0
    GPIOA ->MODER &= ~GPIO_MODER_MODER0;
    GPIOA ->PUPDR |= GPIO_PUPDR_PUPD0_1;

    RCC ->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
    SYSCFG ->EXTICR[0] &= ~(SYSCFG_EXTICR1_EXTI0);

    EXTI ->IMR  |= EXTI_IMR_MR0;
    EXTI ->RTSR |= EXTI_RTSR_TR0;
    EXTI ->FTSR |= EXTI_FTSR_TR0;

    NVIC_EnableIRQ(EXTI0_IRQn);

    while(1){
        if (msTicks>=100) {
            msTicks = 0;
            GPIOD ->ODR ^= GPIO_ODR_OD12;
        }
    };
    return 0;
}
