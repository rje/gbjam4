
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


;SPRITE_X EQU 0
;SPRITE_Y EQU 1
;SPRITE_LEFT EQU 2
;SPRITE_RIGHT EQU 3
;SPRITE_DIRECTION EQU 4
;SPRITE_ANIMATION EQU 5
;SPRITE_FRAME_COUNT EQU 7
;SPRITE_CURRENT_FRAME EQU 8
; hl - sprite addr
UpdateSprite:
	ld16 update_sprite, hl
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
	ld [update_sprite_direction], a
	sla a ;; multiply by 2
	ld e, [hl]
	add a, e
	ld e, a
	inc hl
	ld d, [hl]
	ld16 update_sprite_animation, de
	inc hl

	ld a, [hl+]
	ld [update_sprite_frame_count], a
	ld a, [hl+]
	ld [update_sprite_current_frame], a

	call sprite_UpdateFrame

	; get animation base ptr
	ld16 hl, update_sprite_animation
	ld a, [hl+]
	ld e, a
	ld a, [hl]
	ld d, a
	ld16 hl, de
	
	; get tile for animation frame
	ld de, 1
	ld a, [update_sprite_current_frame]
	sla a
	add e
	ld e, a
	add hl, de
	ld a, [hl]

	; set tile frames
	ld [update_sprite_left_tile], a
	add a, 2
	ld [update_sprite_right_tile], a

	; write left sprite values to oam ram
	ld h, $c0
	ld a, [update_sprite_left_sprite]
	ld l, a

	ld a, [update_sprite_y]
	ld [hl+], a
	ld a, [update_sprite_x]
	sub 8
	ld [hl+], a
	ld a, [update_sprite_left_tile]
	ld [hl], a

	; write right sprite values to oam ram
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

;void UpdateFrame() {
;	var frame = [update_sprite_current_frame]
;	var curCount = [update_sprite_frame_count]
;	var frameptr = [update_sprite_animation] + 1 + frame * 2
;	var count = [frameptr + 1]
;	free(frameptr)
;	curCount += 1
;	if(curCount >= count) {
;		frame += 1
;		curCount = 0
;	}
;	var numframes = [update_sprite_animation] + 0
;	if(frame >= numframes) {
;		frame = 0
;	}
;	[update_sprite_current_frame] = frame
;	[update_sprite_frame_count] = curCount
;}
sprite_UpdateFrame:
	push bc
	push de
	push hl

	ld a, [update_sprite_current_frame]
	ld b, a ; frame

	ld a, [update_sprite_frame_count]
	ld c, a ; curCount

	ld16 hl, update_sprite_animation

	ld a, [hl+]
	ld e, a
	ld a, [hl]
	ld d, a
	ld16 hl, de
	ld de, 0
	ld a, b
	sla a
	add 2
	ld e, a
	add hl, de ; frameptr
	ld a, [hl]
	ld d, a ; count
	
	ld a, c
	inc a
	ld c, a ; curCount += 1
	cp d
	jp nz, .noframeswitch ; if(curCount == count) {
	inc b ; frame += 1
	ld c, 0 ; curCount = 0
.noframeswitch ; }
	ld16 hl, update_sprite_animation
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld16 hl, de
	ld a, [hl]
	ld d, a ; numframes
	ld a, b ; frame
	cp d
	jp nz, .noanimloop ; if(frame == numframes) {
	ld b, 0 ; frame = 0
.noanimloop

	ld a, b
	ld [update_sprite_current_frame], a

	ld a, c
	ld [update_sprite_frame_count], a

	ld16 hl, update_sprite
	ld de, SPRITE_CURRENT_FRAME
	add hl, de
	ld a, b
	ld [hl], a

	ld16 hl, update_sprite
	ld de, SPRITE_FRAME_COUNT
	add hl, de
	ld a, c
	ld [hl], a

	pop hl
	pop de
	pop bc
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
