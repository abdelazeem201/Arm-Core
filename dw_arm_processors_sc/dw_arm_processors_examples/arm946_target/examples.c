#include <examples.h>
#include <stdio.h>
#include <string.h>

/* These are used for interrupt testing */
int intr_level = 0;
int intr_testing = 0;
int intr_received = 0;
int sio_testing = 0;
int test_fail = 0;
int loop_iter = 2500;
int PULSE_TEST = 0;


extern int init_interrupts(void);
extern int fiqtest(void);
extern int irqtest(void);
extern int dataaborttest(void);
extern int resettest(void);

#define ENDIANTEST    1
#define RAM8TEST      2
#define RAM16TEST     3
#define RAM32TEST     4
#define ITCMTEST      5
#define DTCMTEST      6 

#define FIQTEST       7
#define IRQTEST       8
#define DATAABORTTEST 9
#define RESETTEST     10

int fail_count = 0;

int failure(int test_num)
{
   fail_count++;
   /* Use the debugger to print out the test_num that failed!
   */
   return(test_num);
}

int passed()
{
   /* Use the debugger to print out global fail_count.  It should
    * be 0 if everything passed...
    */
   return(0);
}


int dtcmtest()
{
  int total, size;
  U32 answer;
  pU32 i;
  pU32 pAnswer = &answer;
  U32 data;

  /* Test each memory address by writing and reading a unique value
   * from each 8 bit data location.
   */

  data = 1;
  size = 0;
  total = 0;

  for (i=(pU32) DTCMSTART; i < (pU32)(DTCMSTART + CHK_ADDRESSES);  i++)
  {
    MWRITE32(data, i);
    MREAD32(pAnswer, i);
    MWRITE32((U32) 0x0, i);
    if (answer != data){
       failure(DTCMTEST);
    }
    data++;

    size++;

    total++;
  }
  return(0);
}



int itcmtest()
{
  int total, size;
  U32 answer;
  pU32 i;
  pU32 pAnswer = &answer;
  U32 data;

  /* Test each memory address by writing and reading a unique value
   * from each 8 bit data location.
   */  

  data = 1;
  size = 0;
  total = 0;

  for (i=(pU32) ITCMSTART; i < (pU32)(ITCMSTART + CHK_ADDRESSES);  i++)
  {

    MWRITE32(data, i); 
    MREAD32(pAnswer, i);
    MWRITE32((U32) 0x0, i); 
    if (answer != data){
       failure(ITCMTEST);
    }
    data++; 

    size++;

    total++;
  }
  return(0);
}

int ram8test()
{
  int total, size;
  U8 answer;
  pU8 i;
  pU8 pAnswer = &answer;
  U8 data;

  /* Test each memory address by writing and reading a unique value
   * from each 8 bit data location.
   */  

  data = 1;
  size = 0;
  total = 0;

  for (i=(pU8) RAMSTART16; i < (pU8)(RAMSTART16 + CHK_ADDRESSES);  i++)
  {

    MWRITE8(data, i); 
    MREAD8(pAnswer, i);
    MWRITE8((U8) 0x0, i);
    if (answer != data){
       failure(RAM8TEST);
    }
    data++; 

    size++;

    total++;
  }
  return(0);
}


int ram16test()
{
  int total, size;
  U16 answer;
  pU16 i;
  pU16 pAnswer = &answer;
  U16 data;


  /* Test each memory address by writing and reading a unique value
   * from each 8 bit data location.
   */  
  data = 0xa5a5;
  size = 0;
  total = 0;
 
  for (i=(pU16) RAMSTART16; i < (pU16)(RAMSTART16 + CHK_ADDRESSES);  i++)
  {
    MWRITE16(data, i);
    MREAD16(pAnswer, i);
    MWRITE16((U16) 0x0, i);
    if (answer != data){
       failure(RAM16TEST);
    }
    data++; 
  }
  return(0);
}

int ram32test()
{
  int total, size;
  U32 answer;
  pU32 i;
  pU32 pAnswer = &answer;
  U32 data;

  /* Test each memory address by writing and reading a unique value
   * from each 8 bit data location.
   */  
  data = 0xaabbccdd;
  size = 0;
  total = 0;
 
  for (i=(pU32) RAMSTART32; i < (pU32)(RAMSTART32 + CHK_ADDRESSES);  i++)
  {
    MWRITE32(data, i);
    MREAD32(pAnswer, i);
    MWRITE32((U32)0x0, i);
    if (answer != data){
       failure(RAM32TEST);
    }
    data++;
  }
  return(0);
}



#if (NEED_FUNC_PROTOTYPES == 1)
   int main()
#else
   int main()
#endif
{
#if defined(BIGEND)
  /* Change the endian mode to big. */
  MWRITE32( CONFIG_BIG_END , CONFIG_BIGEND );
  MWRITE32( CONFIG_BIG_END , START_BIGEND );
#endif

#ifndef NOINTERRUPTS
  init_interrupts();
#endif

  ram8test();
  ram16test();
  ram32test();

  fiqtest();
  irqtest();

  dtcmtest();

  dataaborttest();

  passed();

  resettest();
  
  return(0);
}
