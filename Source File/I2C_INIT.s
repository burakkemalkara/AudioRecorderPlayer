;LABEL				DIRECTIVE	VALUE		COMMENT
PORTF_LOCK	  	   EQU         0X40025520	;LOCK ADRESS
RCGCI2C			   EQU		   0x400FE620
RCGCGPIO  		   EQU  	   0x400FE608
PORTB_DIR    	   EQU         0x40005400
PORTB_AFSEL  	   EQU         0x40005420
PORTB_DEN    	   EQU         0x4000551C
PORTB_ODR		   EQU  	   0x4000550C
PORTB_PCTL		   EQU  	   0x4000552C
I2CMCR			   EQU		   0x40020020
I2CMTPR			   EQU         0x4002000C
I2CMSA			   EQU		   0x40020000
RCC				   EQU		   0x400FE000
RIS				   EQU		   0x400FE050

I2CMCS		 EQU 0x40020004
I2CMDR		 EQU 0x40020008

counter		 EQU 0x00007BFC ;7BFc
bitAddress	 EQU 0x20000401
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA        sdata, DATA, READONLY
            THUMB

;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	I2C, READONLY, CODE
			THUMB		
			EXPORT  	I2C_INIT

I2C_INIT	
PROC
					PUSH {R0-R5}
					PUSH {LR}
					
;					LDR	 R1,=RCC
;					LDR  R0,[R1]
;					LDR  R2,=0x00400000
;					BIC  R0,R2  ; USEYS 
;					ORR  R0,#0x800     ;Bypass
;					STR  R0,[R1]
;					
;					LDR  R0,[R1]
;					ORR  R0,#0x0600	   ;XTAL
;					ORR  R0,#0x10	   ;PIOSC
;					BIC  R0,#0x2000	   ;Clear PWDN
;					STR  R0,[R1]
;					
;					LDR  R0,[R1]	   ;SYSDIV
;					ORR  R0,#0x04C00000
;					STR  R0,[R1]
;					
;					LDR  R1,=RIS
;					
;loop				
;					LDR  R0,[R1]
;					ANDS  R0,#0x40
;					ADD  R7,#1
;					BEQ  loop
;					
;					LDR	 R1,=RCC
;					LDR  R0,[R1]
;					BIC  R0,#0x800     ;Bypass
;					STR  R0,[R1]
					
					LDR	 R1,=RCGCI2C ; open clock of Port b I2c
					LDR  R0,[R1]
					ORR  R0,#0x01
					STR  R0,[R1]
					NOP
					NOP
					NOP
					
					LDR	 R1,=RCGCGPIO ; open clock of Prot b I2c
					LDR  R0,[R1]
					ORR  R0,#0x02
					STR  R0,[R1]
					NOP
					NOP
					NOP
					
					
					LDR  R1,=PORTB_DEN
					LDR  R0,[R1]
					ORR  R0,#0x0C
					STR  R0,[R1]
					
					LDR  R1,=PORTB_AFSEL
					LDR  R0,[R1]
					ORR  R0,#0x0C
					STR  R0,[R1]
					
					LDR  R1,=PORTB_ODR
					LDR  R0,[R1]
					ORR  R0,#0x08
					STR  R0,[R1]
					
					LDR  R1,=PORTB_PCTL
					LDR  R0,=0x3300
					STR  R0,[R1]
					
					LDR  R1,=I2CMCR
					LDR  R0,=0x10
					STR  R0,[R1]
					
					
					
					
					
					
					
					POP	{LR}
					POP {R0-R5}					
					BX LR
					
;LABEL      DIRECTIVE       VALUE                           COMMENT
			ALIGN
			END