; ----------------------------------------------------------------
; strings, constants
; ----------------------------------------------------------------

;		     12345678901234567890
pcmsg:		.db "Program Ctr: ",0
cfgst:		.db "Config Register: ",0
shad:		.db "Shadow ROM Off ",0
wpchk:		.db "Bank 1 WrProt ",0
ptst:		.db "Page Tst",0
ginpStr:	.db "INPUT bit : ",0
p0chk		.db "Page 0 :",0
p1chk		.db "Page 1 :",0
ram:		.db "RAM",0
rom:		.db "ROM or Empty",0
fail:		.db "Fail",0
pass:		.db "Pass",0
hi:		.db "High",0
lo:		.db "Low",0
hexMsg:		.db "Scan Code : ",0
hexExit:	.db " (Fn Addr to Exit)",0
ramMsg:		.db "RAM Found ",0
byteMsg:	.db " bytes   ",0		; extra padding for short strings
fnMsg:		.db "Fn ",0
plusMsg:	.db "Plus ",0
negMsg:		.db "Minus",0
goMsg:		.db "Go   ",0
addrMsg:	.db "Addr ",0
burnScan:	.db "Scanning",0
burnLatch:	.db "Latched ",0
menutitle:	.db "  Diags Main Menu",0
GPIOtitle:	.db "  GPIO Diags Menu",0
t1GMsg:		.db 0c6h,0c7h,0c3h,04h,28h,0e3h	; 7-seg hexbytes
segScr		.db "7-Seg Scroll",0
segLamp		.db "7-Seg Lamp Test",0
ledBt		.db "LED BAR Test",0
cfgReg		.db "Config Reg Value",0
gInp		.db "General Input Bit",0
bk1Wp		.db "Bank 1 WrProt Chk",0
spk		.db "Speaker Test",0
ramTst		.db "RAM Test",0
expTst		.db "EXPAND Page Test",0
togSh		.db "Toggle SHADOW",0
togPr		.db "Toggle PROTECT",0
togEx		.db "Toggle EXPAND",0
burnst:		.db "Burn-in Mode ",0
hex:		.db "HexPad Test",0
matrixScr	.db "Matrix Keypad Test",0
joyScr		.db "Joystick Port Test",0
diagVer		.db "Diags Version Info",0
ftdiScr		.db "FTDI Loopback Test",0
piCalc		.db "Calculate Pi ",0f7h,0
GPIOMenuStr	.db "=> GPIO Boards",0
GPIO8bit	.db "GPIO 8 bit I/O Test",0
GPIOClock	.db "GPIO RTC Test",0
GPIOSdCard	.db "GPIO SD Card Test",0
GLCDMenuStr	.db "GLCD Test",0
ex8msg		.db "8x8 Display Test",0
ftdiMsg		.db "FTDI Tx Rx Tests",0
discoMsg	.db "Disco LEDs Tests",0
discoMsg2	.db "Disco Interactive",0
discoInt:	.db "R=00 G=00h B=00h",0
red:		.db "Red    ",0			; R,G,B,blank strings must be in sequence
green:		.db "Green  ",0
blue:		.db "Blue   ",0
blankString:	.db "                   ",0	; must come after blue
lcdMsg:		.db "20x4 LCD Tests",0
barText:	.db "|76543210|",0

; 2 bytes ptr to string, 2 bytes ptr to routine to execute

menuTable:	.dw lcdMsg, lcdTest
		.dw segScr, segs, segLamp, segs2, discoMsg, disco, discoMsg2, discoInteractive	; outputs
		.dw ledBt, ledBar, ex8msg, ex8, spk, speaker			; outputs
		.dw cfgReg, readCfgReg, gInp, readGinput			; inputs
		.dw ramTst, ramFind, bk1Wp, wrprot, expTst, expandTest		; memory
		.dw togSh, tShadow, togPr, tProtect, togEx, tExpand		; system control
		.dw ftdiMsg, FTDI, ftdiScr, ftdiLoopback			; serial
		.dw hex, hexPad, matrixScr, matrix, joyScr, joy			; keyboard/joystick
		.dw piCalc, pi							; misc
		.dw GPIOMenuStr, doGPIOMenu					; GPIO peripherals
		.dw GLCDMenuStr, GLCDtest					; GLCD
		.dw burnst, burn, diagVer, diagsVer				; burnin & version

menuLen:	.equ (($-menuTable)/4)-1		; menu entries-1

GPIOMenu:	.dw GPIO8bit, GPIO8bitio
		.dw GPIOClock, clock
		.dw GPIOSdCard, sd_test
GPIOmenuLen:	.equ (($-GPIOMenu)/4)-1			; menu entries-1

burnTable:	.dw diagVer, diagsVer
		.dw lcdMsg, lcdTest
		.dw segScr, segs, segLamp, segs2, discoMsg, disco
		.dw ledBt, ledBar, ex8msg, ex8, spk, speaker
		.dw cfgReg, readCfgReg, gInp, readGinput
		.dw ramTst, ramFind, bk1Wp, wrprot, expTst, expandTest
		.dw ftdiScr, ftdiLoopback
		.dw piCalc, pi
		.dw 0000

pacTable:	.db 0feh,0feh,38h,38h,38h,38h,38h,38h		; T
		.db 0feh,0feh,0e0h,0f8h,0f8h,0e0h,0feh,0feh	; E
		.db 3ch,0feh,0eeh,0e0h,0e0h,0eeh,0feh,07ch	; C
		.db 00h,00h,00h,7eh,7eh,00h,00h,00h		; -
		.db 38h,78h,0f8h,38h,38h,38h,38h,38h		; 1
		.db 3ch,0feh,0e6h,0e0h,0eeh,0e6h,0feh,07ch	; G
		.db 0,0,0,0,0,0,0,0

lcdCustom:	.db 0,0,0,7,4,4,4,4	; topleft
		.db 0,0,0,1ch,4,4,4,4	; topright
		.db 4,4,4,7,0,0,0,0	; bottomleft
		.db 4,4,4,1ch,0,0,0,0	; bottomright
		.db 0,0,0,1fh,0,0,0,0	; horizontal
		.db 4,4,4,4,4,4,4,4	; vertical
		.db 0,0,1fh,0,1fh,0,0,0 ; 2 line horizontal
		.db 0,1fh,0,1fh,0,1fh,0,0 ; 3 line vertical


lcdText:	.db 0,4,4,4,4,4,4,6,6,7,7,6,6,4,4,4,4,4,4,1
		.db 5," TEC-1G Computer  ",5
		.db 5,"   Open Source!   ",5
		.db 2,4,4,4,4,4,4,6,6,7,7,6,6,4,4,4,4,4,4,3

; for GLCD

INIT_BASIC:
        .db      30H             ;8 Bit interface, basic instruction
        .db      0CH             ;display on, cursor & blink off
        .db      06H             ;cursor move to right ,no shift
        .db      01H             ;clear RAM
ROWS:   .db      80H,90H,88H,98H ;Text Row start position

; for RTC

days:		.db "Monday",0
		.db "Tuesday",0
		.db "Wednesday",0
		.db "Thursday",0
		.db "Friday",0
		.db "Saturday",0
		.db "Sunday",0
 
; for SD

spiCMD0:	.db 40h,0,0,0,0,95h		; reset			R1
spiCMD8:	.db 48h,0,0,1,0aah,87h		; send_if_cond		R7
spiCMD9:	.db 49h,0,0,1,0aah,87h		; send_CSD		R1
spiCMD10:	.db 4ah,0,0,0,0,1h		; send_CSD		R1
spiCMD55:	.db 77h,0,0,0,0,1		; APP_CMD		R1
spiACMD41:	.db 69h,40h,0,0,0,1		; send_OP_COND		R1
cmd8Str:	.db "CMD8: ",0
noCardStr:	.db "SD Card not Found",0
sdErrorStr:	.db "SD Card Error "
sdErrorStrNum:	.db "XX",0
megaBytes	.db "MB",0
cardTypeStr:	.db "SD Card type ",0


; ----------------------------------------------------------------
; RAM variables
; ----------------------------------------------------------------

	.ORG RAMST

pcBuff:		.block 6
cfgst2:		.block 4
segbuf:		.block 6
segptr:		.block 1
burnLoops:	.block 2
menuPos:	.block 1
menuSel:	.block 1
oldMenuPos:	.block 1
oldMenuSel:	.block 1
menuMenu:	.block 2
parentMenu	.block 2
menuNest:	.block 1
menuLength:	.block 1
oldMenuLen:	.block 1
menuTitl:	.block 2
RAMCRC:		.block 2
ROMCRC:		.block 2
ramst:		.block 2
ramtst:		.block 2
ramend:		.block 2
ramflag:	.block 1
decimalBuff:	.block 6
cfgMode:	.block 1
pageRam:	.block 1
hexPadBuff:	.block 21	; holds usr typing
kFlag:		.block 1	; FF = no key pressed
oldcaps:	.block 1
oldkey:		.block 1
capsval:	.block 1	; 1 = capslock on
kdelayval:	.block 1	; counter for delay betwen key repeats
kState:		.block 1
joyX:		.block 1
joyY:		.block 1
joyChar:	.block 1
e8x8Buff:	.block 8
scBit:		.block 1
scByte:		.block 1
tBuff:		.block 40
tBuffSize:	.equ $-tBuff
tBuffPtr:	.block 1
rVal:		.block 1
gVal:		.block 1
bVal:		.block 1

;	.ORG (($ + 0FH) & 0FFF0H) +1	; align to next 16 byte boundary +1 byte
; the rtest bytes need to be outside the tested block
; presently placing them here does that -- but its a hack

		.ORG (($ + 0FFH) & 0FF00H) + RTBLK

rTestLoc:	.block 2
rTestByte:	.block 1
rTestResult:	.block 1
rTestBuff:	.block RTBLK

; ----------------------------------------------------------------
; for Pi
; ----------------------------------------------------------------
		.org 1000h
IY0		.equ	$			; Base value for IY
NS		.equ	$-IY0			; N = Number of Digits
Nnn		.block	2			;
LENS		.equ	$-IY0			; LEN = array length
LENnn		.block	2			;
IS		.equ	$-IY0			; I sub loop counter
Inn		.block	2			;
JS		.equ	$-IY0			; J main loop counter
Jnn		.block	2			;
RESS		.equ	$-IY0			; RES = quotient
RESnn		.block	2			;
NINESS		.equ	$-IY0			; NINES = 9s counter
NINESnn		.block	1			;
PREDIGS		.equ	$-IY0			; PREDIG = digit preceding 9s
PREDIGnn	.block	1			;
DOTS		.equ	$-IY0			; DOT = dot to display after 1st digit
DOTnn		.block	1			;
GROUPS		.equ	$-IY0			; GROUP = Digits in group counter
GROUPnn		.block	1			;
GROUPSS		.equ	$-IY0			; GROUPS = Groups in line counter
GROUPSnn	.block	1			;
COUNTnn		.block	2			; COUNT = decimals counter
COUNTlcd	.block  1			; LCD line wrap counter
ARRAY		.block  1

; for RTC
rtcHours:	.block 1
rtcMinutes:	.block 1
rtcSeconds:	.block 1
rtcBuff:	.block 16

; for GLCD
GBUF:		.block 1024	; Graphics Buffer 16 * 64 = 1024 byte
ENDPT:		.block 2	; End Point for Line
SX:		.block 1	; Sign of X
SY:		.block 1	; Sign of Y
DX:		.block 2	; Change of X
DY:		.block 2	; Change of Y
ERR:		.block 2	; Error Rate
RAD:		.block 2	; Radius
CLRBUF:		.block 1	; Clear Buffer Flag on LCD Displaying

; for SD
byteBuff:	.block 2
sdSize:		.block 12
sdBuff:		.block 512+1+2			; 512 + header + CRC16

; ----------------------------------------------------------------
; ROM Signatures
; ----------------------------------------------------------------

	.ORG 0ffech			; release with 0ffech -- 16k

RELMAJOR:	.dw 07e7h		; 2023 !!
RELMINOR:	.dw 0101h		; 1.0
SOFTWARE:	.db "DIAGS  ",0
RELEASE:	.db "1.1    ",0
