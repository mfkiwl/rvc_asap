#include "cr_api.h"
#define _ASMLANGUAGE
#define MEM_SCRATCH_PAD    ((volatile int *) (0x00001000))

int main() 
{
    /* Test API */
    cr_seg7_0_write (0xFFFFFFF1);
    cr_seg7_1_write (0xFFFFFFF2);
    cr_seg7_2_write (0xFFFFFFF3);
    cr_seg7_3_write (0xFFFFFFF4);
    cr_seg7_4_write (0xFFFFFFF5);
    cr_seg7_5_write (0xFFFFFFF6);
    cr_led_write    (0xFFFFFFF7);
    
    MEM_SCRATCH_PAD[0] = cr_seg7_0_read();
    MEM_SCRATCH_PAD[1] = cr_seg7_1_read();
    MEM_SCRATCH_PAD[2] = cr_seg7_2_read();
    MEM_SCRATCH_PAD[3] = cr_seg7_3_read();
    MEM_SCRATCH_PAD[4] = cr_seg7_4_read();
    MEM_SCRATCH_PAD[5] = cr_seg7_5_read();
    MEM_SCRATCH_PAD[6] = cr_led_read();
    MEM_SCRATCH_PAD[7] = cr_button_0_read();
    MEM_SCRATCH_PAD[8] = cr_button_1_read();
    MEM_SCRATCH_PAD[9] = cr_switch_read();

    return 0;
}