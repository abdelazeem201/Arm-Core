#include <stdio.h>
#include <string.h>
#include <examples.h>
#include <intr.h>
#define FIQTEST       7
#define IRQTEST       8
#define DATAABORTTEST 9
#define RESETTEST     10
#define IRQFIQTEST    11

extern int failure(int tnum);

/*
** Since excnt and reset_flag are manipulated from exception handlers
** they should be declared "volatile"
*/
extern int excnt;                     /* exception counter */
extern int PULSE_TEST;                     /* exception counter */
#define LOOP_ITER 10000


/*---------------------------------------------------------------------
**
** RESET TEST
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int resettest( )
#else
int resettest( )
#endif
 
{
  unsigned  prev;
  int cnt=0;
 
  excnt = 0;
  prev = Install_Handler((unsigned ) RESETHandler, (unsigned *) RESETVEC);
 
  MWRITE32( 0xC, 0xb0000000 );  /* Reset and High Vec's */
 
  while (cnt!=LOOP_ITER && !excnt) { /* Wait */
    cnt++;
  }
 
  if (excnt) {
     /* test passed */
  }
  else {
    failure(RESETTEST);
  }
 
  return(0);
}

/*---------------------------------------------------------------------
**
** data abort test - interrupt test
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int dataaborttest( )
#else
int dataaborttest( )
#endif
{
  int       cnt;
  unsigned  prev;
  unsigned *ptr = (unsigned *)DABORTADDR;

  excnt = 0;
  cnt = 0;

/*
** the installed handler doesn't fixup the return address
** to retry the instruction that caused the aborted memory
** access - we're only verifying we detect this correctly.
*/
  prev = Install_Handler( (unsigned)DABORTHandler, (unsigned *)DABORTVEC );
  *ptr = 0xfeeefeee;  /* cause the Data Abort */

  while (cnt!=LOOP_ITER && !excnt) { /* Wait */
    cnt++;
  }

  if (excnt) {
     /* test passed */
  }
  else {
    failure(DATAABORTTEST);
  }
  
  /* Restore DABORTVEC reg to clear exception */
  *(unsigned *)DABORTVEC = prev;
  
  return(0);
}


/*---------------------------------------------------------------------
**
** IRQ TEST
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int irqtest( )
#else
int irqtest( )
#endif

{
  unsigned  prev;
  int cnt=0;

  excnt = 0;
  prev = Install_Handler((unsigned ) irq_hndlr, (unsigned *) IRQVEC);

  MWRITE32( 0x1, 0xb0000000 );

  while (cnt!=LOOP_ITER && !excnt) { /* Wait */
    cnt++;
  }

  if (excnt) {
     /* test passed */
  }
  else {
     failure(IRQTEST);
  }

  /* Restore vectors */
  *(unsigned *)IRQVEC = prev;

  return(0);
}


/*---------------------------------------------------------------------
**
** FIQ test
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int fiqtest( )
#else
int fiqtest( )
#endif
{
  int cnt=0;

  excnt=0;

  MWRITE32( 0x2, 0xb0000000 );

  while (cnt!=LOOP_ITER && !excnt) { /* Wait */
    cnt++;
  }

  if (excnt) {
     /* test passed */
  }
  else {
     failure(FIQTEST);
  }

  return(0);
}


/*---------------------------------------------------------------------
**
** irqfiqtest
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int irqfiqtest( )
#else
int irqfiqtest( )
#endif
{
  /* char      buf[80]; */
  int       cnt, cnt2;
  unsigned  previrq, prevfiq;


  excnt = 0;   /* zero exception counter */ 
  previrq = Install_Handler((unsigned ) irq_hndlr, (unsigned *) IRQVEC);
  prevfiq = Install_Handler((unsigned ) fiq_hndlr, (unsigned *) FIQVEC);
 
  MWRITE32( 0x3, 0xb0000000 );

  /* somewhere in here the interrupt should come through */
  cnt2 = 0;
  for (cnt = 0; ((cnt != LOOP_ITER) && !(excnt == 2)); cnt++){
    cnt2++;
  }
 

  if (excnt != 2 ){
      failure(IRQFIQTEST);
  }
  else if (cnt != cnt2){
      failure(IRQFIQTEST);
  }
  else {
     /* test passed */
  }

 
  /* Restore vectors */
  *(unsigned *)IRQVEC = previrq;
  *(unsigned *)FIQVEC = prevfiq;
  
  return(0);
}
 
 
/*---------------------------------------------------------------------
**
** irqpulsetest
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int irqpulsetest( )
#else
int irqpulsetest( )
#endif
{
  /* char      buf[80]; */
  int       cnt, cnt2;
  unsigned  prev;
 

  PULSE_TEST = 1;

  excnt = 0;  /* zero exception counter */ 
  prev = Install_Handler((unsigned ) irq_hndlr, (unsigned *) IRQVEC);
 
  MWRITE32( 0x1, 0xb0000000 );
 
  /* somewhere in here the interrupt should come through */
  cnt2 = 0;
  for (cnt = 0; (cnt != LOOP_ITER) && (!excnt); cnt++){
    cnt2++;
  }
 

  if (excnt != 1) {
     /* test failed */
  }
  else if (cnt != cnt2) {
     /* test failed */
  }
  else {
     /* test passed */
  }


 
  /* Restore vectors */
  *(unsigned *)IRQVEC = prev;

  PULSE_TEST=0;
  return(0);
}
 
 
/*---------------------------------------------------------------------
**
** fiqpulsetest
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int fiqpulsetest( )
#else
int fiqpulsetest( )
#endif
{
  /* char      buf[80]; */
  int       cnt, cnt2;
  unsigned  prev;


  PULSE_TEST = 1;
 
  excnt = 0;  /* zero exception counter */ 
  prev = Install_Handler((unsigned ) fiq_hndlr, (unsigned *) FIQVEC);
 
  MWRITE32( 0x2, 0xb0000000 );

  /* somewhere in here the interrupt should come through */
  cnt2 = 0;
  for (cnt = 0; (cnt != LOOP_ITER) && (!excnt); cnt++){
    cnt2++;
  }
 

  if (excnt != 1 ){
     /* test failed */
  }
  else if (cnt != cnt2){
     /* test failed */
  }
  else {
     /* test passed */
  }

 
 
  /* Restore vectors */
  *(unsigned *)FIQVEC = prev;

  PULSE_TEST=0;

  return(0);
}
 

/*---------------------------------------------------------------------
**
** irqfiqpulsetest
**
** Assumes interrupts already enabled in status register
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int irqfiqpulsetest( )
#else
int irqfiqpulsetest( )
#endif
{
  /* char      buf[80]; */
  int       cnt, cnt2;
  unsigned  previrq, prevfiq;
 
  PULSE_TEST = 1;

  excnt = 0;  /* zero exception counter */ 
  previrq = Install_Handler((unsigned ) irq_hndlr, (unsigned *) IRQVEC);
  prevfiq = Install_Handler((unsigned ) fiq_hndlr, (unsigned *) FIQVEC);

  MWRITE32( 0x3, 0xb0000000 );

  /* somewhere in here the interrupt should come through */
  cnt2 = 0;
  for (cnt = 0; ((cnt != LOOP_ITER) && (excnt < 1)); cnt++){
    cnt2++;
  }


  if (excnt == 0) {
     /* test failed */
  }
  else if (cnt != cnt2) {
     /* test failed */
  }
  else {
     /* test passed */
  }

 
  /* Restore vectors */
  *(unsigned *)IRQVEC = previrq;
  *(unsigned *)FIQVEC = prevfiq;

  PULSE_TEST=0;

  return(0);
}

/*---------------------------------------------------------------------
**
** IRQ 3000 TEST
**
**-------------------------------------------------------------------*/
#if (NEED_FUNC_PROTOTYPES == 1)
int irq3000test( )
#else
int irq3000test( )
#endif
{
  unsigned prev;
  /* char buf[80]; */
  int cnt, cnt2, i, test_var;

  prev = Install_Handler((unsigned ) irq_hndlr, (unsigned *) IRQVEC);

  /*
   * initialize counters
   */
  test_var = 0;
  i = 0;
  while ( i < 1000 ){
      excnt = 0;

      MWRITE32( 0x3, 0xb0000000 );

      /* somewhere in here the interrupt should come through */
      cnt2 = 0;
      for (cnt = 0; (cnt != LOOP_ITER) && (!excnt); cnt++){
         cnt2++;
      }
      if (excnt != 1 || cnt != cnt2){
         test_var = 1;
         break;
      }
      i++;
  }

  if ( i == 1000 && test_var == 0 ){
      /* test passed */
  }else if (excnt != 1 ){
      /* test failed */
  }
  else if (cnt != cnt2){
      /* test failed */
  }


  /* Restore vectors */
  *(unsigned *)IRQVEC = prev;

  return(0);
}
