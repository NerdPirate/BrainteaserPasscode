CC=gcc
LD=ld
ASM=nasm
BIN=passcode

UNAME:=$(shell uname)
ifeq ($(UNAME), Linux)
	ASM_FLAGS:=-felf64
	PVAL:=1
	EXVAL:=60
	LDARGS:=
	SEDSUFFIX:=
else ifeq ($(UNAME), Darwin)
	ASM_FLAGS:=-fmacho64
	PVAL:=0x02000004
	EXVAL:=0x02000001
	LDARGS:=-e _start -arch x86_64 -lSystem -L$(xcode-select -p)/SDKs/MacOSX.sdk/usr/lib -macosx_version_min $(sw_vers -productVersion)
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
