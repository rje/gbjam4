

ASM=rgbasm
LINK=rgblink
FIX=rgbfix
EMU=bgb

GAME=rjegbjam

OBJS=main.o

all: build
	@echo "Done building!"

run:
	$(EMU) $(GAME).gb
	

build: $(OBJS)
	$(LINK) -m $(GAME).map -n $(GAME).sym -p 0 -o $(GAME).gb $(OBJS)
	$(FIX) -v $(GAME).gb

%.o: %.asm
	$(ASM) -o $@ $<

clean:
	rm -f $(OBJS)
	rm -f $(GAME).gb
	rm -f $(GAME).map
	rm -f $(GAME).sym
