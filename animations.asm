;; animation
;;		north anim data ptr
;;		south anim data ptr
;; 		east anim data ptr
;;		west anim data ptr
;; animation data
;; 		frame count
;; 		frame 0, frame time 0
;; 		frame 1, frame time 1
;;                ...
;; 		frame n, frame time n
animations:
player_walk:
	dw player_walk_north
	dw player_walk_south
	dw player_walk_east
	dw player_walk_west
weapon_swing:
	dw weapon_swing_north
	dw weapon_swing_south
	dw weapon_swing_east
	dw weapon_swing_west

animation_data:
player_walk_north:
	db 2
	db $08, 15
	db $0C, 15

player_walk_south:
	db 2
	db $00, 15
	db $04, 15

player_walk_east:
	db 2
	db $10, 15
	db $14, 15

player_walk_west:
	db 2
	db $18, 15
	db $1C, 15

weapon_swing_north:
	db 3
	db 52, 5
	db 48, 5
	db 44, 5

weapon_swing_south:
	db 3
	db 56, 5
	db 60, 5
	db 64, 5

weapon_swing_east:
	db 3
	db 32, 5
	db 36, 5
	db 40, 5

weapon_swing_west:
	db 3
	db 44, 5
	db 48, 5
	db 52, 5
