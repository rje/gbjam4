
INCLUDE "gbhw.inc"
INCLUDE "load1.inc"

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

begin:
	nop
	di
	ld sp, $ffff
init:
	ld a, %11100100
	ld [rBGP], a
	ld a, %11010000
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

	ld hl, dungeon_tiles
	ld de, $8800
	ld bc, 54 * 16
	call mem_Copy

	ld hl, test_room_0
	ld de, _SCRN0
	ld bc, $400
	call mem_CopyVRAM

	call InitSpriteRAM
	call MoveOAMFuncToHRAM
	call InitPlayer

	ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON
	ld [rLCDC], a

	ld a, IEF_TIMER|IEF_LCDC|IEF_VBLANK
	ld [rIE], a

	ei
wait:
	call ReadJoypad
	call HandlePlayerMovement
	ld hl, player
	push hl
	call UpdateSprite
	pop hl
	halt
	nop
	jr wait

HandlePlayerMovement:
	ld a, [joypad]
	ld d, a
	ld b, PADF_LEFT
	and b
	jr z,.noleft
	ld a, [player_x]
	dec a
	ld [player_x], a
.noleft:
	ld a, d
	ld b, PADF_RIGHT
	and b
	jr z,.noright
	ld a, [player_x]
	inc a
	ld [player_x], a
.noright
	ld a, d
	ld b, PADF_UP
	and b
	jr z,.noup
	ld a, [player_y]
	dec a
	ld [player_y], a
.noup
	ld a, d
	ld b, PADF_DOWN
	and b
	jr z,.nodown
	ld a, [player_y]
	inc a
	ld [player_y], a
.nodown
	ret

ReadJoypad:
	ld a, $20
	ld [$FF00], a
	ld a, [$FF00]
	ld a, [$FF00]
	cpl
	and $0F
	swap a
	ld b, a
	ld a, $10
	ld [$FF00], a
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	cpl
	and $0F
	or b
	ld d, a
	ld a, [joypad]
	ld [joypad_prev], a
	ld a, d
	ld [joypad], a
	ret

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
	ld a, $00
	ld [player_direction], a
	ld16i player_animation, player_walk
	ld [hl], e
	inc hl
	ld [hl], d
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
player_direction:
	ds 1
	ds 1 ;; padding
player_animation:
	ds 2

SECTION "Variable RAM", WRAM0[$C200]
joypad:
	ds 1
joypad_prev:
	ds 1

SECTION "Asset Data", HOME[$4000]
;; animation
;;		north anim data ptr
;;		south anim data ptr
;; 		east anim data ptr
;;		west anim data ptr
;; animation data
;; 		frame count
;; 		frame 0
;; 		frame 1
;; 		frame n
animations:
player_walk:
	dw player_walk_north
	dw player_walk_south
	dw player_walk_east
	dw player_walk_west

animation_data:
player_walk_north:
	db 2
	db $08
	db $0C

player_walk_south:
	db 2
	db $00
	db $04

player_walk_east:
	db 2
	db $10
	db $14

player_walk_west:
	db 2
	db $18
	db $1C

INCLUDE "characters.z80"
INCLUDE "dungeon_tiles.z80"
INCLUDE "test_room_0.z80"
