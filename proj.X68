*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
	ORG	$1000
PROMPT	DC.B 'MONITOR441> ',0
INPUT	DS.B 80
TXT_BUF	DS.B 80
MUS_BUF	DS.B 100
PMT		DS.B 80

M_HELP	DC.B 'Monitor help message: ',$D,$A,$A,0
M_HP1	DC.B 'MDSP <addr1>,[<addr2>] --Display a memory block',$D,$A,0
M_HP2	DC.B 'SORTW <addr1>,<addr2>;(A/D) --Sort a block of memory',$D,$A,0
M_HP3	DC.B 'MM <addr1>;(B/W/L) --Display memory and enter new data',$D,$A,0
M_HP4	DC.B 'MS <addr1>;(number/text in single quotes) --Set a block of memory',$D,$A,0
M_HP5	DC.B 'BF <addr1>,<addr2>;(number) --Fill the memory block with a number',$D,$A,0
M_HP6	DC.B 'BMOV <addr1>,<addr2>;<addr3> --Move block between addr1 and addr2 to location addr3',$D,$A,0
M_HP7	DC.B 'BTST <addr1>,<addr2> --Test a block of memory',$D,$A,0
M_HP8	DC.B 'BSCH <addr1>,<addr2>;(text in single quotes) --Search for the text within memory block',$D,$A,0
M_HP9	DC.B 'GO <addr1> --Start executing at address addr1',$D,$A,0
M_HP10	DC.B 'DF --Display formatted registers',$D,$A,0
M_HP11	DC.B 'EXIT --Exit the monitor program',$D,$A,0
M_HP12	DC.B 'ENCR <addr1>,<addr2>;<key>,<IV> --Encrypt the memory block with key and IV',$D,$A,0
M_HP13	DC.B 'DECR <addr1>,<addr2>;<key>,<IV> --Decrypt the memory block with key and IV',$D,$A,0
M_HP14	DC.B 'RAND --Generate a random number between 0 and 99',$D,$A,0
M_BA	DC.B ' BA=',0
M_IR	DC.B ' IR=',0
M_SSW	DC.B 'SSW=',0

M_INST	DC.B 'What?',$D,$A,0
M_CRLF	DC.B $D,$A,0
M_BT_Y	DC.B 'Test completed. No error found.',0
M_BT_F	DC.B 'FFFF',0
M_BT_0	DC.B '0000',0
M_BT_FA	DC.B 'Failed at ',0
M_BT_W	DC.B ' wrote:',0
M_BT_R	DC.B ' read:',0
M_SPQ	DC.B $20,$27,0
M_QCRLF	DC.B $27,$D,$A,0
M_GOTST	DC.B 'testing GO command',$D,$A,$A,0
M_REGS	DC.B $D,$A,'D0=  D1=  D2=  D3=',$D,$A,'D4=  D5=  D6=  D7=',$D,$A,'A0=  A1=  A2=  A3=',$D,$A,'A4=  A5=  A6=',0
M_PC	DC.B $D,$A,'PC=',0
M_SR	DC.B '  SR=',0
M_US	DC.B '  US=',0
M_SS	DC.B '  SS=',0
M_END	DC.B 'Monitor terminated',0
M_RAND	DC.B 'Collecting random data',$D,$A,'please keep mouse moving for a few seconds ......',0
M_BERR	DC.B 'BUS ERROR',0
M_AERR	DC.B 'ADDRESS ERROR',0
M_ILLI	DC.B 'ILLEGAL INSTRUCTION',0
M_PRIV	DC.B 'PRIVILEGE VIOLATION',0
M_DIVZ	DC.B 'DIVIDE BY ZERO',0
M_CHKI	DC.B 'CHECK INSTRUCTION',0
M_LINA	DC.B '1010 TRAP ERROR',0
M_LINF	DC.B '1111 TRAP ERROR',0

	ORG	(*+1)&-2		; Force Word alignment

CMDS	DC.W L_MDSP
		DC.B 'HELP',0,0
		DC.W HELP
L_MDSP	DC.W L_SORTW
		DC.B 'MDSP',0,0
		DC.W MDSP
L_SORTW DC.W L_MM
		DC.B 'SORTW',0
		DC.W SORTW
L_MM	DC.W L_MS
		DC.B 'MM',0,0
		DC.W MM
L_MS	DC.W L_BF
		DC.B 'MS',0,0
		DC.W MS
L_BF	DC.W L_BMOV
		DC.B 'BF',0,0
		DC.W BF
L_BMOV	DC.W L_BTST
		DC.B 'BMOV',0,0
		DC.W BMOV
L_BTST	DC.W L_BSCH
		DC.B 'BTST',0,0
		DC.W BTST
L_BSCH	DC.W L_GO
		DC.B 'BSCH',0,0
		DC.W BSCH
L_GO	DC.W L_DF
		DC.B 'GO',0,0
		DC.W GO
L_DF	DC.W L_EXIT
		DC.B 'DF',0,0
		DC.W DF
L_EXIT	DC.W L_ENCR
		DC.B 'EXIT',0,0
		DC.W EXIT
L_ENCR	DC.W L_DECR
		DC.B 'ENCR',0,0
		DC.W ENCR
L_DECR	DC.W L_RAND
		DC.B 'DECR',0,0
		DC.W DECR
L_RAND	DC.W L_END
		DC.B 'RAND',0,0
		DC.W RAND
L_END
	
	ORG	(*+1)&-2		; Force Word alignment
START:                  ; first instruction of program
		MOVE.L	#BERR,$8	; initialize vectors
		MOVE.L	#AERR,$C
		MOVE.L	#ILLI,$10
		MOVE.L	#PRIV,$20
		MOVE.L	#DIVZ,$14
		MOVE.L	#CHKI,$18
		MOVE.L	#LINA,$28
		MOVE.L	#LINF,$2C
		MOVEA.L	#$3000,A7
		LEA		PROMPT,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		INPUT,A1	; input buffer
		MOVE.B	#2,D0
		TRAP	#15
		MOVEA.L	A1,A2		; A2 is pointer of input
		LEA		CMDS,A3		; A3 is pointer in list
		LEA		L_END,A4	; A4 is end of list
L_TST	MOVEA.L	A3,A5
		ADDA.L	#2,A5
CMPNEXT	MOVE.B	(A2),D1		; backup the tested character
		CMPI.B	#$20,D1		; if the cursor hits a space,
		BNE		CMP_CNT
		CMPI.B	#0,(A5)		; and the target instruction ends,
		BEQ		Y_MATCH		; it's a match
CMP_CNT	CMPM.B	(A5)+,(A2)+	; compare the two characters
		BNE		N_MATCH
		CMPI.B	#0,D1		; if same, and target instruction ends,
		BEQ		Y_MATCH		; it's a match
		BRA		CMPNEXT		; otherwise, loop back
N_MATCH	MOVEA.L	A1,A2		; cursor back to start point
		MOVEA.W	(A3),A3		; A3 point to the head of next element
		CMP.W	#L_END,A3	; if A3 reaches end of list,
		BEQ		N_INST		; it's not a valid instruction
		BRA		L_TST
Y_MATCH	MOVEA.W	(A3),A3
		MOVEA.W	-2(A3),A5	; deinference A3 and minus 2, we get address of subroutine
		JSR		(A5)
		BRA		START		; end the execution

HELP	MOVEM.L	D0-D7/A0-A6,-(SP)
		LEA		M_HELP,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP1,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP2,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP3,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP4,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP5,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP6,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP7,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP8,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP9,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP10,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP11,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP12,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP13,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_HP14,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

MDSP	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		CMPI.B	#$2C,(A2)	; if ',' is found,
		BEQ		MD_2N		; 2 parameters are received
		MOVEA.L	D7,A5		; A5 points to beginning of block
		MOVEA.L	A5,A6
		ADDA.L	#16,A6		; A6 points to ending of block, i.e. A5+16
		CLR.L	D4
		BSR		P_MM		; print content between A5 and A6
		BRA		MD_END
MD_2N	MOVEA.L	D7,A5		; A5 has the beginning address of memory block
		BSR		SC_NXT
		MOVEA.L	D7,A6		; A6 has the ending address of memory block
		CLR.L	D4
		BSR		P_MM
MD_END	LEA		M_CRLF,A1	; print an empty line to finish
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

SORTW	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5
		MOVEA.L	A5,A4
		BSR		SC_NXT
		MOVEA.L	D7,A6
		SUBQ.L	#2,A6
		CMPI.B	#$41,1(A2)	; check if the input is 'A'
		BEQ		ASCE
		CMPI.B	#$44,1(A2)	; check if the input is 'D'
		BEQ		DESC
		BRA		N_INST		; if neither matches, illegal instruction
ASCE	LEA		CMPER_A,A1	; load ascending comparator to A1
		BRA		SRT_LO1
DESC	LEA		CMPER_D,A1	; load descending comparator to A1
SRT_LO1	MOVEA.L	A4,A5		; A5 points to the first position
SRT_LO2	CMP.W	(A5)+,(A5)+
		JMP		(A1)		; A1 is a function pointer to comparator
NO_SWAP	SUBQ.L	#2,A5		; no need to swap, move to the next position
		CMP.L	A5,A6		; check for the end of list
		BNE		SRT_LO2		; go to the second loop
		BRA		SRT_END
DO_SWAP	MOVE.L	-(A5),D2	; swap the two words
		SWAP.W	D2
		MOVE.L	D2,(A5)
		BRA		SRT_LO1		; go to the first loop
SRT_END	MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS
		
CMPER_A	BLT		DO_SWAP		; comparator for ascending
		BRA		NO_SWAP
CMPER_D	BHI		DO_SWAP		; comparator for descending
		BRA		NO_SWAP

MM		MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A3
		CMPI.B	#$3B,(A2)+	; check ';'
		BNE		N_INST
		CMPI.B	#$42,(A2)	; check 'B'
		BEQ		MM_LOB
		CMPI.B	#$57,(A2)	; check 'W'
		BEQ		MM_LOW
		CMPI.B	#$4C,(A2)	; check 'L'
		BEQ		MM_LOL
		BRA		N_INST
MM_CT1	MOVEA.L	A3,A5
		MOVEA.L	A5,A6
		ADDA.L	D6,A6		; move A6 to next position
		MOVE.L	#1,D4		; print without space
		BSR		P_MM
		LEA		TXT_BUF,A1	; receive input
		MOVE.B	#2,D0
		TRAP	#15
		MOVEA.L	A1,A2
		CMP.B	#$2E,(A2)	; check '.'
		BEQ		MM_END
		CMP.B	#$20,(A2)	; check ' '
		BNE		N_INST
		BSR		SC_NXT
		CMPI.B	#1,D6		; use D6 to determine length
		BEQ		MM_MOB
		CMPI.B	#2,D6
		BEQ		MM_MOW
		CMPI.B	#4,D6
		BEQ		MM_MOL
MM_CT2	BRA		MM_CT1
MM_END	LEA		M_CRLF,A1	; print an empty line to finish
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS
MM_LOB	MOVEQ.L	#1,D6		; load value to D6
		BRA		MM_CT1
MM_LOW	MOVEQ.L	#2,D6
		BRA		MM_CT1
MM_LOL	MOVEQ.L	#4,D6
		BRA		MM_CT1
MM_MOB	MOVE.B	D7,(A3)+
		BRA		MM_CT2
MM_MOW	MOVE.W	D7,(A3)+
		BRA		MM_CT2
MM_MOL	MOVE.L	D7,(A3)+
		BRA		MM_CT2
		
MS		MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A3		; A3 has the starting address
		CMPI.B	#$2C,(A2)+
		BNE		N_INST
		CMPI.B	#$27,(A2)
		BNE		MS_HEX		; if the first char is not ''', it's hex
		ADDQ.L	#1,A2		; otherwise, it's ascii
MS_LO1	MOVE.B	(A2)+,(A3)+	; move ascii into destination memory location
		CMPI.B	#$27,(A2)
		BNE		MS_LO1
		BRA		MS_END
MS_HEX	MOVEA.L	A2,A5
MS_LO2	CMPI.B	#0,(A2)		; if '' is found,
		BEQ		MS_E1		; end the loop
		ADDQ.L	#1,A2
		BRA		MS_LO2		; otherwise, loop
MS_E1	MOVEA.L	A2,A6
		BSR		ATOI
		MOVE.L	D7,D6		; D7 has the hex number, D6 is a copy
MS_LO3	ROL.L	#8,D6		; test the highest byte
		CMPI.B	#0,D6		; if it's zero
		BNE		MS_E2
		LSL.L	#8,D7		; remove the leading zero byte in D7
		BRA		MS_LO3
MS_E2	MOVE.L	D7,(A3)
MS_END	LEA		M_CRLF,A1	; print an empty line to finish
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

BF		MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5		; A5 and A6 has starting and ending address
		BSR		SC_NXT
		MOVEA.L	D7,A6
		BSR		SC_NXT
BF_LO	MOVE.W	D7,(A5)+	; move the word into memory
		CMP.L	A5,A6
		BNE		BF_LO
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

BMOV	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5		; A5 and A6 has starting and ending address
		BSR		SC_NXT
		MOVEA.L	D7,A6
		BSR		SC_NXT
		MOVEA.L	D7,A4
BM_LO	MOVE.B	(A5)+,(A4)+	; move a byte
		CMP.L	A5,A6
		BNE		BM_LO
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

BTST	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5
		BSR		SC_NXT
		MOVEA.L	D7,A6
		MOVEA.L	A5,A3		; A3 has a copy of starting address
		LEA		M_BT_F,A4
BT_LO1	CMP.L	A5,A6
		BEQ		BT_E1
		MOVE.W	#$FFFF,(A5)
		CMPI.W	#$FFFF,(A5)	; write and read $FFFF
		BEQ		BT_C1
		BRA		BT_ERR
BT_C1	ADDA.L	#2,A5
		BRA		BT_LO1
BT_E1	MOVEA.L	A3,A5
		LEA		M_BT_0,A4
BT_LO2	CMP.L	A5,A6
		BEQ		BT_E2
		MOVE.W	#0,(A5)
		CMPI.W	#0,(A5)		; write and read $0000
		BEQ		BT_C2
		BRA		BT_ERR
BT_C2	ADDA.L	#2,A5
		BRA		BT_LO2
BT_E2	LEA		M_BT_Y,A1	; print success message
		MOVE.B	#13,D0
		TRAP	#15
BT_END	LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS
BT_ERR	LEA		M_BT_FA,A1	; print error message
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.L	A5,D1
		MOVE.L	#16,D2
		MOVE.B	#15,D0
		TRAP	#15
		LEA		M_BT_W,A1	; 'wrote:'
		MOVE.B	#14,D0
		TRAP	#15
		MOVEA.L	A4,A1
		MOVE.B	#14,D0
		TRAP	#15
		LEA		M_BT_R,A1	; 'read:'
		MOVE.B	#14,D0
		TRAP	#15
		MOVEA.L	A5,A6
		ADDA.L	#2,A6
		MOVE.L	#1,D4
		BSR		P_MM
		BRA		BT_END
		
BSCH	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5
		BSR		SC_NXT
		MOVEA.L	D7,A6		; A5 and A6 define start and end of text
		CMPI.B	#$3B,(A2)+
		BNE		N_INST		; check ';'
		CMPI.B	#$27,(A2)+
		BNE		N_INST		; check '''
		MOVEA.L	A2,A3
		ADDA.L	#1,A3
		CMPI.B	#$27,(A3)+
		BEQ		N_INST
BS_LO1	CMPI.B	#$27,(A3)+
		BNE		BS_LO1		; A2 and A3 define start and end of pattern
		SUBA.L	#1,A3
		MOVE.B	#0,(A3)		; prepare pattern to output
		MOVE.L	A3,D3
		SUB.L	A2,D3		; D3 is the length of pattern
* calculate partial match table
		LEA		PMT,A0		; A0 is the start of PMT
		LEA		PMT,A1
		CLR.L	D0			; D0 is maximum length of last substring
		MOVEA.L	A2,A4		; A4 is the cursor in pattern
		ADDA.L	#1,A4
		MOVE.B	#0,(A1)+
BS_LO2	CMPI.L	#0,D0		; if maximum length=0 or contents are the same
		BEQ		BS_CNT1
		MOVE.B	(A4),D1
		CMP.B	(A2,D0),D1
		BEQ		BS_CNT1		; do not loop 
		MOVE.B	-1(A0,D0),D0	; otherwise, get new maximum length
		BRA		BS_LO2		; loop
BS_CNT1	MOVE.B	(A4)+,D1
		CMP.B	(A2,D0),D1	; if contents are the same, increase maximum length
		BNE		BS_CNT2
		ADDQ.B	#1,D0
BS_CNT2	MOVE.B	D0,(A1)+
		CMPA.L	A4,A3
		BNE		BS_LO2
* find matching positions using PMT
		CLR.L	D0			; D0 is a counter in pattern
BS_LO3	CMPI.L	#0,D0		; if counter=0 or contents are the same
		BEQ		BS_CNT3
		MOVE.B	(A5),D1
		CMP.B	(A2,D0),D1
		BEQ		BS_CNT3		; do not loop
		MOVE.B	-1(A0,D0),D0	; otherwise, get the new counter
		BRA		BS_LO3
BS_CNT3	MOVE.B	(A5),D1
		CMP.B	(A2,D0),D1
		BNE		BS_CNT4
		ADDQ.B	#1,D0		; if contents are the same, increase counter
BS_CNT4	CMP.B	D0,D3		; check if the whole pattern is compared
		BNE		BS_CNT5
		MOVEM.L	D0,-(SP)
		MOVE.L	A5,D1		; print address and pattern
		ADD.L	#1,D1
		SUB.L	D3,D1
		MOVE.B	#16,D2
		MOVE.B	#15,D0
		TRAP	#15
		LEA		M_SPQ,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVEA.L	A2,A1
		MOVE.B	#14,D0
		TRAP 	#15
		LEA		M_QCRLF,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0
		MOVE.B	-1(A0,D0),D0
BS_CNT5	ADDA.L	#1,A5
		CMPA.L	A5,A6
		BNE		BS_LO3
BS_END	LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

GO		MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT			; read the address
		MOVEA.L	D7,A5
		JSR		(A5)			; jump to program
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

DF		MOVEM.L	D0-D7/A0-A6,-(SP)
		LEA		M_REGS,A0
DF_LO	MOVE.W	#5,D1
		MOVEA.L	A0,A1		; print register name
		MOVE.B	#1,D0
		TRAP	#15
		MOVE.L	(SP)+,D1	; extract register value
		BSR		ITOA
		MOVEA.L	A5,A1
		MOVE.W	#8,D1
		MOVE.B	#1,D0
		TRAP	#15			; print register value
		ADDA.L	#5,A0
		CMPI.B	#0,(A0)
		BNE		DF_LO
		LEA		M_PC,A1		; print 'PC='
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.L	#DF,D1		; print PC value
		BSR		ITOA
		MOVEA.L	A5,A1
		MOVE.W	#8,D1
		MOVE.B	#1,D0
		TRAP	#15
		LEA		M_SR,A1		; print 'SR='
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.W	SR,D1		; print SR value
		BSR		ITOA
		MOVEA.L	A5,A1
		ADDA.L	#4,A1
		MOVE.W	#4,D1
		MOVE.B	#1,D0
		TRAP	#15
		LEA		M_US,A1		; print 'US='
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.L	USP,A1		; print US value
		MOVE.L	A1,D1
		BSR		ITOA
		MOVEA.L	A5,A1
		MOVE.W	#8,D1
		MOVE.B	#1,D0
		TRAP	#15
		LEA		M_SS,A1		; print 'SS='
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.L	SP,D1
		BSR		ITOA
		MOVEA.L	A5,A1
		MOVE.W	#8,D1
		MOVE.B	#1,D0
		TRAP	#15
		
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		RTS

EXIT	LEA		M_END,A1
		MOVE.B	#13,D0
		TRAP	#15
		BRA     END_L

* Encryption and decryption using Cipher-Block Chaining (CBC) mode
ENCR	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5		; A5 and A6 are starting and ending address
		BSR		SC_NXT
		MOVEA.L	D7,A6
		BSR		SC_NXT
		MOVE.W	D7,D3		; D3 is key
		BSR		SC_NXT
		MOVE.W	D7,D4		; D4 is IV
ENC_LO	EOR.W	D4,(A5)		; XOR plaintext with the last ciphertext or IV
		EOR.W	D3,(A5)		; XOR block with key
		MOVE.W	(A5)+,D4
		CMPA.L	A5,A6
		BNE		ENC_LO
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

DECR	MOVEM.L	D0-D7/A0-A6,-(SP)
		BSR		SC_NXT
		MOVEA.L	D7,A5		; A5 and A6 are starting and ending address
		BSR		SC_NXT
		MOVEA.L	D7,A6
		BSR		SC_NXT
		MOVE.W	D7,D3		; D3 is key
		BSR		SC_NXT
		MOVE.W	D7,D4		; D4 is IV
DEC_LO	MOVE.W	(A5),D5		; D5 is a backup of ciphertext
		EOR.W	D3,(A5)		; XOR ciphertext with key
		EOR.W	D4,(A5)+	; XOR block with the last ciphertext or IV
		MOVE.W	D5,D4
		CMPA.L	A5,A6
		BNE		DEC_LO
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

* generate a random number between 0 and 99. Random data is collected form mouse.
RAND	MOVEM.L	D0-D7/A0-A6,-(SP)
		LEA		M_RAND,A1
		MOVE.B	#13,D0
		TRAP	#15
		LEA		MUS_BUF,A1
		CLR.L	D2			; D2 is counter
		CLR.L	D3			; D3 is a random number
RAND_LP	MOVE.B	#$0,D1		; read a mouse position
		MOVE.B	#61,D0
		TRAP	#15
		EOR.L	D1,D3
		MOVE.L	#10,D1		; delay for 0.1 sec
		MOVE.B	#23,D0
		TRAP	#15
		ADDQ.B	#1,D2
		CMP.B	#20,D2		; loop for 20 iterations
		BNE		RAND_LP
		LSL.L	#8,D3
		LSL.L	#8,D3
		LSR.L	#8,D3
		LSR.L	#8,D3
		DIVU.W	#100,D3		; mod the number by 100
		LSR.L	#8,D3
		LSR.L	#8,D3
		MOVE.L	D3,D1		; print the random number
		MOVE.L	#10,D2
		MOVE.B	#15,D0
		TRAP	#15
		LEA		M_CRLF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,D0-D7/A0-A6
		RTS

N_INST	LEA		M_INST,A1
		MOVE.B	#13,D0
		TRAP	#15
		BRA		START
		
* convert string between A5 and A6 to integer at D7
ATOI	MOVEM.L	D2/A4-A6,-(SP)
		CMPI.B	#$24,(A5)	; if the first char is $, skip it
		BNE		NODLR
		ADDQ.L	#1,A5
NODLR	MOVE.L	#0,D7		; D7 is result
		MOVEA.L	A6,A4
		SUBA.L	A5,A4
		CMPA.L	#8,A4		; if length>8, it's an illegal instruction
		BGT		N_INST
ATOI_LP	MOVE.B	(A5)+,D2
		BSR		A2HEX
		ADD.L	D2,D7
		CMP.L	A5,A6
		BEQ		ATOI_ED
		ASL.L	#4,D7
		BRA		ATOI_LP
ATOI_ED	MOVEM.L	(SP)+,D2/A4-A6
		RTS
		
* convert integer in D1.L to string at A5
ITOA	MOVEM.L	D2/A6,-(SP)
		LEA		TXT_BUF,A5
		MOVEA.L	A5,A6
		ADDA.L	#8,A6
ITOA_LP	MOVE.B	D1,D2
		LSL.B	#4,D2
		LSR.B	#4,D2
		BSR		HEX2A
		MOVE.B	D2,-(A6)
		LSR.L	#4,D1
		CMPA.L	A5,A6
		BNE		ITOA_LP
		MOVEM.L	(SP)+,D2/A6
		RTS
		
* Scan the next number end with ',' ';' or NULL. 
* Start scanning from A2+1. After subroutine, A2 will be placed after the number.
* Result is stored at D7
SC_NXT	MOVEM.L	A5-A6,-(SP)
		ADDQ.L	#1,A2		; skip the space before numbers
		MOVEA.L	A2,A5		; A5 has the starting address
SC_LO	CMPI.B	#$2C,(A2)	; if ',' is found,
		BEQ		SC_END
		CMPI.B	#$3B,(A2)	; if ';' is found,
		BEQ		SC_END
		CMPI.B	#$0,(A2)		; if '' is found,
		BEQ		SC_END		; end the loop
		ADDQ.L	#1,A2
		BRA		SC_LO		; otherwise, loop
SC_END	MOVEA.L	A2,A6
		BSR		ATOI		; convert to number in D7
		MOVEM.L	(SP)+,A5-A6
		RTS
		
* convert an ascii char at D2.B to hex number at D2.B
A2HEX	CMPI.B	#$41,D2
		BGE		A2H_CH
		SUBI.B	#$30,D2
		BRA		A2H_END
A2H_CH	SUBI.B	#$37,D2
A2H_END	RTS	
		
* convert a hex number at D2.B to ascii char at D2.B
HEX2A	CMPI.B	#10,D2
		BGE		H2A_CH
		ADDI.B	#$30,D2
		BRA		H2A_END
H2A_CH	ADDI.B	#$37,D2
H2A_END	RTS
		
* print memory from A5 to A6. D4 is a flag. if D4!=0, no space is printed between bytes
P_MM	MOVEM.L	D2-D3/A5-A6,-(SP)
p_LOOP	CMPI.L	#0,D4		; if D4 is zero, skip the part of printing space
		BNE		P_CNT
		MOVE.B	#$20,D1		; print space
		MOVE.B	#6,D0
		TRAP	#15
P_CNT	MOVE.B	(A5)+,D3
		MOVE.B	D3,D2
		LSR.B	#4,D2		; convert the higher 4 bits
		BSR		HEX2A
		MOVE.B	D2,D1
		MOVE.B	#6,D0
		TRAP	#15			; print the higher 4 bits
		MOVE.B	D3,D2
		LSL.B	#4,D2
		LSR.B	#4,D2		; convert the lower 4 bits
		BSR		HEX2A
		MOVE.B	D2,D1
		MOVE.B	#6,D0
		TRAP	#15			; print the lower 4 bits
		CMP.L	A5,A6
		BNE		P_LOOP
		MOVEM.L	(SP)+,D2-D3/A5-A6
		RTS

BERR	MOVEM.L	A1/A5/D0/D1,-(SP)
		LEA		M_BERR,A1
		MOVE.B	#13,D0
		TRAP	#15
		BRA		SBI			; print SSW, BA, IR
AERR	MOVEM.L	A1/A5/D0/D1,-(SP)
		LEA		M_AERR,A1
		MOVE.B	#13,D0
		TRAP	#15
		BRA		SBI			; print SSW, BA, IR
ILLI	MOVEM.L	A1/D0,-(SP)
		LEA		M_ILLI,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
PRIV	MOVEM.L	A1/D0,-(SP)
		LEA		M_PRIV,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
DIVZ	MOVEM.L	A1/D0,-(SP)
		LEA		M_DIVZ,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
CHKI	MOVEM.L	A1/D0,-(SP)
		LEA		M_CHKI,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
LINA	MOVEM.L	A1/D0,-(SP)
		LEA		M_LINA,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
LINF	MOVEM.L	A1/D0,-(SP)
		LEA		M_LINF,A1
		MOVE.B	#13,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/D0
		BSR		DF
		BRA		START
		

SBI		LEA		M_SSW,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.W	16(SP),D1	; print SSW
		BSR		ITOA
		MOVEA.L	A5,A1
		ADDA.L	#4,A1
		MOVE.W	#4,D1
		MOVE.B	#1,D0
		TRAP	#15
		LEA		M_BA,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.L	18(SP),D1	; print BA
		BSR		ITOA
		MOVEA.L	A5,A1
		MOVE.W	#8,D1
		MOVE.B	#1,D0
		TRAP	#15
		LEA		M_IR,A1
		MOVE.B	#14,D0
		TRAP	#15
		MOVE.W	22(SP),D1	; print IR
		BSR		ITOA
		MOVEA.L	A5,A1
		ADDA.L	#4,A1
		MOVE.W	#4,D1
		MOVE.B	#1,D0
		TRAP	#15
		MOVEM.L	(SP)+,A1/A5/D0/D1
		BSR		DF			; print registers
		BRA		START

	ORG	$3500	;AERR
		MOVE.L	#$123,A1
		MOVE.W	D1,(A1)
		RTS
	ORG $3520	;DIV0
		MOVE.L	#100,D0
		DIVU.W	#0,D0
		RTS
	ORG	$3540
		LEA		M_GOTST,A1
		MOVE.B	#13,D0
		TRAP	#15
		RTS
	ORG	$3560	;CHKI
		MOVE.L	#$3000,D6
		MOVE.L	#$3100,D7
		CHK.W	D6,D7
		RTS
	ORG	$3580	;PRIV
		ANDI.W	#$0,SR
		ANDI.W	#$0,SR

END_L
	SIMHALT             ; halt simulator

	END	START        ; last line of source
	
	






*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
