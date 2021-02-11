CC=gcc
LD=ld
ASM=nasm
ASM_FLAGS=-felf64
BIN=passcode

UNAME:=$(shell uname)
ifeq ($(UNAME), Linux)
	PVAL:=1
	EXVAL:=60
	LDARGS:=
	SEDSUFFIX:=
else ifeq ($(UNAME), Darwin)
	PVAL:=0x02000004
	EXVAL:=0x02000001
	LDARGS:=-lSystem
	SEDSUFFIX:=''
else
$(error OS not detected. Cannot fill in syscalls.)
endif

all: $(BIN)

$(BIN): %: %.o
	$(LD) -o $@ $< $(LDARGS)
	@./$@

%.o: %.asm
	@sed -i $(SEDSUFFIX) 's/PRINTCALL/$(PVAL)/g' $<
	@sed -i $(SEDSUFFIX) 's/EXITCALL/$(EXVAL)/g' $<
	$(ASM) $(ASM_FLAGS) $<

clean:
	@rm -f *.o $(BIN)
