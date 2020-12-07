; Pulse.s
; Routine for creating a pulse train using interrupts
; This uses Channel 0, and a 1MHz Timer Clock (_TAPR = 15 )
; Uses Timer0A to create pulse train on PF2

;Nested Vector Interrupt Controller registers
NVIC_EN0_INT19		EQU 0x00080000 ; Interrupt 19 enable
NVIC_EN0			EQU 0xE000E100 ; IRQ 0 to 31 Set Enable Register
NVIC_PRI4			EQU 0xE000E410 ; IRQ 16 to 19 Priority Register
NUM			EQU			0X00085556	
; 16/32 Timer Registers
TIMER0_CFG			EQU 0x40030000
TIMER0_TAMR			EQU 0x40030004
TIMER0_CTL			EQU 0x4003000C
TIMER0_IMR			EQU 0x40030018
TIMER0_RIS			EQU 0x4003001C ; Timer Interrupt Status
TIMER0_ICR			EQU 0x40030024 ; Timer Interrupt Clear
TIMER0_TAILR		EQU 0x40030028 ; Timer interval
TIMER0_TAPR			EQU 0x40030038
TIMER0_TAR			EQU	0x40030048 ; Timer register
	
;GPIO Registers
GPIO_PORTF_DATA    EQU  0x400253FC
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions

;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control
;ADC Registers
ADC0_RIS     		EQU 0x40038004 ; Interrupt status
ADC0_PSSI   		EQU 0x40038028 ; Initiate sample
ADC0_SSFIFO3 		EQU 0x400380A8 ; Channel 3 results
ADC0_ISC     		EQU 0X4003800C	; ADC Interrupt Clear
counter			    EQU 0x00007BFC
bitAddress	        EQU 0x20000401
;---------------------------------------------------
range					EQU	0x0000007D
;---------------------------------------------------
					
			AREA 	main, CODE, READONLY
			THUMB
			EXPORT 	My_Timer0A_Handler
			EXPORT	TIMER_INIT
			EXTERN  DELAY100		
;---------------------------------------------------					
My_Timer0A_Handler	PROC
	PUSH {LR}
			LDR R1,=TIMER0_ICR; when interrupt arrive clear tatoris
			MOV R2,#0X01
			STRB R2,[R1]
			
			
			
			LDR R3, =ADC0_RIS 
			LDR R4, =ADC0_SSFIFO3
			LDR R2, =ADC0_PSSI 
			LDR R6,= ADC0_ISC 
			MOV R7,0;
			STR R7,[R2];
			STR R7,[R3];
			
			LDR R0, [R2]
			ORR R0, R0, #0x08 ; start SS3
			STR R0, [R2]
			
wait	    LDR R0, [R3] ;wait till RIS enable
			ANDS R0, #0x08
			BEQ wait
			LDR R0,[R4]	;R0 holds the value
			LSR R0,R0,#4
			STRB R0,[R5],#1
			MOV R0, #8
			STR R0, [R6] ; clear flag
			ADD R8,#1;counter
			
			LDR R1,=GPIO_PORTF_DATA
			LDR R0,[R1]
			ANDS R0,#0x10
			BEQ  recRel
			SUBS R11,#1
			BNE	 terminate
			BEQ  stop
recRel    	LDR R1, =TIMER0_CTL ; disable timer during setup LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			MOV R11,#0
			LDR  	R0,=NUM
loop		SUBS	R0,#1;3 clock cycle loop 
			BNE		loop
			LDR R1,=GPIO_PORTF_DATA
asd			LDR R0,[R1]
			ANDS R0,#0x10
			BEQ asd
stop		LDR R1, =TIMER0_CTL ; disable timer during setup LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			
terminate
			POP{LR}
			BX LR
					ENDP
;---------------------------------------------------

TIMER_INIT	PROC

			LDR R1, =SYSCTL_RCGCTIMER ; Start Timer0
			LDR R2, [R1]
			ORR R2, R2, #0x01
			STR R2, [R1]
			NOP ; allow clock to settle
			NOP
			NOP
			LDR R1, =TIMER0_CTL ; disable timer during setup LDR R2, [R1]
			BIC R2, R2, #0x01
			STR R2, [R1]
			LDR R1, =TIMER0_CFG ; set 16 bit mode
			MOV R2, #0x04
			STR R2, [R1]
			LDR R1, =TIMER0_TAMR
			MOV R2, #0x02 ; set to periodic, count down
			STR R2, [R1]
			LDR R1, =TIMER0_TAILR ; initialize match clocks
			LDR R2, =range
			STR R2, [R1]
			LDR R1, =TIMER0_TAPR
			MOV R2, #15 ; divide clock by 16 to
			STR R2, [R1] ; get 1us clocks
			LDR R1, =TIMER0_IMR ; enable timeout interrupt
			MOV R2, #0x01
			STR R2, [R1]
; Configure interrupt priorities
; Timer0A is interrupt #19.
; Interrupts 16-19 are handled by NVIC register PRI4.
; Interrupt 19 is controlled by bits 31:29 of PRI4.
; set NVIC interrupt 19 to priority 2
			LDR R1, =NVIC_PRI4
			LDR R2, [R1]
			AND R2, R2, #0x00FFFFFF ; clear interrupt 19 priority
			ORR R2, R2, #0x40000000 ; set interrupt 19 priority to 2
			STR R2, [R1]
; NVIC has to be enabled
; Interrupts 0-31 are handled by NVIC register EN0
; Interrupt 19 is controlled by bit 19
; enable interrupt 19 in NVIC
			LDR R1, =NVIC_EN0
			MOVT R2, #0x08 ; set bit 19 to enable interrupt 19
			STR R2, [R1]
; Enable timer
			LDR R1, =TIMER0_CTL
			LDR R2, [R1]
			ORR R2, R2, #0x03 ; set bit0 to enable
			STR R2, [R1] ; and bit 1 to stall on debug		
			BX LR ; return
			ENDP
			END
				


			