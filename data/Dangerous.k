4 2 8 6 0 5 4 6
11
0
1000
192
30
60
200
Most Dangerous Game by Peter Maruhnic. Pits a hunter against a hunted in a maze.  The hunter must shoot the hunted before either time runs out or the hunted escapes the maze. However, neither the hunted nor the hunter can see a wall in the maze until he runs into it.


=============================
10. VIP Most Dangerous Game

VIP Most Dangerous Game pits a hunter against a hunted in a maze.  The hunter must
shoot the hunted before either time runs out or the hunted escapes the maze.
However, neither the hunted nor the hunter can see a wall in the maze until he runs
into it.  There is always at least one path through the maze.

How To Play VIP Most Dangerous Game

1. Load the CHIP-8 interpretor at 0000-01FF
   and the game starting at 0200.

2. Turn RUN switch on.

3. Hunted's turn:
   When the arrow appears in the lower left, it is the hunted's turn.  Keys 2-4-6-8
   control direction (up-left-right-down, respectively).  The hunted continues to
   move until a) he makes 5 moves, b) he hits a wall or c) key 0 is pressed.

4. Hunter's turn
   When the arrow appears in the lower right, it is the hunter's turn.  The hunter's
   turn consists of two modes, the move and the shoot.  Keys 2-4-6-8 and 0 control both
   modes.  Like the hunted, the hunter continues to move until a) he makes 3 moves,
   b) he hits a wall or c) key 0 is pressed.  If he hits the wall, case b), he cannot
   fire a bullet.  The hunter may fire one of his bullets using the direction keys
   2-4-6-8.  The bullet will travel four squares in the corresponding direction, unless
   a wall is encountered.  If the hunter prefers not to use a bullet, he must press key 0.

5. Repeat steps 3 and 4 until:
   a) The number of turns (upper left on the display) expire.  The hunted wins.
   b) The hunter lands on or shoots the hunted.  The hunter wins.
   c) The hunted lands on hunter, thereby giving up.  The hunter wins.
   d) The hunted reaches the lower right corner of the maze with at least 1 move
      remaining in his turn.  The hunted wins, by escaping the maze.

6. Variations of VIP Most Dangerous Game may be played by changing certain bytes in
   the program.

Location Default Meaning
0215	 0F	 Number of turns in the game.
0217	 06	 Number of bullets hunter has at start.
0219	 03	 Number of moves per turn for the hunter.
0221	 01	 Number of squares per move (hunted and hunter).
022B	 05	 Number of moves per turn for the hunted.
024B	 01	 If zero, walls are invisible.
0355	 04	 Number of squares a bullet will go.
04E3	 70	 Probability (out of 100Hex) of a wall appearing.
04EB	 FE	 If FF, a wall may appear at previously tested boundaries.

===============================


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
