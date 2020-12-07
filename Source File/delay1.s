NUM			EQU			0X0000000D  ;count number for 100 msec delay				
;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	Delay, READONLY, CODE
			THUMB	
			EXPORT  	DELAY1; Make available

DELAY1	
PROC	
			PUSH	{R0}
			PUSH 	{LR}
			LDR  	R0,=NUM
loop		SUBS	R0,#1;3 clock cycle loop 
			BNE		loop	
			POP		{LR}
			POP		{R0}
			BX		LR							; return
;***************************************************************
; End of the program  section
;***************************************************************
;LABEL      DIRECTIVE       VALUE                           COMMENT
			ALIGN
			END