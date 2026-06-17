    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe sprites3.s -o sprites3
	; java -jar d:\amigahd\sources\bin\IFFConverter.jar Lost_In_The_Cave.iff . 2

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

	dc.w 	$cf4f
	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	move.l	#sprite,d0		        ; d0 = dirección del gráfico del sprite
	lea		CopSprP0,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist


main:
    WAIT_VB

	; actualizar posición sprite
	bsr		updateSprite

	; dibujar sprite
	lea     sprite,a0				; puntero al sprite
	move.w	x,d0					; d0 = x (pixels)
	move.w	y,d1					; d1 = y (pixels)	
	move.w	#16,d4					; d4 = altura del sprite (en líneas)
	bsr	 	drawSprite          	; calcular coordenadas del sprite 0	

	CHECK_LMB						; comprobar botón izquierdo ratón

exit:
	or.w	#$8000,oldDMA			; setear bit SET/CLR
	move.w	oldDMA,DMACON(a5)		; restaurar DMA
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar copperlist

	moveq	#0,d0
	rts

updateSprite:
	; actualizar posición x
	move.w	x,d0
	add.w	vx,d0
	
	; comparar posición x con el borde derecho de la pantalla
	cmp.w	#319-16,d0
	blt		.checkLeftBorder
	neg.w	vx
	bra		.dontReverseVx

	; comparar posición x con el borde izquierdo de la pantalla
.checkLeftBorder:
	cmp.w	#0,d0
	bgt		.dontReverseVx
	neg.w	vx

.dontReverseVx:
	move.w	d0,x

	; =====================
	; actualizar posición y
	; =====================
	move.w	y,d0
	add.w	vy,d0	
	move.w	d0,y

	rts

; rutina para cálculo de coordenadas del sprite
; a0.l = puntero al sprite
; d0.w = x (pixels)
; d1.w = y (pixels)
; d4.w = altura del sprite (en líneas)
drawSprite:
    ;move.l  #sprite,a0
    ;lea     sprite,a0   ; a0 = puntero a los datos del sprite

    ; calcular HSTART = x + DWSTART.x - 1
	move.w  d0,d2           ; d2 = x
    add.w   #$81,d2         ; d2 = x + DWSTART.x
    sub.w   #1,d2           ; d2 = x + DWSTART.x  - 1

    ; mover 8 bits altos de HSTART al segundo byte de la cabecera del sprite
    
    lsr.w   #1,d2           ; Logic Shift Right: quedarnos con los 8 bits altos de HSTART en la parte baja de d2
    move.b  d2,1(a0)        ; movemos esos 8 bits altos de HSTART a la cabecera del sprite
                            ; d2 = HSTART (9 bits)
                            ; -> 000 0001 1010 01011 (1bit a la dcha) -> 0000 0000 1010 0101

    ; mover el LSB (bit menos sign) de HSTART, que aún está en d0, a el bit menos significativo de la cabecera
    
    and.b   #%00000001,d2   ; -> 0100 1011 and 0000 0001 -> 0000 0001
    or.b    d2,3(a0)        ; -> 0000 0001 or  0000 0000 -> 0000 0001 

    ; calcular VSTART

	move.w	d1,d3			; movemos y a d3
	add.w   #$2c,d3			; sumamos y inicial de los sprites, que es DIWSTRT
	move.b  d3,(a0)			; movemos los 8 bits menos significativos a la cabecera del sprite
	
	lsr.w   #6,d3			; desplazamos 6 bits a la derecha para colocar el bit 8 del start vertical en el bit 2
	and.b	#%00000100,d3	; máscara para quedarnos con el bit 2
	or.b   d3,3(a0)			; movemos el bit 2 a la cabecera del sprite

    ; calcular VEND

	move.w  d1,d3			; movemos y a d3
	add.w   #$2c,d3			; sumamos y inicial de los sprites, que es DIWSTRT
	add.w  	d4,d3			; sumamos la altura
	move.b	d3,2(a0)		; movemos los 8 bits menos significativos a la cabecera del sprite

	lsr.w   #7,d3			; desplazamos 7 bits a la derecha para colocar el bit 8 del start vertical en el bit 1
	and.b	#%00000010,d3	; máscara para quedarnos con el bit 1
	or.b   d3,3(a0)			; movemos el bit 1 a la cabecera del sprite

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
    dc.w	$2c40,$3c00			    ; SPR0POS SPR0CTL		
	
    dc.w	$07e0,$0000				; línea 0, "plano" 2
	dc.w	$1ff8,$0000				; línea 1, "plano" 2												
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

nullSprite:
	dc.w	$0000,$0000
	dc.w	$0000,$0000
	dc.w	$0000,$0000


;								 8 7 6 5 4 3 2 1 0
;							     -----------------
;  posición vertical inicial   = X 0 0 1 0 1 1 0 0
;  posición horizontal inicial = 0 0 1 0 1 1 0 0 Z
;  posición vertical final     = Y 0 0 1 0 1 1 0 0

; -----------------------------------------------------------------------------
;		       START V    			 START H			END V
; 	       ----------------   	----------------	----------------
; 		   0 0 1 0  1 1 0 0 	0 1 0 0  0 0 0 0, 	0 0 1 1  1 1 0 0 	0 0 0 0  0 X Y Z		X = bit 8 del start vertical
;							      										A		     			Y = bit 8 del end vertical
;			    	         			   										     			Z = bit 0 del start horizontal
;					       				   							   8 7 6 5 4 3 2 1 0			     
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

    section         seccion_fast,DATA_P

x:                  dc.w    0
y:                  dc.w    0
vx:                 dc.w    0
vy:                 dc.w    1