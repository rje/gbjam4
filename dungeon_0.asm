

dungeon_0:
dungeon_0_tiles:
	dw dungeon_tiles
dungeon_0_start_room:
	db 0
dungeon_0_start_x:
	db 80
dungeon_0_start_y:
	db 140
dungeon_0_num_rooms:
	db 4
dungeon_0_room_list:
	dw dungeon_0_rooms
dungeon_0_collision_list:
	dw dungeon_0_collision
dungeon_0_transition_list:
	dw dungeon_0_transitions
	

dungeon_0_rooms:
	dw dungeon_0_room_0
	dw dungeon_0_room_1
	dw dungeon_0_room_2
	dw dungeon_0_room_3
	dw dungeon_0_room_4
	dw dungeon_0_room_5
	dw dungeon_0_room_6

dungeon_0_collision:
	dw dungeon_0_room_0PLN1
	dw dungeon_0_room_1PLN1
	dw dungeon_0_room_2PLN1
	dw dungeon_0_room_3PLN1
	dw dungeon_0_room_4PLN1
	dw dungeon_0_room_5PLN1
	dw dungeon_0_room_6PLN1

dungeon_0_transitions:
	;; north, south, east, west
	db $FF, $FF, $03, $01
	db $05, $02, $00, $FF
	db $01, $FF, $FF, $FF
	db $06, $04, $FF, $00
	db $03, $FF, $FF, $FF
	db $FF, $01, $FF, $FF
	db $FF, $03, $FF, $FF
