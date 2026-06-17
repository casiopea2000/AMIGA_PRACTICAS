    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper4.s -o copper4

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
    move.l	4.w,a6
	moveq	#0,d0			
	move.l 	#graphicsName,a1		
	jsr 	OPENLIBRARY(a6)		
	move.l 	d0,a1			
	move.l 	38(a1),oldCopperPtr	
	jsr 	CLOSELIBRARY(a6)

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

main:
	btst	#6,$bfe001				; botón izq del ratón
	bne		main

exit:
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar la anterior copperlist
	moveq	#0,d0
	rts

	; ----------------
	; ----- DATA -----
	; ----------------

	section amigaWaveDataC,DATA_C

copperlist:	
	dc.w 	COLOR00,$0000

	;dc.w	$ffdf,$fffe 			; espera previa para coordenada Y > 255
                                    ; cualquier WAIT que venga a partir de aquí
                                    ; sumará 255 a la coordenada Y

	; comienzo de la barra

	dc.w 	$ac47,$fffe				; WAIT a la coordenada Y = 255 + 8 = 263
	dc.w 	COLOR00,$0f00		   ; color 0 = ROJO

	; fin de la barra

    ;dc.w	$ffdf,$fffe

	dc.w 	$bc01,$ff00				; WAIT a la coordenada Y = 255 + 24 = 279
	dc.w 	COLOR00,$0000		   ; color 0 = NEGRO

	dc.w 	$ffff,$fffe				; FIN copperlist

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN