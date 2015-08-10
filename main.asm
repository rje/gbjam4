
INCLUDE "gbhw.inc"

SPRITE_RAM EQU $C000
SPRITE_RAM_SIZE EQU 160
OAM_DMA_TRANSFER_FUNC EQU $FF80

SECTION	"Vblank",HOME[$0040]
	nop
	jp VBlank
	
SECTION	"LCDC",HOME[$0048]
	reti

SECTION	"Timer Overflow",HOME[$0050]
	reti

SECTION	"Serial",HOME[$0058]
	reti

SECTION	"Joypad",HOME[$0060]
	reti
	
SECTION	"Start",HOME[$0100]
	nop
	jp begin	

	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE
INCLUDE "memory.inc"
INCLUDE "characters.z80"

begin:
	nop
	di
	ld sp, $ffff
init:
	ld a, %11100100
	ld [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, 0
	ld [rSCX], a
	ld [rSCY], a
	call StopLCD

	ld hl, ChractersLabel
	ld de, _VRAM
	ld bc, 8 * 4 * 16 ; 8 chars * 4 tiles per char (16x16) * 16 bytes per tile
	call mem_Copy
	ld a, 32
	ld hl, _SCRN0
	ld bc, SCRN_VX_B * SCRN_VY_B

	call mem_SetVRAM
	call InitSpriteRAM
	call MoveOAMFuncToHRAM

	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGOFF|LCDCF_OBJ16|LCDCF_OBJON
	ld [rLCDC], a

	ld a, IEF_TIMER|IEF_LCDC|IEF_VBLANK
	ld [rIE], a

	ei
wait:
	halt
	nop
	jr wait

StopLCD:
	ld a, [rLCDC]
	rlca
	ret nc
.wait:
	ld a, [rLY]
	cp 145
	jr nz,.wait

	ld a,[rLCDC]
	res 7,a
	ld [rLCDC],a

	ret

InitSpriteRAM:
	ld de, SPRITE_RAM_SIZE
	ld bc, SPRITE_RAM
.loop:
	ld a, $00
	ld [bc], a
	inc bc
	dec de
	ld a, d
	or e
	jp nz,.loop
	ret

VBlank:
	ld de, $c000
	ld a, 80
	ld [de], a
	inc de
	ld a, 76
	ld [de], a
	inc de
	ld a, 0
	ld [de], a
	inc de
	ld a, 0
	ld [de], a

	ld de, $c004
	ld a, 80
	ld [de], a
	inc de
	ld a, 84
	ld [de], a
	inc de
	ld a, 2
	ld [de], a
	inc de
	ld a, 0
	ld [de], a

	call OAM_DMA_TRANSFER_FUNC
	
	reti

; SIZE: 10 bytes - If function changes we must update size for the HRAM
; copy routine!
COPY_OAM_FUNC_SIZE EQU 10
CopyOAMRam:
	ld a, $c0
	ld [rDMA], a
	ld a, $28
.wait
	dec a
	jr nz, .wait
	ret

MoveOAMFuncToHRAM:
	ld hl, CopyOAMRam
	ld de, OAM_DMA_TRANSFER_FUNC
	ld bc, COPY_OAM_FUNC_SIZE
	call mem_Copy
