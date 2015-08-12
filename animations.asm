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
