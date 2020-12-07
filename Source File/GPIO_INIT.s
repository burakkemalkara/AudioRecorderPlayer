;LABEL				DIRECTIVE	VALUE		COMMENT
PORTF_LOCK	  	    EQU         0X40025520	;LOCK ADRESS
PORTF_KEY		    EQU		    0x4C4F434B
PORTF_CR            EQU         0X40025524          ;COMMITS SETTINGS
GPIO_PORTF_DATA     EQU         0x400253FC 
GPIO_PORTF_DIR      EQU         0x40025400
GPIO_PORTF_AFSEL    EQU         0x40025420
GPIO_PORTF_DEN      EQU         0x4002551C
IOB                 EQU         0xF0
SYSCTL_RCGCGPIO     EQU  	    0x400FE608
PORTF_PUR   	    EQU         0X40025510

;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA        sdata, DATA, READONLY
            THUMB

;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	GPIO, READONLY, CODE
			THUMB		
			EXPORT  	GPIO_INIT

GPIO_INIT	
PROC
					PUSH {R0-R5}
					PUSH {LR}
					LDR R1,=SYSCTL_RCGCGPIO		; Open port F clock
					LDR R0,[R1]
					ORR R0,R0,#0x20
					STR R0,[R1]
					NOP
					NOP
					NOP ; stabilize

					LDR       R1,=PORTF_LOCK
					LDR       R0,=PORTF_KEY      ;PasswORd
					STR       R0,[R1]
					LDR       R1,=PORTF_CR
					MOV       R0,#0x11   ;PF0 activating    
					STR       R0,[R1]
					LDR R1,=GPIO_PORTF_DIR ;initialize port b
					LDR R0,[R1]
					ORR R0,#0x0E
					STR R0,[R1]
					LDR R0,=PORTF_PUR
					MOV R1,#0X11
					STR R1,[R0]
					LDR R1,=GPIO_PORTF_AFSEL	;afsel should be 0
					LDR R0,[R1]
					BIC R0,#0xFF
					STR R0,[R1]
					LDR R1,=GPIO_PORTF_DEN		;den should be all 1
					LDR R0,[R1]
					ORR R0,#0xFF
				    STR R0,[R1] 
					POP	{LR}
					POP {R0-R5}					
					BX LR
					
;LABEL      DIRECTIVE       VALUE                           COMMENT
			ALIGN
			END