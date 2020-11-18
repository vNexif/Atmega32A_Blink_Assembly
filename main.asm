;
; LearnAssembler.asm
;
; Created: 17/11/2020 13:43:40
; Author : Nexif
;
/*
.include"m32adef.inc" ;;Inlucde Atmega32A defines
.cseg ;; Prog mem
	.org 0x40
	rjmp Init
	rjmp MainLoop
*/

.include "m32adef.inc"
.def temp = r16


;; interrupt vector
jmp reset
.org INT0addr
jmp handle_pb0

reset:
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;ser temp
	;out DDRC, temp

	

	ldi temp, (1 << ISC01) | (1 << ISC00)
	sts MCUCR, temp

	in temp, GICR
	ori temp, (1<<INT0)
	out GIMSK, temp
	ldi r17, 0x40
	out ddra, r17
	ldi r17, 0xbf
	out porta, r17

	sei

main: 
	sbis pina,1
	rjmp delay
	nop
	rjmp main

Press:
	sbis pina,6
	rjmp LedOn
	rjmp LedOff

LedOn:
	sbi porta,6
	rjmp ButtonOff

LedOff:
	cbi porta,6
	rjmp ButtonOff

ButtonOff:
	sbis pina,1
	rjmp ButtonOff
	rjmp main

delay:
	sbic pina,1
	ldi r17, 0b11111111
	dec r17
	cpi r17, 0b00000000
	breq Press
	rjmp delay

handle_pb0:
/*
	push temp
	in temp, sreg
	push temp

	in temp, portc
	com temp
	out portc,temp

	pop temp
	out sreg,temp
	pop temp
*/
	
	in r21, ddrc
	cpi r21, 0b00000100
	breq skip_call

	rcall blink

	pop r21

	reti

blink:
	sbi portc,3
	ret

skip_call:
	reti
