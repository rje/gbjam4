
InitPlayer:
	ld8i player_x, 88
	ld8i player_y, 100
	ld8i player_left_sprite, 0
	ld8i player_right_sprite, 4
	ld8i player_direction, DIR_SOUTH
	ld16i player_animation, player_walk
	ld8i player_current_frame, 0
	ld8i player_frame_count, 0

	ld8i weapon_x, 30
	ld8i weapon_y, 30
	ld8i weapon_left_sprite, 8
	ld8i weapon_right_sprite, 12
	ld8i weapon_direction, DIR_SOUTH
	ld16i weapon_animation, weapon_swing
	ld8i weapon_current_frame, 0
	ld8i weapon_frame_count, 0
	ret

; b - x pos
; c - y pos
; hl - base addr
;
; hl - return value, offset addr to tile
CalculateTileAddr:
	push af
	push de
	srl b
	srl b
	srl b
	srl c
	srl c
	srl c
	ld d, 0
	ld e, b
	add hl, de
.loop
	ld a, c
	cp 0
	jr z,.done

	dec c
	ld e, 20
	add hl, de
	jp .loop

.done	
	pop de
	pop af
	ret

HandlePlayerMovement:
	ld a, [player_direction]
	ld d, a
	ld a, [joypad]
	ld b, PADF_LEFT
	and b
	jr z,.noleft
	ld8i player_direction, DIR_WEST
	ld8i weapon_direction, DIR_WEST
	ld a, [player_x]
	dec a
	sub 12
	ld b, a
	ld a, [player_y]
	sub 20
	ld c, a
	ld16 hl, current_collision
	call CalculateTileAddr
	ld a, [hl]
	cp 0
	jp nz, .noleft
	ld a, [player_x]
	dec a
	ld [player_x], a
	jp .done
.noleft:
	ld a, [joypad]
	ld b, PADF_RIGHT
	and b
	jr z,.noright
	ld8i player_direction, DIR_EAST
	ld8i weapon_direction, DIR_EAST
	ld a, [player_x]
	inc a
	sub 4
	ld b, a
	ld a, [player_y]
	sub 20
	ld c, a
	ld16 hl, current_collision
	call CalculateTileAddr
	ld a, [hl]
	cp 0
	jp nz, .noright
	ld a, [player_x]
	inc a
	ld [player_x], a
	jp .done
.noright
	ld a, [joypad]
	ld b, PADF_UP
	and b
	jr z,.noup
	ld8i player_direction, DIR_NORTH
	ld8i weapon_direction, DIR_NORTH
	ld a, [player_x]
	sub 8
	ld b, a
	ld a, [player_y]
	dec a
	sub 20
	ld c, a
	ld16 hl, current_collision
	call CalculateTileAddr
	ld a, [hl]
	cp 0
	jp nz, .noup
	ld a, [player_y]
	dec a
	ld [player_y], a
	jp .done
.noup
	ld a, [joypad]
	ld b, PADF_DOWN
	and b
	jr z,.nodown
	ld8i player_direction, DIR_SOUTH
	ld8i weapon_direction, DIR_SOUTH
	ld a, [player_x]
	sub 8
	ld b, a
	ld a, [player_y]
	inc a
	sub 20
	ld c, a
	ld16 hl, current_collision
	call CalculateTileAddr
	ld a, [hl]
	cp 0
	jp nz, .nodown
	ld a, [player_y]
	inc a
	ld [player_y], a
	jp .done
.nodown
.done
	ld a, [player_direction]
	cp a, d
	jp z, .nochange
	ld8i player_frame_count, 0
	ld8i player_current_frame, 0
	ld8i weapon_frame_count, 0
	ld8i weapon_current_frame, 0
.nochange
	ld a, [player_x]
	add 10
	ld [weapon_x], a
	ld a, [player_y]
	add 12
	ld [weapon_y], a
	call player_CheckForTransition
	ret

player_CheckForTransition:
	ld a, [player_y]
	cp 22
	jp nc,.nonorthtrans
	call player_DoTransition
	ret
.nonorthtrans
	cp 146
	jp c,.nosouthtrans
	call player_DoTransition
	ret
.nosouthtrans
	ld a, [player_x]
	cp 160
	jp c, .noeasttrans
	call player_DoTransition
	ret
.noeasttrans
	cp 8
	jp nc, .nowesttrans
	call player_DoTransition
	ret
.nowesttrans
	ret

player_DoTransition:
	di
	call StopLCD
	call dungeon_MoveToNextRoom

	ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJON
	ld [rLCDC], a
	
	ei
	ret
