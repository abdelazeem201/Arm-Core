#ifndef __intr_h__
#define __intr_h__ intr.h

extern void     hndlr(void);
extern void     irq_hndlr(void);
extern void     fiq_hndlr(void);
extern void     RESETHandler(void);
extern void     DABORTHandler(void);
extern unsigned Install_Handler(unsigned routine, unsigned *vector);
#endif
