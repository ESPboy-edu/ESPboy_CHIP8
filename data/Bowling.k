1 2 7 3 8 9 5 0
14
0
1000
64
30
60
200
VIP Bowling by Gooitzen van der Wal is a great game for recreation and competion requiring skill and a little bit of luck.  This program simulates bowling closely with regular scoring and the option of using three different spins on the ball.


=========================
7. VIP Bowling

Bowling is a great game for recreation and competion requiring skill and a little
bit of luck.  This program simulates bowling closely with regular scoring and the
option of using three different spins on the ball.

How to play VIP Bowling

1. Load the CHIP-8 interpretor at 0000-01FF
   and the game starting at 0200.

2. Turn RUN switch on.

3. Up to 6 persons can compete.  Make the choice by pressing Key 1,2,3,4,5 or 6.
   The players will be referred to as A,B,C,D,E and F.

4. It is possible to play up to 10 frames in one game.  Make your choice of the
   number of frames by pressing Key 1,2,3,4,5,6,7,8,9 or 0 (for 10 frames).

5. It is possible to choose 3 ball speeds (Key 1,2 or 3).  The speed option only
   affects the ball after it is released.

6. At the start of a player's turn, the video will display whose turn it is and
   whether he is working on a spare, strike, 2 strikes or nothing.
   Release the ball by pressing on of the following keys: Key 1,2,3,5,7,8 or 9.
   -Key 5 will cause a straight ball.
   -Key 1,2 and 3 will cause the ball to spin up.
     -Key 1 before the first pin
     -Key 2 after  the first pin
     -Key 3 after  the second pin
   -Key 7,8 and 9 will cause the ball to spin up.
     -Key 7 before the first pin
     -Key 8 after  the first pin
     -Key 9 after  the second pin

7. After the player's turn ends, the video will display whose turn it was, the
   frame, and the score.  The next players follows the instructions at 6 above.

8. After all players have had their turn in a frame, the video will display the
   total of each player and whether he is working on a spare, 1 strike, 2 strikes
   or nothing.  It will display the frame number and the total number of frames
   to go (unless the last frame was played).
   After pressing Any key, player A can start in the next frame.  Continue with
   instruction 6 above.

9. If all frames in the game have been finished, press any key again.  The player's
   who are still working on a spare will recieve 1 more ball, and those working
   on 1 or 2 strikes will receive 2 balls.

10. After all players have finished the game, the final score will be displayed.

===========================



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
