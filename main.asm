
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
	call InitPlayer

	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGOFF|LCDCF_OBJ16|LCDCF_OBJON
	ld [rLCDC], a

	ld a, IEF_TIMER|IEF_LCDC|IEF_VBLANK
	ld [rIE], a

	ei
wait:
	ld a, [player_x]
	inc a
	ld [player_x], a
	ld hl, player
	push hl
	call UpdateSprite
	pop hl
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
	call OAM_DMA_TRANSFER_FUNC
	
	reti

CopyOAMRam:
	ld a, $c0
	ld [rDMA], a
	ld a, $28
.wait
	dec a
	jr nz, .wait
	ret
CopyOAMRamEnd:

MoveOAMFuncToHRAM:
	ld hl, CopyOAMRam
	ld de, OAM_DMA_TRANSFER_FUNC
	ld bc, CopyOAMRamEnd-CopyOAMRam
	call mem_Copy

InitPlayer:
	ld a, 80
	ld [player_x], a
	ld [player_y], a
	ld a, $00
	ld [player_left_sprite], a
	ld a, $04
	ld [player_right_sprite], a
	ret

; 1 parameter on stack - addr of sprite to update
; (see Sprite RAM section starting at $C0A2)
UpdateSprite:
	ld hl, [SP+$02]
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl
	ld b, [hl] ; sprite x
	inc hl
	ld c, [hl] ; sprite y
	inc hl
	ld d, [hl] ; left sprite
	inc hl
	ld e, [hl] ; right sprite

	ld h, $c0
	ld l, d
	ld a, c ; load y
	sub 16 ; place origin at bottom
	ld c, a
	ld [hl], c

	inc hl
	ld a, b ; load x
	sub 8 ; place origin in horizontal middle
	ld [hl], a
	
	inc hl
	ld a, $00 ; FIXME: grab animation data
	ld [hl], a

	ld l, e
	ld [hl], c
	
	inc hl
	ld [hl], b

	inc hl
	ld a, $02 ; FIXME: grab animation data
	ld [hl], a

	ret

SECTION "Sprite RAM", WRAM0[$C0A2]
player:
player_x:
	ds 1
player_y:
	ds 1
player_left_sprite:
	ds 1
player_right_sprite:
	ds 1
