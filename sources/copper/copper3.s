    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper3.s -o copper3

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

; POSICIONES RELATIVAS DE CADA FUNCIÓN RESPECTO AL COMIENZO DE LA LIBRERÍA EXEC
OPENLIBRARY		equ		-408		; http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_3._guide/node0222.html
CLOSELIBRARY	equ		-414		; http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0340.html

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
    move.l	4.w,a6					; poner en A6 la dirección de la librería EXEC (dirección 4 de memoria)			
	
	; **************************
	; ABRIR LA LIBRERÍA GRAPHICS
	; **************************
	moveq	#0,d0					; en D0 pasamos el número de versión de la librería que queremos abrir
									; 0 => abrir la versión más reciente
	move.l 	#graphicsName,a1		; a1 contiene un puntero a la cadena "graphics.library", que es el nombre de la librería
	jsr 	OPENLIBRARY(a6)			; jump to subroutine OPENLIBRARY de la librería EXEC (saltar a dirección inicio de EXEC + (-408))
	move.l 	d0,a1					; en d0 tenemos el puntero al comienzo de la graphics.library
	
	; *************************************
	; GUARDAR LA DIRECCIÓN DE LA COPPERLIST
	; *************************************
	move.l 	38(a1),oldCopperPtr		; copiamos el contenido de la dirección A1 + 38 (inicio de la graphics library)
									; que contiene el puntero a la copperlist actual a oldCopperPtr
	
	; ***************************
	; CERRAR LA LIBRERÍA GRAPHICS
	; ***************************
	jsr 	CLOSELIBRARY(a6)		; cerrar la graphics.library (en a1 tiene que estar el puntero a la librería)

	; --------------------------------------------------------------------------------------------------------------
	
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
	dc.w 	COLOR00,$0f00		   ; color 0 = ROJO (MOVE)
	dc.w 	$ffff,$fffe				; FIN copperlist		

oldCopperPtr:		dc.l	1						; guarda la dirección de la copperlist antigua (4 bytes)
graphicsName:		dc.b 	"graphics.library",0	; guarda 1 byte por cada caracter y se le indica el fin de cadena con un 0
