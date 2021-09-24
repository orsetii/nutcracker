# All non-source files that are part of the distribution.
AUXFILES := Makefile README.md LICENSE assets/WalnutComplete.svg  assets/WalnutLogoOnly.svg scripts/qemu.sh

include .test_kmain.mk

#ifdef TEST_KMAIN
	TEST_KMAIN := 1
#endif

# Sub directories holding the actual sources
PROJDIRS := src

# Gets all source files
SRCFILES := $(shell find $(PROJDIRS) -type f -name "*.c")
ASMSRCFILES := $(shell find $(PROJDIRS) -type f -name "*.s")
HDRFILES := $(shell find $(PROJDIRS) -type f -name "*.h")

# Gets all object files and test driver executables
OBJFILES := $(filter %.o,$(patsubst %.s,%.o,$(ASMSRCFILES))) \
			$(patsubst %.c,%.o,$(SRCFILES))
TSTFILES := $(patsubst %.c,%_t,$(SRCFILES))

# Create dependency files to automatically provide the correct
# header files to a source file
TSTDEPFILES := $(patsubst %,%.d,$(TSTFILES))
DEPFILES := $(patsubst %,%.d,$(SRCFILES))

# Contains all sources, headers and auxilary files
ALLFILES := $(SRCFILES) $(HDRFILES) $(AUXFILES)

# GCC Flags
CC := gcc
WARNINGS := -Wall -Wextra -Wshadow -Wpointer-arith -Wcast-align \
	-Wwrite-strings \
	-Wredundant-decls -Wnested-externs -Winline -Wno-long-long \
	-Wconversion -Wstrict-prototypes

# Flags for C code
CSTD := gnu17
CFLAGS := -g -std=$(CSTD) $(WARNINGS) -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2

# Flags for assembly code
AS := nasm
ASMFLAGS := -g -felf64
# Linker Flags
LD := ld
LDFLAGS := 
# Archiver Flags
AR := ar
ARFLAGS := -rcs

# Targets
.PHONY: all clean dist check testdrivers todolist run

all: libnutcracker.a

run: nutcracker.bin
	./scripts/qemu.sh ./nutcracker.bin
	
# Compiles to an archive to be linked with the kernel
libnutcracker.a: $(OBJFILES)
	@$(AR) $(ARFLAGS) libnutcracker.a $?
# Compiles to a bootable binary which can then be run via qemu script
nutcracker.bin: $(OBJFILES)
	@$(LD) $(LDFLAGS) $? -o nutcracker.bin

	
clean:
	-@$(RM) $(wildcard $(shell find $(PROJDIRS) -type f -name "*.o" -o -name "*.d" -o -name "*.*_t") \
		libnutcracker.a nutcracker.bin)
	
dist:
	@tar czf nutcracker.tgz $(ALLFILES)

check: testdrivers
	# This leading '-' below means that Make will 
	# not abort when encountering an error but continue in the loop
	-@rc=0; count=0; \
	for file in $(TSTFILES); do \
	echo " TST     $$file"; ./$$file; \
	rc=`expr $$rc + $$?`; count=`expr $$count + 1`; \
	done; \
	echo; echo "Tests executed: $$count  Tests failed: $$rc"
	
testdrivers: $(TSTFILES)

-include $(DEPFILES) $(TSTDEPFILES)

# Find and print all 'TODO' or 'FIXME' lines
todolist:
	-@for file in $(ALLFILES:Makefile=); do fgrep -H -e TODO -e FIXME $$file; done; true

# Rules

# Via GCC dependency magic, this will compile all sources correctly :D
#
# The -MMD flag generates the dependency file (%.d), 
# which will hold (in Makefile syntax) rules making the generated 
# file (%.o in this case) depend on the source file 
# and any non-system headers it includes.
%.o: %.c Makefile
ifdef TEST_KMAIN
	@$(CC) $(CFLAGS) -DTEST_KMAIN=1 -MMD -MP -c $< -o $@
else
	@$(CC) $(CFLAGS) -MMD -MP -c $< -o $@
endif

%.o: %.s Makefile
	@$(AS) $(ASMFLAGS) $< -o $@


# Test driver executables compilation
%_t: %.c Makefile nutcracker.o
	@$(CC) $(CFLAGS) -MMD -MP -DTEST $< nutcracker.o -o $@
