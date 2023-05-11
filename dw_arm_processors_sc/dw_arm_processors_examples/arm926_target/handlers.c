#include <stdio.h>
#include <stdlib.h>
#include <examples.h>

int excnt;
extern int PULSE_TEST;
extern int Entry;

#define RAM_Base   0x10000000      ; 64k RAM at this base
#define RAM_Limit  0x10010000
#define IRQ_Stack  RAM_Limit-256   ; 1K IRQ stack at top of memory
#define SVC_Stack  RAM_Limit-1024  ; followed by SVC stack
#define USR_Stack  SVC_Stack-1024  ; followed by USR stack
#define FIQ_Stack  USR_Stack-1024  ; followed by FIQ stack
#define ABT_Stack  FIQ_Stack-1024  ; followed by Abort stack


#define Mode_USR  0x10
#define Mode_FIQ  0x11
#define Mode_SVC  0x13

#define I_Bit     0x80
#define F_Bit     0x40


/* SWI to fiddle with interrupt mask */
void __swi(0x256) SWI_enableINTRS(int bits);
 
 
/* THIS NEEDS TO BE IN ASSEMBLY IN ORDER TO PERFORM THE CORRECT RETURN???? */
void __irq irq_hndlr()
 
{
 /*  unsigned char romv; */
  U8 answer;
  pU8 pAnswer = &answer;


  if ( PULSE_TEST != 1 ){
   	MWRITE32( 0x0, 0xb0000000 );  
  }
  excnt++;
 
  /*
   * add mem read so that we don't end up getting multiple
   * interrupts (looks to be a VSP problem)
  ** For some reason ADS does not like the use of
  ** the statement below to read from ROM.  Must use
  ** the MREAD32 macro.
   *
   *romv = *(unsigned char *) ROMSTART;
   *romv = *(unsigned char *) ROMSTART;
   *romv = *(unsigned char *) ROMSTART;
   *romv = *(unsigned char *) ROMSTART;
   */
  
  MREAD32(pAnswer, (VSPADR) ROMSTART);


}

void __irq fiq_hndlr()
{
  /* unsigned char romv; */
  U8 answer;
  pU8 pAnswer = &answer;


  if ( PULSE_TEST != 1 ){
   	MWRITE32( 0x0, 0xb0000000 );
  }
  excnt++;

  /*
   * add mem read so that we don't end up getting multiple
   * interrupts (looks to be a VSP problem)
   *
  ** For some reason ADS does not like the use of
  ** the statement below to read from ROM.  Must use
  ** the MREAD32 macro.
  ** romv = *(unsigned char *) ROMSTART;
  ** romv = *(unsigned char *) ROMSTART;
  ** romv = *(unsigned char *) ROMSTART;
   */

  MREAD32(pAnswer, (VSPADR) ROMSTART);

 
}


void __irq hndlr()
{
   excnt++;
}

void __irq nop_hndlr()
{
}

/* copied from 11-12 in Programming Techniques manual */
unsigned Install_Handler(unsigned routine, unsigned *vector)
{
   unsigned vec, oldvec;
   vec = ((routine - (unsigned) vector - 0x8) >> 2);
   if (vec & 0xff000000) {
   }
   vec = 0xea000000 | vec;
   oldvec = *vector;

   *vector = vec;

   return(oldvec);
}

#if 0
void __irq IRQHandler(void)
{
    /* Turn off the IRQ signal */
    MWRITE32( 0x0, 0xb0000000 );
}

void __irq FIQHandler(void)
{
     /* Turn off the FIQ signal */
     MWRITE32( 0xb0000000, 0x0);
}
#endif

void __irq DABORTHandler()
{
    excnt++;
    /* need to return to LR - 8 - see page 11-7 */
    /*  exit(0); */
}

void __irq IABORTHandler()
{
#if 0
    exit(0);
#endif
}

void __irq RESETHandler()
{
  if ( PULSE_TEST != 1 ){
        MWRITE32( 0x8, 0xb0000000 );    /* remove reest but leave hi vecs */
  }
  excnt++;
}

void __irq UNDEFHandler()
{
}

void SWIHandler(void)
{
   /* this must be coded in assembly - refer to 11-8 */
}

void init_interrupts(void)
{
    Install_Handler((unsigned ) RESETHandler,  (unsigned *) 0x00);
    Install_Handler((unsigned ) UNDEFHandler,  (unsigned *) 0x04);
    Install_Handler((unsigned ) SWIHandler,    (unsigned *) 0x08);
    Install_Handler((unsigned ) IABORTHandler, (unsigned *) 0x0c);
    Install_Handler((unsigned ) DABORTHandler, (unsigned *) 0x10);
    Install_Handler((unsigned ) irq_hndlr,    (unsigned *) 0x18);
    Install_Handler((unsigned ) fiq_hndlr,    (unsigned *) 0x1c);
}
