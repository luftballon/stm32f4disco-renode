#include "rcc.h"

#define RCC_PLL_N        0x150
#define RCC_PLL_Q        0x7


void RCC_init(void){

    RCC->CR |= ((uint32_t)RCC_CR_HSEON);
    while(!(RCC->CR & RCC_CR_HSERDY)){};

    FLASH->ACR |= FLASH_ACR_PRFTEN;
    FLASH->ACR &= (uint32_t)((uint32_t)~FLASH_ACR_LATENCY);
    FLASH->ACR |= (uint32_t)FLASH_ACR_LATENCY_5WS;
    FLASH->ACR |= FLASH_ACR_ICEN | FLASH_ACR_DCEN;

    RCC->CFGR |= RCC_CFGR_PPRE2_DIV2;
    RCC->CFGR |= RCC_CFGR_PPRE1_DIV4;

    RCC->PLLCFGR = RCC_PLLCFGR_PLLM_3 | (RCC_PLL_N << RCC_PLLCFGR_PLLN_Pos) |
                   RCC_PLLCFGR_PLLSRC_HSE | (RCC_PLL_Q << RCC_PLLCFGR_PLLQ_Pos);

    RCC->CR |= RCC_CR_PLLON;

    while((RCC->CR & RCC_CR_PLLRDY) == 0) {};
    RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
    RCC->CFGR |= (uint32_t)RCC_CFGR_SW_PLL;
    while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) != (uint32_t)0x08) {};

    SystemCoreClockUpdate();
}