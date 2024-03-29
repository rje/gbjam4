

ASM=rgbasm
LINK=rgblink
FIX=rgbfix
EMU=../bgbw64/bgb64.exe
#EMU=no$$gmb

GAME=rjegbjam

OBJS=main.o

all: build
	@echo "Done building!"

run: clean build
	$(EMU) $(GAME).gb
	

build: $(OBJS)
	$(LINK) -t -m $(GAME).map -n $(GAME).sym -p 0 -o $(GAME).gb $(OBJS)
	$(FIX) -v -p 0 -i rgj4 -k re -m 0 -n 0 -r 0 -t gbjam4 $(GAME).gb

%.o: %.asm
	$(ASM) -Wall -o $@ $<

%.o: %.z80
	$(ASM) -Wall -o $@ $<

clean:
	rm -f $(OBJS)
	rm -f $(GAME).gb
	rm -f $(GAME).map
	rm -f $(GAME).sym
