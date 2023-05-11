.SUFFIXES: .c .o


INCLUDES = -I.
LDFLAGS = 
CRT =

LD=armlink
CC=armcc
AS=armasm
RM=/bin/rm -f
TCC=tcc
TAS=tasm

ARMLIB=/d/tools/ADS1.2/common/lib
CFILES=examples.c  intr_test.c
CFILES32=handlers.c

#ASFILES = init.s data.s handlers.s
ASFILES = init.s


TAS=armasm


ifeq ($(ARMTOOLSREL), SDT)
CFLAGS_LI = -c  -g -li -CPU ARM9TM -DLANGUAGE_C -DLITTLEEND
else
CFLAGS_LI = -c -g -li -CPU 5TEJ -DLANGUAGE_C -DLITTLEEND -DADS
endif

LI_OBJS  = $(CFILES:%.c=./LI/%.o) $(CFILES32:%.c=./LI/%.o) $(ASFILES:%.s=./LI/%.o)


./LI/%.o: %.c
	$(CC) $(CFLAGS_LI) $(INCLUDES) -o $@ $<

./LI/%.o: %.s
	$(AS) -li -o $@ $<


all : LI examples.axf



LI:	
	mkdir -p ./LI

examples.axf : $(LI_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(LI_OBJS) $(RTLIB_LI) ;\

clean:
	$(RM) examples.axf examples.bin $(LI_OBJS) 
