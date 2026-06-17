    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe playfield1.s -o playfield1

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

SCREENWIDTH		equ		320
SCREENHEIGHT	equ		256
NUMPLANES		equ		1
MODULO			equ		(NUMPLANES-1)*(SCREENWIDTH/8)

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
	SAVE_COPPER						; salvar puntero a copperlist
		
	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist

	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist
	
	;bset	#7,(screenBuffer)		; activa el primer bit del buffer de pantalla
	
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
	            
	dc.w 	COLOR00,$0000			; COLOR 0
	dc.w 	COLOR01,$0fff			; COLOR 1

	; ----- BITPLANES -----

CopBplP0:
	dc.w 	BPL1PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL1PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos)

CopBPLCON0:
	dc.w 	BPLCON0,NUMPLANES<<12	; BPLCON0 / Habilitar NUMPLANES bitplanes

	dc.w 	$ffff,$fffe			    ; FIN copperlist

screenBuffer:
	REPT (SCREENWIDTH/8)*SCREENHEIGHT*NUMPLANES
	dc.b	%01010101
	ENDR
	
	;REPT 128
	;blk.b			SCREENWIDTH/8,%00000000
	;blk.b			SCREENWIDTH/8,%11111111	
	;ENDR
	
oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN
