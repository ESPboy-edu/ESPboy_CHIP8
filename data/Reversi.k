4 2 8 6 5 15 4 6
14
0
1000
64
30
60
200
Reversi by Philip Baltzer. CHIP8. Reversi is a game over 100 years old, which has become popular recently under the name Othello.


==================================
6. VIP REVERSI
Reversi is a game over 100 years old, which has become popular recently under the
name Othello.  The game is played on a 8x8 square, using two kinds of markers.
In VIP Reversi one player has the open markers and the other player the solid
markers.  The score for either player at any time is the total number of his markers
on the square.

How to play VIP Reversi

1. Load the CHIP-8 interpretor at 0000-01FF
   and the game starting at 0200.

2. Turn RUN switch on.

3. The 8x8 square will be formed and the starting marker configuration shown, having
   two of each kind of marker in the center four locations of the square.  The starting
   score for each player is shown as 02 above a line of his markers.

4. Your VIP indicates the player's turn by blinking that player's score and also blinking
   a cursor dot in the 8x8 square.  A player moves the blinking cursor dot in the 8x8
   square by pressing the direction keys 1-4 and 6-9 as shown. (VIPG1-6.JPG)

5. When the cursor-dot is properly located, the player presses key 5 to place his marker
   on the square.  You will find that your VIP will not allow you to make a non-valid
   play.  The only placements allowed are onces for which at least one of the other
   player's markers is surrounded between an existing marker of your own and your new
   marker being placed.  All these markers must be in consecutive positions on the
   square and can be in any horizontal, vertical or diagonal direction.  Once a new
   marker has been placed, your VIP will change all such surrounded markers of the
   other player to your kind and change the scores.

6. Sometimes it may not be possible for a player to make a valid move.  If this happens
   he must forfeit his move by pressing the "F" key! The game ends when neither player
   can play or when the 8x8 square is completely filled with markers.  The goal is to
   end the game with the highest score.  Do not be discouraged if during the game you
   seem to be losing because this is a game with dramatic reversals!  Develop a winning
   strategem and become a champion!!
===================================




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

0x1E ADI I = I + VX. SET reg I OVERFLOW BIT IN reg VF OR NOT
bit9 = 1 set VF=1 in case of I ovelflow, overwise VF=0
bit9 = 0 VX stay unchanged after oveflowing reg I operation I = I + VX 

*/

for example for AstroDodge game should be set as (binary)01000011 = (decimal)67


6. Quantity of opcodes runs till screen update. Works if you don't use TFT_DRAW bit7 of COMPATIBILITY FLAGS

7. TIMERS FREQUENCY
Setting up the frequency of CHIP8 timers. Standart is 60Hz

8. SOUND TONE
the freq tone of sound

9. GAME INFO
write 314 symbols of information you'll see before the game starts
