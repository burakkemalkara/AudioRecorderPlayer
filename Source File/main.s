ADC0_RIS     EQU 0x40038004 ; Interrupt status
ADC0_PSSI    EQU 0x40038028 ; Initiate sample
ADC0_SSFIFO3 EQU 0x400380A8 ; Channel 3 results
ADC0_ISC     EQU 0X4003800C	; ADC Interrupt Clear
GPIO_PORTF_DATA    EQU         0x400253FC 
counter		 EQU 0x00007BFC ;7BFc
bitAddress	 EQU 0x20000401
I2CMSA		 EQU 0x40020000
I2CMCS		 EQU 0x40020004
I2CMDR		 EQU 0x40020008
I2CMTPR		 EQU 0x4002000C

										
			AREA 	main, CODE, READONLY
			THUMB
			EXPORT  __main
			EXTERN	ADC_INIT
			EXTERN  TIMER_INIT
			EXTERN  GPIO_INIT
			EXTERN  DELAY100
			EXTERN  I2C_INIT
			EXTERN  POT
__main		
			BL GPIO_INIT
			BL ADC_INIT
idle		
			BL DELAY100

			LDR R1,=GPIO_PORTF_DATA	;mavi
			LDR R0,[R1]
			MOV R0,#0x04	;led
			STR R0,[R1]
asilcheck   
checkrec    LDR R1,=GPIO_PORTF_DATA
			LDR R0,[R1]		;tus basildi mi (0 oldu mu) record button
			ANDS R0,#0x10
			BEQ checkRecJr
checkplay	LDR R1,=GPIO_PORTF_DATA
			LDR R0,[R1]		;play button
			ANDS R0,#0x01
			BEQ checkPlayJr
			B   asilcheck
			
checkRecJr  BL DELAY100
			LDR R1,=GPIO_PORTF_DATA
releaseR	LDR R0,[R1]
			ANDS R0,#0x10
			BEQ releaseR
			B   verial
			
checkPlayJr BL DELAY100
			LDR R1,=GPIO_PORTF_DATA
releaseP	LDR R0,[R1]
			ANDS R0,#0x01
			BEQ releaseP
			B   play


verial
			BL GPIO_INIT
			BL ADC_INIT
			LDR R11, =counter 
			LDR R5, =bitAddress
			MOV	R8,#0;
			
			LDR R1,=GPIO_PORTF_DATA	;kirmizi
			LDR R0,[R1]
			MOV R0,#0x02
			STR R0,[R1]
			
			
			BL TIMER_INIT
dongu		WFI         ;veri alma bolumu
			CMP  R11,#0
			BNE  dongu
			B idle
play
			LDR  R1,=GPIO_PORTF_DATA
			LDR  R0,[R1]
			MOV  R0,#0x08 ;green
			STR  R0,[R1]

			BL   I2C_INIT
bas
			LDR  R7,=bitAddress
			MOV  R3,R8 ;counter
tekrar		
			BL POT
			LDR  R1,=I2CMTPR
			MOV  R0,R9
			STR  R0,[R1]
					
			LDR  R1,=I2CMSA
			MOV  R0,#0xC4
			STR  R0,[R1]
			
			LDR  R1,=I2CMDR		
			LDRB R6,[R7]
			LSR  R6,#4
			BIC  R6,#0xF0
			STRB  R6,[R1]
			
			LDR  R1,=I2CMCS
			MOV  R2,#0x3 ;start and run
			STR  R2,[R1]
			NOP
			NOP
			NOP
			
busystart	LDR  R0,[R1] ;check if it is busy
			ANDS R0,#0x01
			BNE  busystart
			
			

			LDR  R1,=I2CMDR		
			LDRB R6,[R7],#1
			LSL  R6,#4
			BIC  R6,#0x0F
			STRB  R6,[R1]

			LDR  R1,=I2CMCS
			MOV  R2,#0x5	;stop and run
			STR  R2,[R1]
			NOP
			NOP
			NOP
			
busystop	LDR  R0,[R1]
			ANDS R0,#0x01
			BNE  busystop

			
			
			LDR R1,=GPIO_PORTF_DATA
			LDR R0,[R1]
			ANDS R0,#0x01
			BEQ  playRel
			SUBS R3,#1
			BNE tekrar
			B bas
			
playRel     BL DELAY100
			LDR R1,=GPIO_PORTF_DATA
asd			LDR R0,[R1]
			ANDS R0,#0x01
			BEQ asd
			B   idle			
			
			
done		B	done     			
			END