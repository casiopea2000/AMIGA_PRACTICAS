    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper1.s -o copper1

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:		   	
	lea		CUSTOM,a5			; a5 = puntero a dirección base custom chips
	move.w	#$0f00,COLOR00(a5) 	; color 0 = ROJO
	;move.w	#$0f00,$dff180

main:
	btst	#6,$bfe001			; botón izq del ratón
	bne		main

exit:
    moveq	#0,d0               ; salir sin errores
	rts

	; ----------------
	; ----- DATA -----
	; ----------------
