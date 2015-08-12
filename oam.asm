
OAM_DMA_TRANSFER_FUNC EQU $FF80
EXPORT OAM_DMA_TRANSFER_FUNC

CopyOAMRam:
	ld a, $c0
	ld [rDMA], a
	ld a, $28
.wait
	dec a
	jr nz, .wait
	ret
CopyOAMRamEnd:

MoveOAMFuncToHRAM:
	ld hl, CopyOAMRam
	ld de, OAM_DMA_TRANSFER_FUNC
	ld bc, CopyOAMRamEnd-CopyOAMRam
	call mem_Copy
