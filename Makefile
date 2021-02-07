CC=gcc
LD=ld
ASM=nasm
ASM_FLAGS=-felf64
BIN=passcode

all: $(BIN)

$(BIN): %: %.o
	$(LD) -o $@ $<
	@./$@

%.o: %.asm
	$(ASM) $(ASM_FLAGS) $<

clean:
	@rm -f *.o $(BIN)
