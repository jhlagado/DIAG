; Graphical LCD 128 x 64 Library
; ------------------------------
; By B. Chiha May-2023
;
; This is a native Z80 Graphics library to be used with 128x64 Graphical LCD Screens
;
; There are a few variants of these LCD screens, but they must all must use the ST7920
; LCD Controller.  The LCD Screen that I used is the QC12864B.  This screen has two
; ST7921 Panels (128 x 32) stacked one above the other.
;
; These screens have DDRAM (Graphics) and CGRAM (Text) areas.  Both RAM areas can 
; be displayed at the same time.
;
; Initialise LCD
initLCD:
        LD HL, INIT_BASIC       ;POINT HL TO LCD INITIALIZE TABLE
        LD B, 04H               ;B=4 BYTES
NEXT_CMD:
        LD A, (HL)
        OUT (GLCD_INST), A
        CALL delayUS
        INC HL
        DJNZ NEXT_CMD
        LD DE, 0140H            ;1.6 ms
        CALL delayMS
        
        CALL clearGrLCD
        
; Clears the Graphics Memory Buffer
clearGBUF:
        LD HL, GBUF
        LD DE, GBUF + 1
        XOR A
        LD (HL), A
        LD BC, 03FFH
        LDIR
        RET
        
; Clears the Graphics LCD Buffer
clearGrLCD:
        CALL setGrMode
        LD C, 00H
CLR_X:
        LD A, 80H
        OR C
        OUT (GLCD_INST), A
        CALL delayUS
        LD A, 80H
        OUT (GLCD_INST), A
        CALL delayUS
        XOR A                   ;Clear Byte
        LD B, 10H
CLR_Y:
        OUT (GLCD_DATA), A
        CALL delayUS
        OUT (GLCD_DATA), A
        CALL delayUS
        DJNZ CLR_Y
        INC C
        LD A, C
        CP 20H
        JR NZ, CLR_X        
        RET

; Clears the ASCII Text LCD
clearTxtLCD:
        CALL setTxtMode
        LD A, 80H
        OUT (GLCD_INST), A
        CALL delayUS
        LD B, 40H
CLR_ROWS:
        LD A, ' '
        OUT (GLCD_DATA), A
        CALL delayUS
        DJNZ CLR_ROWS
        RET
        
; Set Graphics Mode
setGrMode:
        LD A, 34H
        OUT (GLCD_INST), A
        CALL delayUS
        LD A, 36H
        OUT (GLCD_INST), A
        JP delayUS

; Set Text Mode
setTxtMode:
        LD A, 30H
        OUT (GLCD_INST), A
        JP delayUS
        
;Draw Box
;Inputs: BC = X0,Y0
;        DE = X1,Y1
;Destroys: HL
drawBox:
        PUSH BC
TOP:
        CALL drawPixel
        LD A, D
        INC B
        CP B
        JR NC, TOP
        POP BC
        
        PUSH BC
        LD C, E
BOTTOM:
        CALL drawPixel
        LD A, D
        INC B
        CP B
        JR NC, BOTTOM
        POP BC
        
        PUSH BC
LEFT:
        CALL drawPixel
        LD A, E
        INC C
        CP C
        JR NC, LEFT
        POP BC
        
        PUSH BC
        LD B, D
RIGHT:
        CALL drawPixel
        LD A, E
        INC C
        CP C
        JR NC, RIGHT
        POP BC
        RET
        
;Fill Box
;Draws vertical lines from X0,Y0 to X0,Y1 and increase X0 to X1 until X0=X1
;Inputs: BC = X0,Y0
;        DE = X1,Y1
;Destroys: HL
fillBox:
        PUSH BC
NEXT_PIXEL:
        CALL drawPixel
        LD A, E
        INC C
        CP C
        JR NC, NEXT_PIXEL
        POP BC
        LD A, D
        INC B
        CP B
        JR NC, fillBox
        RET
        
;Draw a line between two points using Bresenham Line Algorithm
; void plotLine(int x0, int y0, int x1, int y1)
; {
;    int dx =  abs(x1-x0), sx = x0<x1 ? 1 : -1;
;    int dy = -abs(y1-y0), sy = y0<y1 ? 1 : -1;
;    int err = dx+dy, e2; /* error value e_xy */
        
;    for(;;){  /* loop */
;       setPixel(x0,y0);
;       if (x0==x1 && y0==y1) break;
;       e2 = 2*err;
;       if (e2 >= dy) { err += dy; x0 += sx; } /* e_xy+e_x > 0 */
;       if (e2 <= dx) { err += dx; y0 += sy; } /* e_xy+e_y < 0 */
;    }
; }
;Inputs: BC = X0,Y0
;        DE = X1,Y1
drawLine:
;check that points are in range
        LD A, C
        CP 40H
        RET NC
        LD A, B
        CP 80H
        RET NC
        LD A, E
        CP 40H
        RET NC
        LD A, D
        CP 80H
        RET NC
        
;sx = x0<x1 ? 1 : -1
        LD H, 01H
        LD A, B
        CP D
        JR C, $ + 4
        LD H, 0FFH
        LD A, H
        LD (SX), A
        
;sy = y0<y1 ? 1 : -1
        LD H, 01H
        LD A, C
        CP E
        JR C, $ + 4
        LD H, 0FFH
        LD A, H
        LD (SY), A
        
        ld (ENDPT), DE
        
;dx =  abs(x1-x0)
        PUSH BC
        LD L, D
        LD H, 0
        LD C, B
        LD B, 0
        OR A
        SBC HL, BC
        CALL ABSHL
        LD (DX), HL
        POP BC
        
;dy = -abs(y1-y0)
        PUSH BC
        LD L, E
        LD H, 0
        LD B, 0
        OR A
        SBC HL, BC
        CALL ABSHL
        XOR A
        SUB L
        LD L, A
        SBC A, A
        SUB H
        LD H, A
        LD (DY), HL
        POP BC
        
;err = dx+dy,
        LD DE, (DX)
        ADD HL, DE
        LD (ERR), HL
        
LINE_LOOP:
;setPixel(x0,y0)
        CALL drawPixel
        
;if (x0==x1 && y0==y1) break;
        LD A, (ENDPT + 1)
        CP B
        JR NZ, $ + 7
        LD A, (ENDPT)
        CP C
        RET Z
        
;e2 = 2*err;
        LD HL, (ERR)
        ADD HL, HL              ;E2
        
;if (e2 >= dy)  err += dy; x0 += sx;
        LD DE, (DY)
        OR A
        SBC HL, DE
        ADD HL, DE
        JP M, LL2
        
        PUSH HL
        LD HL, (ERR)
        ADD HL, DE
        LD (ERR), HL
        LD A, (SX)
        ADD A, B
        LD B, A
        POP HL
        
LL2:
;if (e2 <= dx)  err += dx; y0 += sy;
        LD DE, (DX)
        OR A
        SBC HL, DE
        ADD HL, DE
        JR Z, LL3
        JP P, LINE_LOOP
LL3:
        LD HL, (ERR)
        ADD HL, DE
        LD (ERR), HL
        LD A, (SY)
        ADD A, C
        LD C, A
        
        JR LINE_LOOP
        
ABSHL:
        BIT 7, H
        RET Z
        XOR A
        SUB L
        LD L, A
        SBC A, A
        SUB H
        LD H, A
        RET
        
;Draw a circle from a midpoint to a radius using Bresenham Line Algorithm
; void plotCircle(int xm, int ym, int r)
; {
;    int x = -r, y = 0, err = 2-2*r, i = 0; /* II. Quadrant */
;    printf("Midpoint = (%X,%X), Radius = %X\n", xm, ym, r);
;    do {
;       printf("(%X,%X) ", xm-x, ym+y); /*   I. Quadrant */
;       printf("(%X,%X) ", xm-y, ym-x); /*  II. Quadrant */
;       printf("(%X,%X) ", xm+x, ym-y); /* III. Quadrant */
;       printf("(%X,%X) ", xm+y, ym+x); /*  IV. Quadrant */
;       r = err;
;       if (r <= y) err += ++y*2+1;           /* e_xy+e_y < 0 */
;       if (r > x || err > y) err += ++x*2+1; /* e_xy+e_x > 0 or no 2nd y-step */
;       printf("x = %d, r = %d, y = %d, err =%d\n", x, r, y, err);
;    } while (x < 0);
; }
;Inputs BC = xm,ym (Midpoint)
;       E = radius
drawCircle:
;   int x = -r, err = 2-2*r; /* II. Quadrant */
        XOR A
        SUB E
        LD (SX), A              ;x
;   y = 0
        XOR A
        LD (SY), A              ;y
;   RAD = r
        LD D, 00H
        LD A, E
        LD (RAD), DE            ;r
;   err = 2-2*r
        EX DE, HL
        ADD HL, HL
        EX DE, HL
        LD HL, 0002H
        OR A
        SBC HL, DE              ;err
        LD (ERR), HL
        
CIRCLE_LOOP:
;       setPixel(xm-x, ym+y); /*   I. Quadrant */
        PUSH BC
        LD A, (SX)
        NEG
        ADD A, B
        LD B, A
        LD A, (SY)
        ADD A, C
        LD C, A
        CALL drawPixel
        POP BC
;       setPixel(xm+x, ym-y); /* III. Quadrant */
        PUSH BC
        LD A, (SX)
        ADD A, B
        LD B, A
        LD A, (SY)
        NEG
        ADD A, C
        LD C, A
        CALL drawPixel
        POP BC
;       setPixel(xm-y, ym-x); /*  II. Quadrant */
        PUSH BC
        LD A, (SY)
        NEG
        ADD A, B
        LD B, A
        LD A, (SX)
        NEG
        ADD A, C
        LD C, A
        CALL drawPixel
        POP BC
;       setPixel(xm+y, ym+x); /*  IV. Quadrant */
        PUSH BC
        LD A, (SY)
        ADD A, B
        LD B, A
        LD A, (SX)
        ADD A, C
        LD C, A
        CALL drawPixel
        POP BC
;       r = err;
        LD HL, (ERR)
        LD (RAD), HL
;       if (r <= y) err += ++y*2+1;           /* e_xy+e_y < 0 */
        LD A, (SY)
        LD E, A
        LD D, 0
        OR A
        SBC HL, DE
        ADD HL, DE
        JR Z, $ + 5
        JP P, DS1
        LD A, (SY)
        INC A
        LD (SY), A
        ADD A, A
        INC A
        LD E, A
        LD D, 0
        LD HL, (ERR)
        ADD HL, DE
        LD (ERR), HL
;       if (r > x || err > y) err += ++x*2+1; /* e_xy+e_x > 0 or no 2nd y-step */
DS1:
        LD HL, (RAD)
        LD A, (SX)
        LD D, 0FFH
        LD E, A
        OR A
        SBC HL, DE
        ADD HL, DE
        JR Z, $ + 5
        JP P, DS2
        LD HL, (ERR)
        LD A, (SY)
        LD D, 0
        LD E, A
        OR A
        SBC HL, DE
        ADD HL, DE
        JR Z, DS3
        JP M, DS3
DS2:
        LD A, (SX)
        INC A
        LD (SX), A
        ADD A, A
        INC A
        LD E, A
        LD D, 0FFH
        LD HL, (ERR)
        ADD HL, DE
        LD (ERR), HL
;   } while (x < 0);
DS3:
        LD A, (SX)
        OR A
        JP NZ, CIRCLE_LOOP
        RET
        
;Fill Circle
;Fills a circle by increasing radius until Radius = Original Radius E
;Inputs BC = xm,ym (Midpoint)
;       E = radius
fillCircle:
        LD D, 01H               ;Start radius
NEXT_CIRCLE:
        PUSH DE                 ;Save end Radius
        LD E, D
        CALL drawCircle
        POP DE                  ;Restore Radius
        LD A, E
        INC D
        CP D
        JR NC, NEXT_CIRCLE
        RET
        
;Draw Pixel in position X Y
;Input B = column/X (0-127), C = row/Y (0-63)
;destroys HL
drawPixel:
        LD A, C
        CP 40H
        RET NC
        LD A, B
        CP 80H
        RET NC
        
        PUSH DE
        CALL SET_GBUF

        LD A, D
        OR (HL)
        LD (HL), A
        POP DE
        RET

;Clear Pixel in position X Y
;Input B = column/X (0-127), C = row/Y (0-63)
;destroys HL
clearPixel:
        LD A, C
        CP 40H
        RET NC
        LD A, B
        CP 80H
        RET NC
        
        PUSH DE
        CALL SET_GBUF

        LD A, D
        CPL
        AND (HL)
        LD (HL), A
        POP DE
        RET

;Flip Pixel in position X Y
;Input B = column/X (0-127), C = row/Y (0-63)
;destroys HL
flipPixel:
        LD A, C
        CP 40H
        RET NC
        LD A, B
        CP 80H
        RET NC
        
        PUSH DE
        CALL SET_GBUF

        LD A, D
        XOR (HL)
        LD (HL), A
        POP DE
        RET

;Helper routine to set HL to the correct GBUF address given X and Y
;Input B = column/X (0-127), C = row/Y (0-63)
;Output HL = address of GBUF X,Y byte, D = Byte with Pixel Bit Set
;Destroys E
SET_GBUF:
        LD L, C
        LD H, 00H
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        ADD HL, HL
        LD DE, GBUF - 1
        ADD HL, DE
        
        LD A, B
        LD D, 08H
BASE_COL:
        INC HL
        SUB D
        JR NC, BASE_COL
        
        CPL
        LD D, 01H
        OR A
        RET Z
SHIFT_BIT:
        SLA D
        DEC A
        JR NZ, SHIFT_BIT
        RET

;Main draw routine.  Moves GBUF to LCD and clears buffer
;Destroys all
plotToLCD:
        LD HL, GBUF
        LD C, 80H
PLOT_ROW:
        LD A, C
        AND 9FH
        OUT (GLCD_INST), A      ;Vertical
        CALL delayUS        
        LD A, 80H
        BIT 5, C
        JR Z, $ + 4
        OR 08H
        OUT (GLCD_INST), A      ;Horizontal
        CALL delayUS        
        LD B, 10H               ;send eight double bytes (16 bytes)
PLOT_COLUMN:
        LD A, (HL)
        OUT (GLCD_DATA), A
        CALL delayUS
        LD A, (CLRBUF)
        OR A
        JR Z, $ + 4
        LD (HL), 00H            ;Clear Buffer if CLRBUF is non zero
        INC HL
        DJNZ PLOT_COLUMN
        INC C
        BIT 6, C                ;Is Row = 64?
        JR Z, PLOT_ROW
        RET
        
; Print ASCII text on a given row
; Inputs: C = 0 to 3 Row Number
;         DB "String" on next line, terminate with 0
; EG:
;   LD C,2
;   CALL printString
;   DB "This Text",0
;
printString:
        LD B, C
        CALL setTxtMode
        LD HL, ROWS
        LD A, B
        ADD A, L
        JR NC, $ + 3
        INC H
        LD L, A
        LD A, (HL)
        OUT (GLCD_INST), A
        CALL delayUS
        POP HL
DS_LOOP:
        LD A, (HL)
        INC HL
        OR A
        JR Z, DS_EXIT
        OUT (GLCD_DATA), A
        CALL delayUS
        JR DS_LOOP
DS_EXIT:
        JP (HL)
        
;Print Characters at a position X,Y
;Eventhough there are 16 columns, only every second column can be written
;to and two characters are to be printed.  IE: if you want to print one
;character in column 2, then you must set B=0 and print " x", putting
;a space before the chracter.
;Input B = column/X (0-7), C = row/Y (0-3)
;      HL = Start address of text to display, terminate with 0
printChars:
        CALL setTxtMode
        LD DE, ROWS
        LD A, C
        ADD A, E
        JR NC, $ + 3
        INC D
        LD E, A
        LD A, (DE)
        ADD A, B
        OUT (GLCD_INST), A
        CALL delayUS
PC_LOOP:
        LD A, (HL)
        INC HL
        OR A
        RET Z
        OUT (GLCD_DATA), A
        CALL delayUS
        JR PC_LOOP
        
; Delay for LCD write
delayUS:
        LD DE, V_DELAY_US       ;DELAY BETWEEN, was 0010H
delayMS:
        DEC DE                  ;EACH BYTE
        LD A, D                 ;AS PER
        OR E                    ;LCD MANUFACTER'S
        JR NZ, delayMS         ;INSTRUCTIONS
        RET
        
; Set Buffer Clearing after outputting to LCD
; Input: A = 0 Buffer to be cleared, A <> 0 Buffer kept
setBufClear:
        LD A, 0FFH
        LD (CLRBUF), A
        JP clearGBUF
        
setBufNoClear:
        XOR A
        LD (CLRBUF), A
        RET


