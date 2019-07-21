7 8 14 9 14 12 7 8
14
1
0
67
30
60
200
UBoat by Michael D. Kemper. SCHIP, 1994. Sink the submarines. The premise of the game is fairly simple. You are the Captain of a sub hunting destroyer, and your objective is to sink as many enemy U-Boats as you can. Your only weapon against the U-Boats is your ship’s supply of depth charges.


============================
 Subject:  U-BOAT v1.0  (c)1994 Michael D. Kemper
Released:  v1.0 - 8/8/94
Requires:  S-CHIP interpreter which can be found on Joseph Horn's
           goodies disk 3.

This game is based on a game that I used to play back in the early 80's
on an Apple ][.  I believe the name of the program was "Depth Charge."
Unfortunately I don't know who was responsible for programming it.

The premise of the game is fairly simple.  You are the Captain of a sub
hunting destroyer, and your objective is to sink as many enemy U-Boats as
you can.  Your only weapon against the U-Boats is your ship's supply of
depth charges.  You have an unlimited supply of charges but, due to the
amount of time it takes your second rate crew to reload, you may only have
four charges in the water at any given time.

The subs that you are hunting appear at random depths and have one of
three random velocities (stopped, ahead half, or ahead full).
There are six enemy subs visible at any one time.  When one of these
subs is destroyed, another will appear at a different location.

The keys used are as follows:

     [1]     ship's speed full stop
     [2]     ship's speed ahead half
     [3]     ship's speed ahead full
     [-]     drop depth charge
     [/]     abort game
     [+/-]   toggle sound
     [<-]    exit program
     [Enter] restart program

Scoring for the game is based on the depth of the sub, multiplied by one
plus it's velocity.  For example:
If a sub is at a depth of 50, and he is stopped then he is worth 50 points.
A sub at the same depth of 50, but moving at 1/2 speed is worth 100 points.
A sub at a depth of 50, but moving at full speed is worth 150 points.

The time limit for the game is about 2.5 minutes.  At about 1:45 into the
game a warning buzzer goes off and an almost empty hourglass is displayed
by your score to let you know that the game is about over.

Once the game is over your score, the high score, the number of charges
dropped, the number of subs hit, and your hit percentage are displayed.

A good game is about 2800 or so, and a really good game is around 3500.  I
haven't had a whole lot of time to play it, but my high is 3551.

----------------------------------------------------------------------------

Thanks to Erik Bryntse for his S-CHIP interpreter, which was an extension
to Andreas Gustafsson's CHIP-48 interpreter.  Thanks also to Christian
Egeberg for his CHIPPER v2.11 assembler.  A big thanks to Joseph Horn for
collecting various HP48 programs and utilities.  His goodies files are just
about my only source of information on this fascinating calculator.

If there are any questions, comments or criticism's they can be emailed
to mikek@access.mountain.net

This game is freeware, and may be distributed freely as long as this doc
file remains with it, and both the doc and program remain unchanged.  If
you find that you become wildly addicted to U-BOAT and can't sleep at
night knowing that I didn't receive any compensation for writing it then
by all means send me enough to allow you to get your z's.

============================================================================
Disclaimer:
     This program uses "Super-Chip" which makes use of undocumented
     low-level features of the HP48 calculator, and may or may not
     cause loss of data, excessive battery drainage, and/or damage to
     the calculator hardware.  The author takes no responsibility
     whatsoever for any damage caused by the use of this program.
============================================================================\

=======================



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
A[10] 0[0]  B[11]   F[15]

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
