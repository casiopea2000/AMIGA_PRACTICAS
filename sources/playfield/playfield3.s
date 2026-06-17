    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe playfield3.s -o playfield3

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

SCREENWIDTH		equ		320
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
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

	moveq	#15,d0					; desplazamiento del playfield 1				

main:
	WAIT_VB							; esperar al vertical blank
	WAIT_VB2						; segunda espera porque el bucle dura menos que una línea del barrido

	lea		scrollValues,a0			; a0 = puntero a copperlist
	subq	#1,d0					; restar 1 al desplazamiento del playfield 1
	tst.b	d0						; comprobar si el desplazamiento es mayor o igual que 0
	bge		.dontResetScroll		; si es así, no hacemos nada
	moveq	#15,d0					; si es menor que 0 lo reiniciamos a 15
.dontResetScroll:
	move.b	d0,3(a0)				; seteamos el desplazamiento en la copperlist

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
	dc.w 	DIWSTRT,$2c81			; DIWSTRT
	dc.w 	DIWSTOP,$2cc1			; DIWSTOP
	dc.w 	DDFSTRT,$0030			; DDFSTRT
	dc.w 	DDFSTOP,$00d0			; DDFSTOP
	dc.w 	BPL1MOD,MODULO			; BPL1MOD		
	dc.w 	BPL2MOD,MODULO			; BPL2MOD
scrollValues:	
	dc.w	BPLCON1,$0000			; BPLCON1

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
	incbin 			"grid.336x256x1.raw"

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN