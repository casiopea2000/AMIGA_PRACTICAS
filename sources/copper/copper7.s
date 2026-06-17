    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper7.s -o copper7

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
    SAVE_COPPER

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

	; -----------------------------------------------------------

main:
	; doble espera al vertical blank, ya que nuestro código para actualizar la barra se ejecuta en menos tiempo que una raster line


.waitVB:
	move.l	$dff004,d3				; primero nos quedamos esperando en este bucle mientras no estemos en la línea 303 del barrido
	and.l	#$1ff00,d3
	cmp.l	#303<<8,d3
	bne.b	.waitVB

.waitVB2:
	move.l	$dff004,d3				; una vez que ya estamos en la línea 303 nos quedamos en este bucle hasta que el barrido pase a la siguiente
	and.l	#$1ff00,d3
	cmp.l	#303<<8,d3
	beq.b	.waitVB2

    ; "rotamos" las copperbars
    lea     copperbar1,a0			; a0 = dirección de inicio de la copper bar en la copperlist
    moveq   #4-1,d0  				; d0 = número de desplazamientos de colores que habrá que hacer
    bsr     rotateBar				; bsr = branch to subroutine

    lea     copperbar2,a0
    moveq   #9-1,d0  
    bsr     rotateBar

.waitLMB:
	CHECK_LMB

	; -----------------------------------------------------------

exit:
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar la anterior copperlist
	moveq	#0,d0
	rts


; =================================
; SUBRUTINA PARA ROTAR LA COPPERBAR
; =================================

rotateBar:							; es una etiqueta "global", se puede saltar aquí desde cualquier punto del programa
    move.w  6(a0),d1                ; dir indicada por a0 + 6: nos guardamos el color de la primera línea para al final ponérselo a la última
    add.l   #14,a0                  ; nos situamos en el color de la segunda línea y los iremos desplazando una línea hacia arriba

.rotate:							; es una etiqueta "local", sólo se puede invocar en esta subrutina
    move.w  (a0),-8(a0)             ; mover el color actual a la línea inmediatamente superior
    add.l   #8,a0                   ; avanzar al color de la siguiente línea
    dbf     d0,.rotate              ; resta 1 a d0 y si d0 >= 0 salta a la etiqueta .rotate

    move.w  d1,-8(a0)               ; mover el color de la primera línea (que guardamos antes) a la última

    rts								; return from subroutine

	; ----------------
	; ----- DATA -----
	; ----------------o

	section amigaWaveDataC,DATA_C

copperlist:	
	dc.w 	COLOR00,$0000

copperbar1:
	dc.w 	$a001,$ff00
	dc.w 	COLOR00,$0f26			
	dc.w 	$a101,$ff00
	dc.w 	COLOR00,$0f58	
	dc.w 	$a201,$ff00
	dc.w 	COLOR00,$0f7a	
    dc.w 	$a301,$ff00
    dc.w 	COLOR00,$0f58	
	dc.w 	$a401,$ff00
	dc.w 	COLOR00,$0f26	

    dc.w    $a501,$ff00
    dc.w 	COLOR00,$0000

copperbar2:
	dc.w 	$c001,$ff00
	dc.w 	COLOR00,$0f26	
	dc.w 	$c101,$ff00
	dc.w 	COLOR00,$0f26	
	dc.w 	$c201,$ff00
	dc.w 	COLOR00,$0f58	
	dc.w 	$c301,$ff00
	dc.w 	COLOR00,$0f58	
	dc.w 	$c401,$ff00
	dc.w 	COLOR00,$0f7a	
	dc.w 	$c501,$ff00
	dc.w 	COLOR00,$0f7a	
    dc.w 	$c601,$ff00
    dc.w 	COLOR00,$0f58	
    dc.w 	$c701,$ff00
    dc.w 	COLOR00,$0f58	
	dc.w 	$c801,$ff00
	dc.w 	COLOR00,$0f26	
	dc.w 	$c901,$ff00
	dc.w 	COLOR00,$0f26	

	dc.w 	$ca01,$ff00
	dc.w 	COLOR00,$0000	

	dc.w 	$ffff,$fffe				; FIN copperlist

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN