    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe sprites3.s -o sprites3
	; java -jar d:\amigahd\sources\bin\IFFConverter.jar Lost_In_The_Cave.iff . 2

	incdir "..\include"
	;incdir ".\imagenes"
	
	include "custom.i"
	include "macros.i"

OPENLIBRARY		equ		-408
CLOSELIBRARY	equ		-414

SCREENWIDTH		equ		320
SCREENHEIGHT	equ		256
NUMPLANES		equ		4

	; ----------------
	; ----- CODE -----
	; ----------------

	section arkanoidCodeP,CODE_P

init:
	SAVE_COPPER						; salvar puntero a copperlist

	move.w	DMACONR(a5),oldDMA		; salvar configuración de DMA
    move.w	#$7fff,DMACON(a5)		; desactivar todos los canales de DMA
	move.w	#$83a0,DMACON(a5)		; activar canales DMA para bitplanes, copper y sprites

	move.l	#screenBuffer,d0		; d0 = dirección del buffer de pantalla
	lea		CopBplP0,a0				; a0 = dirección de punteros a los planos en la copperlist
	POKE_BITPLANES					; informar punteros a los planos en la copperlist

	move.l	#ball_sprite,d0		     ; d0 = dirección del gráfico de la bola
	lea		CopSprP0,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	move.l	#pad_sprite,d0		    ; d0 = dirección del gráfico del pad
	lea		CopSprP1,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

	lea		CUSTOM,a5				; a5 = puntero a dirección base custom chips
	move.l 	#copperlist,COP1LC(a5)  ; indicar dirección copperlist

main:
    WAIT_VB

	; actualizar posición sprite
	lea		ball_entity,a0
	move.w	#16,d4
	bsr		updateEntity

	; dibujar bola
	lea     ball_sprite,a0			; puntero al sprite
	move.w	ball_x,d0				; d0 = x (pixels)
	move.w	ball_y,d1				; d1 = y (pixels)	
	move.w	#16,d4					; d4 = altura del sprite (en líneas)
	bsr	 	drawSprite          	; calcular coordenadas del sprite 0	

	bsr		checkJoystick

	; actualizar posición sprite
	lea		pad_entity,a0
	move.w	#32,d4
	bsr		updateEntity

	; dibujar pad
	lea     pad_sprite,a0			; puntero al sprite
	move.w	pad_x,d0				; d0 = x (pixels)
	move.w	pad_y,d1				; d1 = y (pixels)	
	move.w	#32,d4					; d4 = altura del sprite (en líneas)
	bsr	 	drawSprite          	; calcular coordenadas del sprite 0	

	bsr		checkCollision

	CHECK_LMB						; comprobar botón izquierdo ratón

exit:
	or.w	#$8000,oldDMA			; setear bit SET/CLR
	move.w	oldDMA,DMACON(a5)		; restaurar DMA
	move.l	oldCopperPtr,COP1LC(a5)	; restaurar copperlist

	moveq	#0,d0
	rts

; ==================================
; rutina para comprobar colisión
; ==================================
checkCollision:
	; 1) ball_x + ball_w < pad.x
	move.w	ball_x,d0				; d0 = x de la bola
	add.w	#16,d0					; d0 = x de la bola + su ancho
	cmp.w	pad_x,d0				; comparamos con la x del pad
	blt		.checkCollisionEnd		; no hay colisión

	; 2) ball_x > pad.x + pad_w
	move.w	pad_x,d0
	add.w	#16,d0
	cmp.w	ball_x,d0
	blt		.checkCollisionEnd

	; 3) ball_y + ball_h < pad.y
	move.w	ball_y,d0				; d0 = y de la bola
	add.w	#16,d0					; d0 = y de la bola + su alto
	cmp.w	pad_y,d0				; comparamos con la y del pad
	blt		.checkCollisionEnd		; no hay colisión

	; 4) ball_y > pad.y + pad_h
	move.w	pad_y,d0
	add.w	#32,d0
	cmp.w	ball_y,d0
	blt		.checkCollisionEnd

	; SI LLEGAMOS A ESTE PUNTO ES PORQUE HAY COLISIÓN
.CollisionTrue:
	;lea		CUSTOM,a5
	;move.w	#$0f00,COLOR00(a5)		; borde rojo si hay colisión
	
	move.l	#nullSprite,d0		    ; d0 = dirección del gráfico de la bola
	lea		CopSprP0,a0				; a0 = dirección de punteros a los sprites en la copperlist
	POKE_SPRITE					    ; informar punteros a los sprites en la copperlist

.checkCollisionEnd:
	rts

; ==================================
; rutina para leer el joystick
; ==================================
checkJoystick:
	move.w	#0,pad_vx
	move.w	#0,pad_vy

	; DIRECCIONES: tenemos que leer bits del registro JOY1DAT
	; bit 1-> derecha, bit 9 -> izquierda, 1 xor 0 -> abajo, 9 xor 8 -> arriba
	; DISPARO: tenemos que comprobar si CIAAPRA <> 0
	lea		CUSTOM,a5
	move.w	JOY1DAT(a5),d0

	btst	#1,d0
	bne		.right

	btst	#9,d0
	bne		.left

	bra		.checkVertical

.right:
	move.w	#2,pad_vx
	bra		.checkVertical

.left:
	move.w	#-2,pad_vx

.checkVertical:
	move.w	JOY1DAT(a5),d1
	lsr.w	#1,d1				; desplazamos para alinear los bits 0, 1 y 8, 9 de d0 y d1, respectivamente
	eor.w	d0,d1

	btst	#0,d1
	bne		.down

	btst	#8,d1
	bne		.up

	bra		.checkJoystickEnd
.down:
	move.w	#2,pad_vy
	bra		.checkJoystickEnd

.up:
	move.w	#-2,pad_vy

.checkJoystickEnd:
	rts

; ==================================
; rutina para actualizar la posición
; a0.l = puntero a la entidad
; d4.w = altura de al entidad
; ==================================
updateEntity:
	; =====================
	; actualizar posición x
	; =====================
	move.w	(a0),d0
	add.w	4(a0),d0
	
	; comparar posición x con el borde derecho de la pantalla
checkRightBorder:
	cmp.w	#319-16,d0
	blt		.checkLeftBorder
	neg.w	4(a0)
	move.w	#319-16,d0
	bra		.dontReverseVx

	; comparar posición x con el borde izquierdo de la pantalla
.checkLeftBorder:
	cmp.w	#0,d0
	bgt		.dontReverseVx
	neg.w	4(a0)
	move.w	#0,d0

.dontReverseVx:
	move.w	d0,(a0)

	; =====================
	; actualizar posición y
	; =====================
	move.w	2(a0),d0
	add.w	6(a0),d0	
	
	; comparar posición y con el borde inferior de la pantalla
.checkBottomBorder:
	move.w	#255,d1
	sub.w	d4,d1
	cmp.w	d1,d0
	blt		.checkTopBorder
	neg.w	6(a0)
	move.w	d1,d0
	bra		.dontReverseVy

	; comparar posición y con el borde superior de la pantalla
.checkTopBorder:
	cmp.w	#0,d0
	bgt		.dontReverseVy
	neg.w	6(a0)
	move.w	#0,d0

.dontReverseVy	
	move.w	d0,2(a0)

	rts

; ==================================
; rutina para cálculo de coordenadas del sprite
; a0.l = puntero al sprite
; d0.w = x (pixels)
; d1.w = y (pixels)
; d4.w = altura del sprite (en líneas)
; ==================================
drawSprite:
	and.b	#%11111000,3(a0)

    ; calcular HSTART = x + DWSTART.x - 1
	move.w  d0,d2           ; d2 = x
    add.w   #$81,d2         ; d2 = x + DWSTART.x
    sub.w   #1,d2           ; d2 = x + DWSTART.x  - 1

    ; mover 8 bits altos de HSTART al segundo byte de la cabecera del sprite
    
	move.w	d2,d3
    lsr.w   #1,d2           ; Logic Shift Right: quedarnos con los 8 bits altos de HSTART en la parte baja de d2
    move.b  d2,1(a0)        ; movemos esos 8 bits altos de HSTART a la cabecera del sprite
                            ; d2 = HSTART (9 bits)
                            ; -> 000 0001 1010 01011 (1bit a la dcha) -> 0000 0000 1010 0101

    ; mover el LSB (bit menos sign) de HSTART, que aún está en d0, a el bit menos significativo de la cabecera
    
    and.b   #%00000001,d3   ; -> 0100 1011 and 0000 0001 -> 0000 0001
    or.b    d3,3(a0)        ; -> 0000 0001 or  0000 0000 -> 0000 0001 

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

	section arkanoidDataC,DATA_C

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

	;--PALETA FONDO (BORAR)
	dc.w    $0180,$0000
	dc.w    $0182,$0888
	dc.w    $0184,$0CCB
	dc.w    $0186,$0444
	dc.w    $0188,$0AA9
	dc.w    $018A,$0666
	dc.w    $018C,$0AAA
	dc.w    $018E,$0EEE
	dc.w    $0190,$0222
	dc.w    $0192,$0776
	dc.w    $0194,$0988
	dc.w    $0196,$0BBB
	dc.w    $0198,$0555
	dc.w    $019A,$0DCC
	dc.w    $019C,$0332
	dc.w    $019E,$0777
	;dc.w    $01A2,$0111
	;dc.w    $01A0,$0CBB
	;dc.w    $01A4,$0555
	;dc.w    $01A6,$0FFE
	;dc.w    $01A8,$0DDD
	;dc.w    $01AA,$0777
	;dc.w    $01AC,$0999
	;dc.w    $01AE,$089A
	;dc.w    $01B0,$0AAA
	;dc.w    $01B2,$0333
	;dc.w    $01B4,$0CCD
	;dc.w    $01B6,$0556
	;dc.w    $01B8,$0433
	;dc.w    $01BA,$0666
	;dc.w    $01BC,$0998
	;dc.w    $01BE,$0AAB


	; ----- SPRITES -----

CopSprP0:
	dc.w 	SPR0PTH,$0000			; SPR0PTH / puntero al sprite 0 (16 bits altos)
	dc.w 	SPR0PTL,$0000			; SPR0PTL / puntero al sprite 0 (16 bits bajos)

CopSprP1:
	dc.w 	SPR1PTH,$0000			; SPR0PTH / puntero al sprite 0 (16 bits altos)
	dc.w 	SPR1PTL,$0000			; SPR0PTL / puntero al sprite 0 (16 bits bajos)

	; ----- BITPLANES -----

CopBplP0:
	dc.w 	BPL1PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL1PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos) 

	dc.w 	BPL2PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL2PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos)

	dc.w 	BPL3PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL3PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos)

	dc.w 	BPL4PTH,$0000			; BPL1PTH / puntero al plano 1 (16 bits altos)
	dc.w 	BPL4PTL,$0000			; BPL1PTL / puntero al plano 1 (16 bits bajos)

CopBPLCON0:
	dc.w 	BPLCON0,$1200		    ; BPLCON0 / Habilitar NUMPLANES bitplanes

	dc.w 	$ffff,$fffe			    ; FIN copperlist

	; -----------------------------------------------------------------------------

ball_sprite:							    						
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

pad_sprite:
	incbin "pad.16x32x2.raw"


;0 1 2 3 4 5 6 7 8 9 A B C D E F		PIXELS
;============================================
;1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0		PLANO 2
;0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1		PLANO 1

; plano 2	plano 1
;	1			0
;	0			1
;	0			1
;	0			1
;...

;ÍNDICE COLOR = 01

;00 0 BLANCO
;01 1 ROJO
;10 2 NEGRO
;11 3 NEGRO

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
	incbin          "alienigena2.raw"
	;blk.b			SCREENHEIGHT*SCREENWIDTH/8,0

	section arkanoidDataF,DATA_P

oldCopperPtr:		dc.l	1
oldDMA:				dc.w	1
graphicsName:		dc.b "graphics.library",0
	EVEN

; entidad de la bola
ball_entity:
ball_x:                  dc.w    $011e
ball_y:                  dc.w    $00c0
ball_vx:                 dc.w    1
ball_vy:                 dc.w    1

; entidad del pad
pad_entity:
pad_x:                  dc.w    0
pad_y:                  dc.w    112
pad_vx:                 dc.w    0
pad_vy:                 dc.w    0

; array de 8 entidades
;entidades: = 1000
;	blk.b	64,0

;a0 = 1000 (entidades)

;ent 0 -> dir 1000	
;ent 1 -> dir 1008	a0
;ent 2 -> dir 1016
;...