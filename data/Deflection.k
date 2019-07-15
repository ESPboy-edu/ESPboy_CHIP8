4 2 8 6 5 0 3 1
15
0
1000
195
30
60
200
Deflection by John Fort. CHIP8. Position up to 10 mirrors on the display screen. The object of the game is to deflect a ball of the mirrors a maximum number of times before hitting the target.


=====================
8.  VIP DEFLECTION

In the VIP Deflection game you position mirrors anywhere on the display screen.
The object of the game is to deflect a ball of the mirrors a maximum number of
times before hitting the target.

The number of deflections times the target number gives you deflection points.
These are added to your previous point total.  If you fail to hit the target you
get no points.  The winner of the game is the player who accumulates 257 or
more deflected points.

How to Play VIP Deflection

1. Load the CHIP-8 interpretor at 0000-01FF
   and the game starting at 0200.

2. Turn RUN switch on.

3. After the scores appear a letter, the target with a number and a ball.  The
   letter signifies the player who will program the mirrors.  This sequence will
   be repeated until there is a winner.

4. To program the mirrors, select the proper mirror type by using Table 1 (VIP1-8.jpg)
   as a guide.  Key 1 will place a horizontal mirror on the board.  Key 2 selects a
   vertical mirror, Key 3 a slant-left mirror, Key 4 a slant-right mirror.

5. After a mirror has been selected, you may position the mirror by using keys 1
   through 4 and 6 through 9 (see Table 2 for movement of a mirror).  Once a
   mirror has been selected and positioned, it may be fixed into position by pressing
   Key 5.

   Table 2 - Mirror Positioning and Ball Direction
   Key Selection     |  Positioning and Direction
   ------------------+---------------------------
         1           |  up and to the left
         2           |  up
         3           |  up and to the right
         4           |  left
         5           |  right
         7           |  down and to the left
         8           |  down
         9           |  down and to the right

6. You may position up to 10 mirrors on the game board.  After you have the maximum
   amount on the board you must press Key 0 to progress to the fire mode.  If you
   wish to progress to the fire mode with less than 10 mirrors programmed, you may
   do so by pressing Key 0.  You fire the ball in the direction you want by using
   Keys 1 through 4 and Keys 6 through 9 (see Table 2).

7. After the ball has reached the target or leaves the game board, the player's
   score is computed and displayed and a new ball and target appear.
========================




//INSTRUCTIONS
It's important not to change layout of first 9 lines of this file.
- key mapping separated by spaces
- foreground color
- background color
- delay
- compatibility flags
- quantity of opcodes run before TFT updates
- timers frequency
- sound tone frequency
- .ch8 file description


1. KEY MAPPING
first line is the list of chi8 keys separated with spaces corresponded to ESPboy keys

ESPboy keys
0-LEFT, 1-UP, 2-DOWN, 3-RIGHT, 4-ACT, 5-ESC, 6-LFT side button, 7-RGT side button

Chip8 keys
1     2     3       C[12]
4     5     6       D[13]
7     8     9       E[14]
A[10] 0[0]   B[11]  F[15]

2. FOREGROUND COLOR
no of color according to the list
0-BLACK  1-NAVY  2-DARKGREEN  3-DARKCYAN  4-MAROON
5-PURPLE  6-OLIVE  7-LIGHTGREY  8-DARKGREY  9-BLUE
10-GREEN  11-CYAN  12-RED  13-MAGENTA  14-YELLOW
15-WHITE  16-ORANGE  17-GREENYELLOW  18-PINK

3. BACKGROUND COLOR
no of color according to the same list

4. DELAY
delay in microseconds before each instruction

5. COMPATIBILITY FLAGS
are used to turn on/off few emulator tricks
details https://github.com/Chromatophore/HP48-Superchip

8XY6/8XYE opcode
Bit shifts a register by 1, VIP: shifts rY by one and places in rX, SCHIP: ignores rY field, shifts existing value in rX.
bit1 = 1    <<= amd >>= takes vx, shifts, puts to vx, ignore vy
bit1 = 0    <<= and >>= takes vy, shifts, puts to vx

FX55/FX65 opcode
Saves/Loads registers up to X at I pointer - VIP: increases I by X, SCHIP: I remains static.
bit2 = 1    load and store operations leave i unchaged
bit2 = 0    I is set to I + X + 1 after operation

8XY4/8XY5/8XY7/ ??8XY6??and??8XYE??
bit3 = 1    arithmetic results write to vf after status flag
bit3 = 0    vf write only status flag

DXYN
bit4 = 1    wrapping sprites
bit4 = 0    clip sprites at screen edges instead of wrapping

BNNN (aka jump0)
Sets PC to address NNN + v0 - VIP: correctly jumps based on value in v0. SCHIP: also uses highest nibble of address to select register, instead of v0 (high nibble pulls double duty). Effectively, making it jumpN where target memory address is N##. Very awkward quirk.
bit5 = 1    Jump to CurrentAddress+NN ;4 high bits of target address determines the offset register of jump0 instead of v0.
bit5 = 0    Jump to address NNN+V0

DXYN check bit 8
bit6 = 1    drawsprite returns number of collised rows of the sprite + rows out of the screen lines of the sprite (check for bit8)
bit6 = 0    drawsprite returns 1 if collision/s and 0 if no collision/s

EMULATOR TFT DRAW
bit7 = 1    draw to TFT just after changing pixel by drawsprite() not on timer
bit7 = 0    redraw all TFT from display on timer

DXYN OUT OF SCREEN check bit 6
bit8 = 1    drawsprite does not add "number of out of the screen lines of the sprite" in returned value
bit8 = 0    drawsprite add "number of out of the screen lines of the sprite" in returned value
*/

for example for AstroDodge game should be set as (binary)01000011 = (decimal)67


6. Quantity of opcodes runs till screen update. Works if you don't use TFT_DRAW bit7 of COMPATIBILITY FLAGS

7. TIMERS FREQUENCY
Setting up the frequency of CHIP8 timers. Standart is 60Hz

8. SOUND TONE
the freq tone of sound

9. GAME INFO
write 314 symbols of information you'll see before the game starts
