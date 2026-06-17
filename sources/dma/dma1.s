    ; vasmm68k_mot.exe -kick1hunks -Fhunkexe dma1.s -o dma1

	incdir "..\include"
	
	include "custom.i"

    section dma1Code,CODE_P

    lea     CUSTOM,a5
	move.w	DMACONR(a5),oldDMACON

	move.w	#$7fff,DMACON(a5)	
	move.w	#$83a0,DMACON(a5)	; $8380 sin sprites		

main:
    btst	#6,$bfe001
	bne		main

    move.w	#$7fff,DMACON(a5)
	move.w	oldDMACON,d0		
	or.w	#$8000,d0
	move.w	d0,DMACON(a5)

    ; DMACONR = oldDMACON
    ; 0000 0001 1010 1111
    ; 1000 0000 0000 0000 OR
    ; ===================
    ; 1000 0001 1010 1111

    rts

    section dma1Data,DATA_P
oldDMACON:
    dc.l    -1