    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe playfield1b.s -o playfield1b
	
	; para convertir una iff a raw:
	; IFFConverter <fichero/directorio de entrada> <directorio de salida> num_planes [-spr16]
	;		-spr16  convert to attached sprites data: even sprite data will be in the first half and odd sprite data in the second half of the output file
	; Ejemplo: java -jar d:\amigahd\sources\bin\IFFConverter.jar Lost_In_The_Cave.iff . 5

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

SCREENWIDTH		equ		320
SCREENHEIGHT	equ		256
NUMPLANES		equ		5
MODULO			equ		(NUMPLANES-1)*(SCREENWIDTH/8)

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
	SAVE_COPPER						; salvar puntero a copperlist
		
	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist
	
	bset	#7,(screenBuffer)		; activa el primer bit del buffer de pantalla
	
main:
    CHECK_LMB						; comprobar botón izquierdo ratón

exit:
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar copperlist
	moveq	#0,d0
	rts

	; ----------------
	; ----- DATA -----
	; ----------------

	section amigaWaveDataC,DATA_C

copperlist:	
	dc.w 	DIWSTRT,$2c81			; DIWSTRT = display window start (Y = $02c, X = $081)
	dc.w 	DIWSTOP,$2cc1			; DIWSTOP = display window stop  (Y = $12c, X = $1c1)
	dc.w 	DDFSTRT,$0038			; DDFSTRT = data fetch start
	dc.w 	DDFSTOP,$00d0			; DDFSTOP = data fetch stop
	dc.w 	BPL1MOD,MODULO			; BPL1MOD		
	dc.w 	BPL2MOD,MODULO			; BPL2MOD

	; ----- PALETTE -----

	dc.w	$0180,$0000,$0182,$0fea,$0184,$0cf9,$0186,$0fe6
	dc.w	$0188,$0aef,$018a,$0fc4,$018c,$0eb8,$018e,$0fa5
	dc.w	$0190,$0ac7,$0192,$07bf,$0194,$09aa,$0196,$0d83
	dc.w	$0198,$04ae,$019a,$0a86,$019c,$0b72,$019e,$0683
	dc.w	$01a0,$0a51,$01a2,$0565,$01a4,$026b,$01a6,$0741
	dc.w	$01a8,$0351,$01aa,$0245,$01ac,$0623,$01ae,$0530
	dc.w	$01b0,$0332,$01b2,$0134,$01b4,$0221,$01b6,$0022
	dc.w	$01b8,$0400,$01ba,$0110,$01bc,$0011,$01be,$0fff
    
	; ----- BITPLANES -----

CopBplP0:
	dc.w 	BPL1PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL1PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos)

    dc.w 	BPL2PTH,$0000
    dc.w 	BPL2PTL,$0000

    dc.w 	BPL3PTH,$0000
    dc.w 	BPL3PTL,$0000

    dc.w 	BPL4PTH,$0000
    dc.w 	BPL4PTL,$0000

    dc.w 	BPL5PTH,$0000
    dc.w 	BPL5PTL,$0000

CopBPLCON0:
	dc.w 	BPLCON0,NUMPLANES<<12	; BPLCON0 / Habilitar NUMPLANES bitplanes

	dc.w 	$ffff,$fffe			    ; FIN copperlist

screenBuffer:
    incbin          "xeno.raw"
	
oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN
