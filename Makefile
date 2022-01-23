#####################################################################
# Copyright (c) 2021-2022, Eric Mackay
# All rights reserved.
# 
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.
#####################################################################

CC=gcc
LD=ld
ASM=nasm
BIN=passcode

UNAME:=$(shell uname)
ifeq ($(UNAME), Linux)
	ASM_FLAGS:=-felf64 -o
	PVAL:=1
	EXVAL:=60
	LDARGS:=
	SEDSUFFIX:=
else ifeq ($(UNAME), Darwin)
	ASM_FLAGS:=-fmacho64
	PVAL:=0x02000004
	EXVAL:=0x02000001
 	LDARGS:=-e _start -arch x86_64 -lSystem -no_pie -macos_version_min $(shell sw_vers -productVersion | awk -F. '{print $$1"."$$2;}') 
	SEDSUFFIX:=''
else
$(error OS not detected. Cannot fill in syscalls.)
endif

ARCH:=$(shell uname -m)
ifeq ($(ARCH), aarch64)
	ASM=as
	ASM_FLAGS=-o 
	PVAL=64
	EXVAL=93
endif


all: $(BIN)

$(BIN): %: $(ARCH)/%.o
	$(LD) -o $@ $< $(LDARGS)
	@./$@

$(ARCH)/%.o: $(ARCH)/%.asm
	@sed $(SEDSUFFIX) 's/PRINTCALL/$(PVAL)/g' $< > $<.tmp
	@sed -i $(SEDSUFFIX) 's/EXITCALL/$(EXVAL)/g' $<.tmp
	$(ASM) $(ASM_FLAGS) $@ $<.tmp

clean:
	@rm -f *.o *.tmp */*.tmp */*.o $(BIN)
