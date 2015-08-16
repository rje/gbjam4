
INCLUDE "gbhw.inc"
INCLUDE "load1.inc"

DIR_NORTH EQU 0
DIR_SOUTH EQU 1
DIR_EAST EQU 2
DIR_WEST EQU 3

SECTION "OAM Stuff",HOME[$0000]
INCLUDE "oam.asm"

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
	call InitSystem
	ei
wait:
	call FrameUpdate
	halt
	nop
	jr wait


FrameUpdate:
	call ReadJoypad
	call HandlePlayerMovement
	ld hl, player
	push hl
	call UpdateSprite
	pop hl
	ret

InitSystem:
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

	;ld hl, dungeon_0_room_2
	;ld de, _SCRN0
	;ld bc, 32 * 16
	;call mem_CopyVRAM

	ld hl, dungeon_0
	call dungeon_LoadDungeon

	call InitSpriteRAM
	call MoveOAMFuncToHRAM
	call InitPlayer
	ld8i frame_counter, 0
	ld8i frame_index, 0

	ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON
	ld [rLCDC], a

	ld a, IEF_TIMER|IEF_LCDC|IEF_VBLANK
	ld [rIE], a
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

VBlank:
	call UpdateFrameCounter
	call OAM_DMA_TRANSFER_FUNC
	
	reti

INCLUDE "sprite_functions.asm"
INCLUDE "player.asm"
INCLUDE "joypad.asm"
INCLUDE "dungeon.asm"

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
player_animation:
	ds 2

SECTION "Variable RAM", WRAM0[$C200]
joypad:
	ds 1
joypad_prev:
	ds 1

frame_counter:
	ds 1
frame_index:
	ds 1

update_sprite_x:
	ds 1
update_sprite_y:
	ds 1
update_sprite_left_sprite:
	ds 2
update_sprite_right_sprite:
	ds 2
update_sprite_direction:
	ds 1
update_sprite_animation:
	ds 2
update_sprite_left_tile:
	ds 1
update_sprite_right_tile:
	ds 1

current_dungeon:
	ds 2
current_room:
	ds 1
current_collision:
	ds 2

SECTION "Asset Data", HOME[$4000]
INCLUDE "animations.asm"
INCLUDE "characters.z80"
INCLUDE "dungeon_tiles.z80"
INCLUDE "dungeon_0.asm"
INCLUDE "dungeon_0_room_0.z80"
INCLUDE "dungeon_0_room_1.z80"
INCLUDE "dungeon_0_room_2.z80"
INCLUDE "dungeon_0_room_3.z80"
INCLUDE "dungeon_0_room_4.z80"
INCLUDE "dungeon_0_room_5.z80"
INCLUDE "dungeon_0_room_6.z80"
