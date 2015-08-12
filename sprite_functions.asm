; base address of sprite to update is passed on stack
; FIXME: could we just pass it in HL instead?

SPRITE_RAM EQU $C000
SPRITE_RAM_SIZE EQU 160

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

UpdateSprite:
	ld hl, [SP+$02]
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	pop hl

	ld a, [hl+]
	ld [update_sprite_x], a
	ld a, [hl+]
	sub 16
	ld [update_sprite_y], a
	ld a, [hl+]
	ld [update_sprite_left_sprite], a
	ld a, [hl+]
	ld [update_sprite_right_sprite], a
	ld a, [hl+]
	sla a ;; multiply by 2
	ld [update_sprite_direction], a
	ld e, [hl]
	add a, e
	ld e, a
	inc hl
	ld d, [hl]
	ld16 update_sprite_animation, de

	ld h, $c0
	ld a, [update_sprite_left_sprite]
	ld l, a

	push hl
	ld16 hl, update_sprite_animation
	ld a, [hl]
	add a, $01
	ld b, a
	ld a, [frame_index]
	add a, b
	ld e, a
	inc hl
	ld d, [hl]
	push de
	pop hl
	ld a, [hl]
	ld [update_sprite_left_tile], a
	add a, 2
	ld [update_sprite_right_tile], a
	pop hl

	ld a, [update_sprite_y]
	ld [hl+], a
	ld a, [update_sprite_x]
	sub 8
	ld [hl+], a
	ld a, [update_sprite_left_tile]
	ld [hl], a

	ld h, $c0
	ld a, [update_sprite_right_sprite]
	ld l, a

	ld a, [update_sprite_y]
	ld [hl+], a
	ld a, [update_sprite_x]
	ld [hl+], a
	ld a, [update_sprite_right_tile]
	ld [hl], a

	ret

UpdateFrameCounter:
	ld a, [frame_counter]
	inc a
	ld [frame_counter], a
	cp 12
	jr nz, .done
	ld8i frame_counter, 0
	ld a, [frame_index]
	inc a
	ld [frame_index], a
	cp 2
	jr nz, .done
	ld8i frame_index, 0
.done
	ret
