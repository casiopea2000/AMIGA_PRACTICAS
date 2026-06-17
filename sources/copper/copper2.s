    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe copper2.s -o copper2

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l	#copperlist,COP1LC(a5) 	; indicar dirección copperlist
	; move.l	#copperlist,$dff080

main:
	btst	#6,$bfe001				; botón izq del ratón
	bne		main

exit:
	moveq	#0,d0					; salir sin errores
	rts

	; ----------------
	; ----- DATA -----
	; ----------------

	section amigaWaveDataC,DATA_C

	; el copper tiene 3 instrucciones:
	;	WAIT: espera a que el haz de electrones esté en la posición (x,y) que digamos
	; 	MOVE: mueve un word (segunda word de la instrucción) a un registro de los custom chips (primer word de la instrucción)
	;	SKIP
copperlist:
	dc.w 	COLOR00,$0f00 		   ; color 0 = ROJO
	dc.w 	$ffff,$fffe				; FIN copperlist

; numLifes:
;	dc.b	3						; reservamos un byte con valor 3 en la dirección de memoria indicada por la etiqueta numLifes
