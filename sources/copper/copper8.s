    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper8.s -o copper8

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

	; esperar botón izquierdo ratón

main::
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

	dc.w 	$ac31,$fffe			    ; WAIT Y = $ac (se actualiza desde main)
    REPT    23
	dc.w 	COLOR00,$0f00		   ; color 0 = ROJO
	dc.w 	COLOR00,$0fff		   ; color 0 = ROJO
    ENDR

	dc.w 	$ad01,$fffe			    ; WAIT Y = $ac (se actualiza desde main)
	dc.w 	COLOR00,$0000		   ; color 0 = ROJO

	dc.w 	$ffff,$fffe				; FIN copperlist

oldCopperPtr:		dc.l	1
graphicsName:		dc.b "graphics.library",0
	EVEN