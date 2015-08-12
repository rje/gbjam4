
InitPlayer:
	ld a, 80
	ld [player_x], a
	ld [player_y], a
	ld a, $00
	ld [player_left_sprite], a
	ld a, $04
	ld [player_right_sprite], a
	ld a, DIR_SOUTH
	ld [player_direction], a
	ld16i player_animation, player_walk
	ld [hl], e
	inc hl
	ld [hl], d
	ret

HandlePlayerMovement:
	ld a, [joypad]
	ld d, a
	ld b, PADF_LEFT
	and b
	jr z,.noleft
	ld a, [player_x]
	dec a
	ld [player_x], a
	ld8i player_direction, DIR_WEST
	jp .done
.noleft:
	ld a, d
	ld b, PADF_RIGHT
	and b
	jr z,.noright
	ld a, [player_x]
	inc a
	ld [player_x], a
	ld8i player_direction, DIR_EAST
	jp .done
.noright
	ld a, d
	ld b, PADF_UP
	and b
	jr z,.noup
	ld a, [player_y]
	dec a
	ld [player_y], a
	ld8i player_direction, DIR_NORTH
	jp .done
.noup
	ld a, d
	ld b, PADF_DOWN
	and b
	jr z,.nodown
	ld a, [player_y]
	inc a
	ld [player_y], a
	ld8i player_direction, DIR_SOUTH
	jp .done
.nodown
.done
	ret
