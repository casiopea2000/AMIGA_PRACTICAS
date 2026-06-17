; ============================================================
; Comprueba si se ha pulsado el botón izquierdo del ratón
; ============================================================
CHECK_LMB macro
    btst	#6,$bfe001
	bne		main
endm

; ============================================================
; Espera al vertical blank
; ============================================================
WAIT_VB macro
.waitVB:
	move.l	$dff004,d3
	and.l	#$1ff00,d3
	cmp.l	#303<<8,d3
	bne.b	.waitVB
endm

; ============================================================
; Segunda espera al vertical blank para rutinas que tardan 
; menos que una línea del barrido
; ============================================================
WAIT_VB2 macro
.waitVB2:
	move.l	$dff004,d3
	and.l	#$1ff00,d3
	cmp.l	#303<<8,d3
	beq.b	.waitVB2
endm

; ============================================================
; Guarda el puntero a la copperlist actual
; ============================================================
SAVE_COPPER macro
    move.l	4.w,a6
	moveq	#0,d0			
	move.l 	#graphicsName,a1		
	jsr 	OPENLIBRARY(a6)		
	move.l 	d0,a1			
	move.l 	38(a1),oldCopperPtr	
	jsr 	CLOSELIBRARY(a6)
endm

; ============================================================
; Informa los punteros a los planos en la copperlist
; IN:
;	d0 = dirección del buffer
; 	a0 = dirección en copperlist
; ============================================================
POKE_BITPLANES macro
	moveq	#NUMPLANES-1,d6
.\@:  
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	#SCREENWIDTH/8,d0
	add.l	#8,a0
	dbf		d6,.\@
endm

; ============================================================
; Informa los punteros a los sprites en la copperlist
; IN:
;	d0 = dirección del buffer
; 	a0 = dirección en copperlist
; ============================================================
POKE_SPRITE macro
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
endm

; ============================================================
; Espera a que acabe el blit en ejecución
; IN:
;	a5 = dirección base de los custom chips
; ============================================================
WAITBLT macro
	move.w	#$8400,DMACON(a5)
.\@:
	btst	#6,DMACONR(a5)
	bne.b	.\@
	move.w	#$0400,DMACON(a5)
endm