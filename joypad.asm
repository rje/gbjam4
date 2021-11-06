
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
