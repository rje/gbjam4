
DUNGEON_TILES_OFFSET EQU 0
DUNGEON_START_ROOM_OFFSET EQU 2
DUNGEON_START_X_OFFSET EQU 3
DUNGEON_START_Y_OFFSET EQU 4
DUNGEON_ROOM_COUNT_OFFSET EQU 5
DUNGEON_ROOM_LIST_OFFSET EQU 6
DUNGEON_COLLISION_LIST_OFFSET EQU 8
DUNGEON_TRANSITION_LIST_OFFSET EQU 10

; screen/interrupts must be off!
; hl - dungeon base addr
dungeon_LoadDungeon:
	push de
	ld16 current_dungeon, hl
	; load tiles
	ld de, DUNGEON_TILES_OFFSET
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld16 hl, de
	ld de, $8800
	ld bc, 128 * 16
	call mem_Copy
	
	; set current room variable
	ld16 hl, current_dungeon
	ld de, DUNGEON_START_ROOM_OFFSET
	add hl, de
	ld a, [hl]
	ld [current_room], a

	; load room
	call dungeon_LoadRoom

	; move player to start
	pop de
	ret

; screen/interrupts must be off!
dungeon_LoadRoom:
	; load room tiles
	ld16 hl, current_dungeon
	ld de, DUNGEON_ROOM_LIST_OFFSET
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl
	ld a, [current_room]
	sla a
	ld e, a
	ld d, 0
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld16 hl, de
	ld de, _SCRN0
	call dungeon_CopyRoom

	; set collision info
	ld16 hl, current_dungeon
	ld de, DUNGEON_COLLISION_LIST_OFFSET 
	add hl, de							; jump to variable list
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl
	ld a, [current_room]
	ld d, 0
	ld e, a
	sla e
	add hl, de							; offset by room index
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld16 current_collision, de

	ret

; hl - base data addr
; de - dest data addr
dungeon_CopyRoom:
	push af
	ld b, 20 ; x counter
	ld c, 16 ; y counter
.outerloop
	dec c

.innerloop
	dec b

	ld a, [hl+]
	push hl
	ld16 hl, de
	ld [hl], a
	inc de
	pop hl

	ld a, b
	cp 0
	jp nz, .innerloop

	ld b, 20
	push bc
	ld c, 12
	ld b, 0
	push hl
	ld16 hl, de
	add hl, bc
	ld16 de, hl
	pop hl
	pop bc
	ld a, c
	cp 0
	jp nz, .outerloop

	pop af
	ret

dungeon_MoveToNextRoom:
	ld16 hl, current_dungeon
	ld de, DUNGEON_TRANSITION_LIST_OFFSET 
	add hl, de							
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl						; jump to variable list
	ld a, [current_room]
	sla a
	sla a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [player_direction]
	ld e, a
	add hl, de
	ld a, [hl]
	ld [current_room], a
	call dungeon_LoadRoom

	ld a, [player_direction]
	cp DIR_NORTH
	jp z, .northjump
	cp DIR_SOUTH
	jp z, .southjump
	cp DIR_WEST
	jp z, .westjump
	cp DIR_EAST
	jp z, .eastjump
	ret

.northjump
	ld8i player_y, 145
	ret
.southjump
	ld8i player_y, 23
	ret
.westjump
	ld8i player_x, 159
	ret
.eastjump
	ld8i player_x, 9
	ret
