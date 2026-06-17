    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe playfield2.s -o playfield2

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
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

    move.l   #0,d0					; d0 = x
    move.l   #0,d1					; d1 = y

main:
	WAIT_VB							; esperar al vertical blank
	WAIT_VB2						; segunda espera porque el bucle dura menos que una línea del barrido

	bsr		erase					; borrar punto
	bsr		update					; actualizar posición punto
	bsr     draw					; dibujar punto

    btst	#6,$bfe001
	bne		main

exit:
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar copperlist
	moveq	#0,d0
	rts

; ==============================
; IN:
; 	d0 = x
; 	d1 = y
; ==============================
erase:
	movem.l d0/d1,-(a7)				; salvar registros en la pila = PUSH

	bsr		coords2Address			; transformar coordenadas en dirección
    swap    d0 						; poner en la parte baja el resto = pixel dentro del byte
    move.b  #7,d1					; determinar el bit a borrar
    sub.b   d0,d1				
    bclr    d1,(a0)					; borrar bit

    movem.l (a7)+,d0/d1				; restaurar registros desde la pila = POP
    rts

; ==============================
; IN:
; 	d0 = x
; 	d1 = y
; ==============================
update:
    cmp.w   #SCREENWIDTH,d0				
    blt     .dontResetX				; si x >= 320 -> saltar a nueva línea
    add.w   #1,d1					; incrementar y
    move.w  #0,d0					; resetear x
    rts								; volvemos a la instrucción siguiente desde la que se llamó
.dontResetX:
    add.w   #5,d0					; x < 320 -> incrementar x --> x = x + vx
	rts								; volvemos a la instrucción siguiente desde la que se llamó

; ==============================
; IN:
; 	d0 = x
; 	d1 = y
; ==============================
draw:
    movem.l d0/d1,-(a7)				; salvar registros en la pila

	bsr		coords2Address			; transformar coordenadas en dirección
    swap    d0 						; poner en la parte baja el resto = pixel dentro del byte
    move.b  #7,d1					; determinar el bit a activar
    sub.b   d0,d1
    bset    d1,(a0)					; activar bit

    movem.l (a7)+,d0/d1				; restaurar registros desde la pila
    rts

; ==============================
; IN:
;	d0 = x
; 	d1 = y
; OUT:
;	a0 = address
; ==============================
coords2Address:
    lea     screenBuffer,a0			; a0 = dirección buffer de pantalla
    divu.w  #8,d0					; x / 8 = columna
    mulu.w  #SCREENWIDTH/8,d1		; y * SCREENWIDTH = fila
    add.w   d0,d1					; sumar columna + fila
    add.l   d1,a0					; a0 apunta al byte a modificar

	rts

	; ----------------
	; ----- DATA -----
	; ----------------

	section amigaWaveDataC,DATA_C

copperlist:	
	dc.w 	DIWSTRT,$2c81			; DIWSTRT
	dc.w 	DIWSTOP,$2cc1			; DIWSTOP
	dc.w 	DDFSTRT,$0038			; DDFSTRT
	dc.w 	DDFSTOP,$00d0			; DDFSTOP
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
	blk.b			SCREENHEIGHT*SCREENWIDTH/8,0	; inicializa todos los bytes del buffer a 0 (0x00 = 0b00000000)

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN