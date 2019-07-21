4 2 8 6 5 15 4 6
0
16
500
64
30
60
200
A magic square by David WINTER. SCHIP, 1997. The goal is to turn then BLACK by inverting their color, knowing that inverting the colour of a square will also invert these of the squares placed just on the left, right, up and down of it...


=================================
****************************************************************************
                     №яяя  №яяя№ џ   џ №яяя№ №яяя№ џяяяя
                      яяя№ џ  №я џ   џ џяяяџ џяџя  џяя
                      яяя   яя я  яяя  я   я я  я  яяяяя
                        A magic square in Super CHIP-8
                      (C)Copyright 1997 by David WINTER
****************************************************************************


       This game, as well as the others for this scene, are FREE
       and freely ditributable. If you paid to have it, you have
       been stolen. If you got money to give it, you're a thief.


       The rules of this game are very simple: the game is played
       in a variable size grid made of 3*3 to 8*8 squares, so the
       level of the game is designated by the width of the grid.
       Initially, all the squares of the grid are WHITE. The goal
       is to turn then BLACK by inverting their color, knowing
       that inverting the colour of a square will also invert these
       of the squares placed just on the left, right, up and down
       of it...
       Some levels are very simple: level 3 can be finished with
       only 5 inversions, and level 4 needs only 4 inversions to
       be completed...
       Once a level is completed, the game is finished. To play
       again, just reset the emulator.

       I know I could have implemented some sort of inversions
       counter, and next-level playing after a level is finished,
       but I missed some time to do this... Anyway, have fun !

       I could also have given the source of this program, but it
       is not documented, so it would not be interesting to those
       who are looking for help in programming.


       The keys are:
                   [8] :   UP
                   [4] :   LEFT (lower level under level selection)
                   [5] :   INVERT SQUARE (start game under level selection)
                   [6] :   RIGHT (upper level under level selection)
                   [2] :   DOWN
==========================




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
