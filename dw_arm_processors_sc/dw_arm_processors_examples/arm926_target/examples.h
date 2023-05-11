/*  defines a 64 bit word in LSB and MSB data words */


/*
 * Handle function declarations for C, ANSI C, and C++
 */
#ifndef _EI_FUNC_PROTO_H_
#       define _EI_FUNC_PROTO_H_
#       ifndef NEED_FUNC_PROTOTYPES
#               if defined(FUNCPROTO) || defined(__STDC__) || \
                   defined(__cplusplus) || defined(c_plusplus) || \
                   defined(_MSC_VER)
#                       define NEED_FUNC_PROTOTYPES 1
#               else    /* FUNCPROTO */
#                       define NEED_FUNC_PROTOTYPES 0
#               endif   /* FUNCTPROTO */
#       endif   /* NEED_FUNC_PROTOTYPES */
#       ifndef FUNC_PROTOTYPE_BEG
#               ifdef __cplusplus
#                       define FUNC_PROTOTYPE_BEG extern "C" {
#                       define FUNC_PROTOTYPE_END }
#               else    /* __cplusplus */
#                       define FUNC_PROTOTYPE_BEG
#                       define FUNC_PROTOTYPE_END
#               endif   /* __cplusplus */
#       endif   /* FUNC_RPTOTYPE_BEG */
#endif  /* _EI_FUNC_PROTO_H */




typedef char              CHAR, *pCHAR;
typedef unsigned char     U8,   *pU8;
typedef unsigned short    U16,  *pU16;
typedef long int          S32,  *pS32;
typedef unsigned long int U32,  *pU32;
typedef struct _vspU64
{
        U32 vspHigh;
        U32 vspLow;
} U64, *pU64;

typedef U32               VSPADR,     *pVSPADR;
typedef U64               VSPSIMTIME, *pVSPSIMTIME;


/*
 * extern defns
 */
extern int ram8test(void);
extern int ram16test(void);
extern int ram32test(void);

#define MWRITE8(data, addr)       *((pU8) (addr)) = (data) 
#define MREAD8(data, addr)        *(data) = *((pU8) (addr)) 
#define MWRITE16(data, addr)      *((pU16) (addr)) = (data) 
#define MREAD16(data, addr)       *(data) = *((pU16) (addr)) 
#define MWRITE32(data, addr)      *((pU32) (addr)) = (data) 
#define MREAD32(data, addr)       *(data) = *((pU32) (addr)) 
#define MWRITE64(data, addr)      *((pU64) (addr)) = (data) 
#define MREAD64(data, addr)       *(data) = *((pU64) (addr)) 


struct int64
{
   int lw0;
   int lw1;
};

/*  SBC Memory Mapping */
#define ROMSTART     0x90000000
#define ROMEND       0x900003ff 
#define RAMSTART16   0x90000000
#define RAMEND16     0x9000000f
#define RAMSTART32   0x90000000
#define RAMEND32     0x9000000f
#define ITCMSTART     0xFF000
#define ITCMEND       0xFF00f
#define DTCMSTART     0x20000
#define DTCMEND       0x2000f
#define CHK_ADDRESSES   0x10

#define SemiSWI 0x123456

#define DABORTADDR 0x0d000000   /* addrto try to read/write to cause data abort
*/
#define DABORTVEC  0x10         /* Data abort vector */
#define RESETVEC   0x08         /* RESET vector */
#define IRQVEC     0x18         /* IRQ vector */
#define FIQVEC     0x1c         /* FIQ vector */
#define CNTLREG    0xf0000000   /* Design address of control reg */

/* Write a character */
__swi(SemiSWI) void _WriteC(unsigned op, const char *c);
#define PrintChar(c) _WriteC (0x3,c)

/* Write a string */
__swi(SemiSWI)void _Write0(unsigned op, const char *string);
#define PrintStr(string) _Write0 (0x4,string)

extern int term_write_str(char *);
