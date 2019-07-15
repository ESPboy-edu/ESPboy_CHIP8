3 10 6 12 10 10 3 12
14
5
0
195
30
60
200
Alien - by Jonas Lindstedt. Shoot the alien invaders.


Welcome to my second CHIP48 game ever. This time it uses the new features 
(i.e. scrolling and full-screen graphics) that were added in SUPER-CHIP V1.1.

The game
--------
Due to lack of imagination, I did a very wellknown game. Alien, one of the 
first games I played in the beginning of the C=64 era. It is a rather simple
shoot'em up game and the story behind the game is as follows: Unfriendly
(most aliens are) aliens have invaded the earth and the only one who can stop 
them are you. To assist you in your battle, the russian experts have 
developed a new powerful (and leathal) weapon, the blaster. But, as you
known, the Rubel isn't what it used to be and therefore, the scientists could 
only afford the version with limited firecapacity. You can only have one shot 
in the air at the same time. And what's even worse: the aliens have gotten 
hold of the very same weapon. And they're continually making their shields 
stronger and stronger. Stop them before they reach mother earth!

How to start the game
---------------------
Upload the game to your HP48-series calulcator via the serial cable. Make 
sure the you also have got S-CHIP V1.1 somewhere in your machine (otherwise 
you'll have to upload that too). Press the Alien menu-key and a string will 
appear in the first level of the stack (the only thing readable is my name). 
Then press the S-Chip menu-key and the game will begin. See next section for 
further description.

The controls
------------
KEY             DESCRIPTION

Enter           Restart the game
Backspace       Quit game (return to calculating, who needs that?!)
+/-             Toggle sound on/off (useful when teacher is near you)
9               Stear your blaster left
/               Stear your blaster right
0               Fire (you also use this key to begin playing)

Copyrights
----------
CHIP48 V2.25 (C) Andreas Gustafsson, Finland
S-CHIP V1.1 (C) Erik Bryntse, Sweden
ALIEN V1.0 (C) Jonas Lindstedt, Sweden

This game is released as Public Domain via Internet and various Bulletin
Board Systems. You may copy this program for non-profit purposes. I don't 
take any responsibility for any damage caused by this program, but please 
write me a letter if you find any bugs or have suggestions how to make this a 
better game. (I know it's a bit slow, but so am I.)
                                                
Enjoy!!

Jonas Lindstedt
Department of Real Time Computer Systems
Malardalens University, Vasteras, Sweden
-------------------------------------------
E-mail:         ltd92jlt@martin.mdh.se 
                 or              
                akcs.jonasl@hpcvbbs.cv.hp.com

Address:        Jonas Lindstedt
                Bergmastarv. 15
                S-724 78  VASTERAS
                Sweden




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
