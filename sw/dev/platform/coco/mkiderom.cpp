#include <stdio.h>
#include <stdlib.h>

#define DISPLAY printf
#define EOL "\n"

#define SHOW_INT(label,val)     DISPLAY ("%*.*s = %d" EOL, 60, 60, label, val);
#define SHOW_YESNO(label,val)   DISPLAY ("%*.*s = %s" EOL, 60, 60, label, ((val) ? "yes" : "no"));
#define SHOW_BITS(label,var)                \
  {                                         \
    int b;                                  \
    DISPLAY ("%*.*s = ", 60, 60, label);    \
    if ((var) == 0)                         \
    {                                       \
      DISPLAY ("(none)" EOL);               \
    }                                       \
    else                                    \
    {                                       \
      for (b=0; b<8; b++)                   \
        if ((var) & (1<<b))                 \
          DISPLAY ("%d,", b);               \
      DISPLAY ("\b " EOL);                  \
    }                                       \
  }

unsigned short int rom[] =
{
  0x044A, 0x03DF, 0x0000, 0x0008, 0x0000, 0x0200, 0x0020, 0x0003, 
  0xDF00, 0x0000, 0x5354, 0x4946, 0x6C61, 0x7368, 0x4361, 0x7264, 
  0x2020, 0x2020, 0x2020, 0x2020, 0x0001, 0x0001, 0x0004, 0x3039, 
  0x3036, 0x3035, 0x4C32, 0x5369, 0x6D70, 0x6C65, 0x5465, 0x6368, 
  0x2046, 0x6C61, 0x7368, 0x2020, 0x2020, 0x2020, 0x2020, 0x2020, 
  0x2020, 0x2020, 0x2020, 0x2020, 0x2020, 0x2020, 0x2020, 0x0001, 
  0x0000, 0x0F00, 0x0000, 0x0200, 0x0000, 0x0003, 0x03DF, 0x0008, 
  0x0020, 0xDF00, 0x0003, 0x0100, 0xDF00, 0x0003, 0x0000, 0x0407, 
  0x0003, 0x0078, 0x0078, 0x0078, 0x0078, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x3035, 0x3033, 0x3136, 0x6238, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};
  
int main (int argc, char *argv[])
{
  unsigned short *buf = (unsigned short *)rom;
  unsigned blocks = (unsigned)buf[1] * (unsigned)buf[3] * (unsigned)buf[6];
  
  SHOW_YESNO ("removable media device", (buf[0] & (1<<7) ? 1 : 0));
  SHOW_YESNO ("not removable controller/device", (buf[0] & (1<<6) ? 1 : 0));
  SHOW_INT ("number of logical cylinders", buf[1]);
  SHOW_INT ("number of logical heads", buf[3]);
  SHOW_INT ("number of logical sectors per logical track", buf[6]);
  SHOW_INT ("(calculated number of sectors)", (int)blocks);
  SHOW_INT ("(calculated size (MB))", (int)((blocks*512L)/1000000L));
  SHOW_INT ("max READ/WRITE MULTIPLE sectors/int", buf[47]&0xFF);
  DISPLAY ("%*.*s = %s" EOL, 60, 60, "IORDY supported", ((buf[49]&(1<<11)) ? "yes" : "maybe"));
  SHOW_YESNO ("IORDY may be disabled", buf[49]&(1<<11));
  SHOW_YESNO ("LBA supported", buf[49]&(1<<9));
  SHOW_YESNO ("DMA supported", buf[49]&(1<<8));
  SHOW_INT ("(Current) PIO timing mode", buf[51] >> 8);
  //SHOW_INT ("(Current) DMA timing mode", buf[52] >> 8);   // obsolete
  if (buf[53] & (1<<0))
  {
    // words 54-58 are valid
  }
  if (buf[53] & (1<<1))
  {
    // words 64-70 are valid
    SHOW_BITS ("Multiword DMA mode active", buf[63] >> 8);
    SHOW_BITS ("Multiword DMA modes supported", buf[63]);
    SHOW_BITS ("Advanced PIO modes supported", (buf[64]&0x03)<<3);
    SHOW_INT ("Minimum Multiword DMA transfer cycle time", buf[65]);
    SHOW_INT ("Recommended Multiword DMA transfer cycle time", buf[65]);
  }
  SHOW_BITS ("Ultra DMA modes supported", buf[88]&0xFF);
  SHOW_BITS ("Ultra DMA mode selected", buf[88]>>8);

  FILE *fp = fopen ("iderom.bin", "wb");
  fwrite (rom, 2, 256, fp);
  fclose (fp);
}

