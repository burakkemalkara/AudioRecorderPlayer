RCGCADC      EQU 0x400FE638 ; ADC clock register
ADC0_ACTSS   EQU 0x40038000 ; Sample sequencer (ADC0 base address)
ADC0_RIS     EQU 0x40038004 ; Interrupt status
ADC0_IM      EQU 0x40038008 ; Interrupt select
ADC0_EMUX    EQU 0x40038014 ; Trigger select
ADC0_PSSI    EQU 0x40038028 ; Initiate sample
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
					
			AREA 	adcint, CODE, READONLY
			THUMB
			EXPORT	ADC_INIT
					


ADC_INIT	PROC
			LDR R1, =RCGCADC ; Turn on ADC clock
			LDR R0, [R1]
			ORR R0, R0, #0x01 ; set bit 0 to enable ADC0 clock
			STR R0, [R1]
			NOP
			NOP
			NOP ; Let clock stabilize
			LDR R1, =RCGCGPIO ; Turn on GPIO clock
			LDR R0, [R1]
			ORR R0, R0, #0x10 ; set bit 4 to enable port E clock
			STR R0, [R1]
			NOP
			NOP
			NOP ; Let clock stabilize
			LDR R1, =PORTE_DIR	;enable Alternate Func
			LDR R0, [R1]
			AND R0, R0, #0x00 ; set bit 3 to enable alt functions on PE3
			STR R0, [R1]
			LDR R1, =PORTE_AFSEL	;enable Alternate Func
			LDR R0, [R1]
			ORR R0, R0, #0x18 ; set bit 3 to enable alt functions on PE3 and PE4
			STR R0, [R1]
			;No require for PCTL since default is AIN0
			LDR R1, =PORTE_DEN
			LDR R0, [R1]
			BIC R0, R0, #0x18 ; clear bit 3 to disable analog on PE3
			STR R0, [R1]
			; Enable analog on PE3
			LDR R1, =PORTE_AMSEL
			LDR R0, [R1]
			ORR R0, R0, #0x18 ; set bit 3 to enable analog on PE3
			STR R0, [R1]
			; Disable sequencer while ADC setup
			LDR R1, =ADC0_ACTSS
			LDR R0, [R1]
			BIC R0, R0, #0x0C ; clear bit 3 to disable seq 3 &2
			STR R0, [R1] 
			; Select trigger source
			LDR R1, =ADC0_EMUX
			LDR R0, [R1]
			BIC R0, R0, #0xFF00 ; clear bits 15:12 to select SOFTWARE
			STR R0, [R1] 
			; Select input channel
			LDR R1, =ADC0_SSMUX3
			LDR R0, [R1]
			BIC R0, R0, #0x000F ; clear bits 3:0 to select AIN0
			STR R0, [R1]
			LDR R1, =ADC0_SSMUX2 ;
			LDR R0, [R1]
			BIC R0, R0, #0x000F ; clear bits 3:0 
			ORR R0,#0x0009		; select AIN9 for PB4
			STR R0, [R1]
			; Config sample sequence
			LDR R1, =ADC0_SSCTL3
			LDR R0, [R1]
			ORR R0, R0, #0x06 ; set bits 2:1 (IE0, END0)
			STR R0, [R1]
			LDR R1, =ADC0_SSCTL2
			LDR R0, [R1]
			ORR R0, R0, #0x06 ; set bits 2:1 (IE0, END0)
			STR R0, [R1]
			; Set sample rate
			LDR R1, =ADC0_PP
			LDR R0, [R1]
			ORR R0, R0, #0x07 ; set bits 3:0 to 1 for 125k sps
			STR R0, [R1]
			; Done with setup, enable sequencer
			LDR R1, =ADC0_ACTSS
			LDR R0, [R1]
			ORR R0, R0, #0x0C ; set bit 3 to enable seq 3
			STR R0, [R1] ; sampling enabled but not initiated yet		
			BX LR ; return
			ENDP
			END