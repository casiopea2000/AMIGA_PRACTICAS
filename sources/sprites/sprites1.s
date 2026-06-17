    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe sprites1.s -o sprites1

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

	move.w	DMACONR(a5),oldDMA		; salvar configuración de DMA
    move.w	#$7fff,DMACON(a5)		; desactivar todos los canales de DMA
	move.w	#$83a0,DMACON(a5)		; activar canales DMA para bitplanes, copper y sprites

	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	move.l	#sprite,d0		        ; d0 = dirección del gráfico del sprite
	lea		CopSprP0,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

main:
	CHECK_LMB						; comprobar botón izquierdo ratón

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

    dc.w    COLOR00,$0000

	dc.w 	COLOR16,$0000           ; COLOR 16 (fondo -> transparente)
	dc.w 	COLOR17,$0d00           ; COLOR 17
	dc.w 	COLOR18,$0e60           ; COLOR 18
	dc.w 	COLOR19,$0fff           ; COLOR 19


	; ----- SPRITES -----

CopSprP0:
	dc.w 	SPR0PTH,$0000			; SPR0PTH / puntero al sprite 0 (16 bits altos)
	dc.w 	SPR0PTL,$0000			; SPR0PTL / puntero al sprite 0 (16 bits bajos)

	; ----- BITPLANES -----

CopBplP0:
	dc.w 	BPL1PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL1PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos) 

CopBPLCON0:
	dc.w 	BPLCON0,$1200		    ; BPLCON0 / Habilitar NUMPLANES bitplanes

	dc.w 	$ffff,$fffe			    ; FIN copperlist

	; -----------------------------------------------------------------------------

sprite:							    						
	; PRIMER USO DEL SPRITE 0
    dc.w	$2c40,$3c00			; SPR0POS SPR0CTL		
									
	dc.w	$07e0				; línea 0, "plano" 1
	dc.w	$0000				; línea 0, "plano" 2
	
	dc.w	$1ff8				; línea 1, "plano" 1
	dc.w    $0000				; línea 1, "plano" 2	
																									
	dc.w	$381c,$07e0 																			
	dc.w	$718e,$0ff0																		   	
	dc.w	$67e6,$1ff8							
	dc.w	$cff3,$3ffc							
	dc.w	$cff3,$3ffc
	dc.w	$dffb,$3ffc
	dc.w	$dffb,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$67e6,$1ff8
	dc.w	$718e,$0ff0 
	dc.w	$381c,$07e0 
	dc.w	$1ff8,$0000 
	dc.w	$07e0,$0000

	; SEGUNDO USO DEL SPRITE 0
    dc.w	$4c40,$5c00				; SPR0POS SPR0CTL		
									
	dc.w	$07e0,$0000				; planos 1 y 2 del sprite
	dc.w	$1ff8,$0000					
	dc.w	$381c,$07e0 			
	dc.w	$718e,$0ff0
	dc.w	$67e6,$1ff8
	dc.w	$cff3,$3ffc
	dc.w	$cff3,$3ffc
	dc.w	$dffb,$3ffc
	dc.w	$dffb,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$67e6,$1ff8
	dc.w	$718e,$0ff0 
	dc.w	$381c,$07e0 
	dc.w	$1ff8,$0000 
	dc.w	$07e0,$0000

		; TERCER USO DEL SPRITE 0
    dc.w	$6c40,$7c00				; SPR0POS SPR0CTL		
									
	dc.w	$07e0,$0000				; planos 1 y 2 del sprite
	dc.w	$1ff8,$0000					
	dc.w	$381c,$07e0 			
	dc.w	$718e,$0ff0
	dc.w	$67e6,$1ff8
	dc.w	$cff3,$3ffc
	dc.w	$cff3,$3ffc
	dc.w	$dffb,$3ffc
	dc.w	$dffb,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$cff3,$3ffc 
	dc.w	$67e6,$1ff8
	dc.w	$718e,$0ff0 
	dc.w	$381c,$07e0 
	dc.w	$1ff8,$0000 
	dc.w	$07e0,$0000





	dc.w	$0000,$0000

;								 8 7 6 5 4 3 2 1 0
;							     -----------------
;  posición vertical inicial   = X 0 0 1 0 1 1 0 0
;  posición horizontal inicial = 0 0 1 0 1 1 0 0 Z
;  posición vertical final     = Y 0 0 1 0 1 1 0 0

; -----------------------------------------------------------------------------
;		       START V    			 START H			END V
; 	       ----------------   	----------------	----------------
; SPR0POS: 0 0 1 0  1 1 0 0 	0 1 0 0  0 0 0 0, 	0 0 1 1  1 1 0 0 	0 0 0 0  0 X Y Z
;							      										A		   S E S
;			    	         			   										   V V H	
;					       				   										   8 8 0
;					       
; START V = 000101100 = $2c		END V = 000111100 = $3c
; START H = 010000000 = $80

	; -----------------------------------------------------------------------------

; PLANO 1	$381c	0 0 1 1  1 0 0 0  0 0 0 1  1 1 0 0		bit 0
; PLANO 2	$07e0	0 0 0 0  0 1 1 1  1 1 1 0  0 0 0 0		bit 1
; 					==================================
; COLOR  			0 0 1 1  1 2 2 2  2 2 2 1  1 1 0 0

screenBuffer:
	blk.b			SCREENHEIGHT*SCREENWIDTH/8,0

oldCopperPtr:		dc.l	1
oldDMA:				dc.w	1
graphicsName:		dc.b "graphics.library",0
	EVEN