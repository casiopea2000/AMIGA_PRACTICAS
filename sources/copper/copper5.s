    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper5.s -o copper5

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

	move.w	#$ac,d0					; d0 = Y superior de la barra
	move.w	#1,d1					; d1 = velocidad Y

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

	; actualizar la barra

	add.w	d1,d0					; Y += velocidad

.checkBarAtBottom:
	cmp.w	#$e0,d0					; comprobamos si la franja ha llegado al límite inferior de su movimiento (Y = $e0)
	blt		.checkBarAtTop
	neg.w	d1						; de ser así, rebotar cambiando a velocidad negativa
	bra		.checkBarEnd

.checkBarAtTop:
	cmp.w	#$40,d0					; comprobar si la franja ha llegado al límite superior de su movimiento (Y = $40)
	bgt		.checkBarEnd
	neg.w	d1						; de ser así, rebotar cambiando a velocidad positiva

.checkBarEnd:
	move.w	d0,d3					; d3 = Y superior de la barra
	move.b	d3,(wait1)				; seteamos Y superior de la barra en la copperlist
	add.b	#16,d3					; sumamos 16 para obtener la Y inferior de la barra
	move.b	d3,(wait2)				; seteamos Y inferior de la barra en la copperlist

	; -----------------------------------------------------------

	; esperar botón izquierdo ratón

.waitLMB:
	CHECK_LMB

exit:
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar la anterior copperlist
	moveq	#0,d0
	rts

	; ----------------
	; ----- DATA -----
	; ----------------o

	section amigaWaveDataC,DATA_C

copperlist:	
	dc.w 	COLOR00,$0000

	; comienzo de la barra

wait1:
	dc.w 	$ac01,$ff00				; WAIT Y = $ac (se actualiza desde main)
	dc.w 	COLOR00,$0f00		   ; color 0 = ROJO

wait2:
	dc.w 	$bc01,$ff00				; WAIT Y = $bc (se actualiza desde main)
	dc.w 	COLOR00,$0000		   ; color 0 = NEGRO

	dc.w 	$ffff,$fffe				; FIN copperlist

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN