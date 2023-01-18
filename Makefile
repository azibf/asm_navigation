ASM=nasm
ASMFLAGS=bin
TARGET=main.COM
SOURCE=main.asm
DOSBOX=dosbox

BATFILE=RUN.BAT

$(TARGET):
	$(ASM) -f $(ASMFLAGS) $(SOURCE) -o $(TARGET)

clean:
	rm $(TARGET)

dosbox: $(TARGET)
	$(DOSBOX) ./$(BATFILE)
