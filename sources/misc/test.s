    section test,CODE_P

main:
    btst	#6,$bfe001
	bne		main
    rts

    section testD,DATA_P
variable:
     dc.l $cccccccc