    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe sprites2.s -o sprites2

	incdir "..\include"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

SCREENWIDTH		equ		320
SCREENHEIGHT	equ		256
NUMPLANES		equ		1

	; ----------------
	; ----- CODE -----
	; ----------------

	section amigaWaveCodeP,CODE_P

init:
	SAVE_COPPER						; salvar puntero a copperlist

	lea		CUSTOM,a5

	move.w	DMACONR(a5),oldDMA		; salvar configuración de DMA
    move.w	#$7fff,DMACON(a5)		; desactivar todos los canales de DMA
	move.w	#$83a0,DMACON(a5)		; activar canales DMA para bitplanes, copper y sprites

	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	move.l	#sprite0,d0		        ; d0 = dirección del gráfico del sprite
	lea		CopSprP0,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	move.l	#sprite1,d0		   		; d0 = dirección del gráfico del sprite
	lea		CopSprP1,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

	;bsr 	calcCoords2
	
main:
	WAIT_VB	
	WAIT_VB2
	move.w	#100,d0
	move.w	#100,d1
	
	dc.w	$cf4f

	jsr 	calcCoords2

	move.w	#200,d0
	move.w	#200,d1
	
	dc.w	$cf4f

	jsr 	calcCoords


	CHECK_LMB						; comprobar botón izquierdo ratón
	;jsr 	calcCoords2
exit:
	or.w	#$8000,oldDMA			; setear bit SET/CLR
	move.w	oldDMA,DMACON(a5)		; restaurar DMA
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar copperlist
	moveq	#0,d0
	rts

	; ----------------
	; ----- DATA -----
	; ----------------

	section amigaWaveDataC,DATA_C

	;calculamos las coordenadas:
	

	
calcCoords:

	lea		sprite0,a0
	
	move.w	d0,d2
	add.w	#$81,d2
	sub.w	#1,d2


	lsr.w	#1,d2
	move.b	d2,1(a0)

	and.b	#%00000001,d0
	or.b	d0,3(a0)


	rts



copperlist:	
	dc.w 	FMODE,0					; slow fetch mode, AGA compatibility
	dc.w 	BPLCON0,$0200			; BPLCON0 / Disable every bitplane
	dc.w	BPLCON1,0
	dc.w	BPLCON2,0
	dc.w	BPLCON3,0
	dc.w 	DDFSTRT,$0038			; DDFSTRT
	dc.w 	DDFSTOP,$00d0			; DDFSTOP

	dc.w 	DIWSTRT,$2c81			; DIWSTRT
	dc.w 	DIWSTOP,$2cc1			; DIWSTOP

	; ----- PALETTE -----

	dc.w    COLOR00,$0000			 ; color 0
	
	dc.w    COLOR16,$0000			 ; colores 16 A 31 -> sprites
	dc.w    COLOR17,$0F44
	dc.w    COLOR18,$0C00
	dc.w    COLOR19,$0F99
	
	dc.w    COLOR20,$0600
	dc.w    COLOR21,$0FFF
	dc.w    COLOR22,$0CFF
	dc.w    COLOR23,$03BF
	
	dc.w    COLOR24,$008B
	dc.w    COLOR25,$0069
	dc.w    COLOR26,$0D62
	dc.w    COLOR27,$0910
	
	dc.w    COLOR28,$0046
	dc.w    COLOR29,$0273
	dc.w    COLOR30,$054B
	dc.w    COLOR31,$0800

	; ----- SPRITES -----

CopSprP0:
	dc.w 	SPR0PTH,$0000			; SPR0PTH / puntero al sprite 0 (16 bits altos)
	dc.w 	SPR0PTL,$0000			; SPR0PTL / puntero al sprite 0 (16 bits bajos)

CopSprP1:
	dc.w 	SPR1PTH,$0000			; SPR1PTH / puntero al sprite 1 (16 bits altos)
	dc.w 	SPR1PTL,$0000			; SPR1PTL / puntero al sprite 1 (16 bits bajos)

	; ----- BITPLANES -----

CopBplP0:
	dc.w 	BPL1PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL1PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos) 

CopBPLCON0:
	dc.w 	BPLCON0,$1200		    ; BPLCON0 / Habilitar NUMPLANES bitplanes

	dc.w 	$ffff,$fffe			    ; FIN copperlist

	; -----------------------------------------------------------------------------

sprite0:							   		
    dc.w $2c40,$3700				; SPR0POS SPR0CTL
	
	dc.w $0300,$0100				; planos 1 y 2 del sprite
	dc.w $0380,$0100
	dc.w $03c0,$0100				
	dc.w $03b6,$0150
	dc.w $01bf,$0000
	dc.w $2100,$3fbf				
	dc.w $6000,$7b07
	dc.w $22f8,$3800
	dc.w $0060,$03f0
	dc.w $00c0,$01c0
	dc.w $00f8,$0010
    
	dc.w $0000,$0000				; fin sprite 0

	; -----------------------------------------------------------------------------

sprite1:			
    dc.w $2c40,$3780				; SPR1POS SPR1CTL
	
	dc.w $0000,$0000				; planos 3 y 4 del sprite
	dc.w $0080,$0000
	dc.w $00c0,$0000
	dc.w $0082,$0004
	dc.w $0044,$0003
	dc.w $3840,$4000
	dc.w $78f8,$8000
	dc.w $3804,$4000
	dc.w $0000,$0000
	dc.w $0000,$0000 
	dc.w $0000,$0000 
    
	dc.w $0000,$0000				; fin sprite 1

	; -----------------------------------------------------------------------------


; SPRITE 0    PLANO 1     $03c0   0000 0011 1100 0000     bit 0 
;             PLANO 2     $0100   0000 0001 0000 0000     bit 1 
; SPRITE 1    PLANO 3     $00c0   0000 0000 1100 0000     bit 2 
;             PLANO 4     $0000	  0000 0000 0000 0000     bit 3 		
;                                 ===================
; COLOR                           0000 0013 5500 0000

screenBuffer:
	blk.b			SCREENHEIGHT*SCREENWIDTH/8,0

oldCopperPtr:		dc.l	1
oldDMA:				dc.w	1
graphicsName:		dc.b "graphics.library",0
	EVEN

calcCoords2:

	lea		sprite1,a0
	
	move.w	d0,d2
	add.w	#$81,d2
	sub.w	#1,d2

	lsr.w	#1,d2
	move.b	d2,1(a0)

	and.b	#%00000001,d0
	or.b	d0,3(a0)


	rts