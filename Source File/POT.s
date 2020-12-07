RCGCADC      EQU 0x400FE638 ; ADC clock register
ADC0_ACTSS   EQU 0x40038000 ; Sample sequencer (ADC0 base address)
ADC0_IM      EQU 0x40038008 ; Interrupt select
ADC0_EMUX    EQU 0x40038014 ; Trigger select

ADC0_SSMUX3  EQU 0x400380A0 ; Input channel select
ADC0_SSMUX2  EQU 0x40038080 ; Input channel select
ADC0_SSCTL3  EQU 0x400380A4 ; Sample sequence control
ADC0_SSCTL2  EQU 0x40038084 ; Sample sequence control
ADC0_SSFIFO3 EQU 0x400380A8 ; Channel 3 results
ADC0_PP      EQU 0x40038FC4 ; Sample rate
RCGCGPIO     EQU 0x400FE608 ; GPIO clock register
PORTE_DEN    EQU 0x4002451C ; Digital Enable
PORTE_DIR    EQU 0x40024400 ; Digital Enable	
PORTE_PCTL   EQU 0x4002452C ; Alternate function select
PORTE_AFSEL  EQU 0x40024420 ; Enable Alt functions
PORTE_AMSEL  EQU 0x40024528 ; Enable analog
	
ADC0_RIS     EQU 0x40038004 ; Interrupt status
ADC0_PSSI    EQU 0x40038028 ; Initiate sample
ADC0_SSFIFO2 EQU 0x40038088 ; Channel 3 results
ADC0_ISC     EQU 0X4003800C	; ADC Interrupt Clear
					
			AREA 	adcint, CODE, READONLY
			THUMB
			EXPORT	POT
					

POT	PROC
	PUSH{R0-R7}
	PUSH{LR}
			LDR R3, =ADC0_RIS 
			LDR R4, =ADC0_SSFIFO2
			LDR R2, =ADC0_PSSI 
			LDR R6,= ADC0_ISC 
			MOV R7,0;
			STR R7,[R2];
			STR R7,[R3];
			
			
			LDR R0, [R2]
			ORR R0, R0, #0x04 ; start SS3
			STR R0, [R2]
			
wait	    LDR R0, [R3] ;wait till RIS enable
			CMP R0, #4
			BNE wait
			
			LDR R0,[R4]	;R0 holds the value
			CMP R0,0
			BEQ ata
			BNE devam
ata			MOV R0,#1
devam
			MOV R1,#0x200
			UDIV R0,R0,R1
			ADD R0,R0,#1
			MOV R9,R0
		POP{LR}
		POP{R0-R7}
			BX LR ; return
			ENDP
			END
	
	