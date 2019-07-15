4 2 8 6 5 11 4 6
13
5
200
67
30
60
200
AstroDodge by Martijn Wenting / Revival Studios. CHIP8-HIERES (C) 18.12.2008. www.revival-studios.com Your goal is to make your way through the asteroids field and dodge the asteroids, scoring points for each asteroid you are able to dodge.


-----------------------------------------------------------------------------
			      /////////////////
	                      //////////////////
        	              ////          ////
	               	      ////   ///////////
	                      ////  ///////////
                              ////  ////
                              ////  ///////////
                              ////   //////////
  	     	   	
  			   www.revival-studios.com
-----------------------------------------------------------------------------
Title		:	Astro Dodge
Author		:	Martijn Wenting / Revival Studios
Genre		:	Game
System		:	Chip8 / SuperChip8
Date		:	18/12/2008
Product ID	:	RS-C8003
-----------------------------------------------------------------------------

All the contents of this package are (c)Copyright 2008 Revival Studios.

The contents of the package may only be spread in its original form, and may not be
published or distributed otherwise without the written permission of the authors.

Description:
------------
Astro Dodge is an arcade game for the Chip8 and SuperChip8 systems.
Both versions of the game are included in this package.
 
Your goal is to make your way through the asteroids field and dodge the asteroids, scoring points for each asteroid you are able to dodge.
Button 2,4,6,8 will move your ship, button 5 will start the game.

Running the game(s):
--------------------
The CHIP8 version of the game has been programmed to be compatible with original hardware like the Cosmac VIP and Telmac 1800.
Use the Megachip emulator or any other Chip8/SuperChip compatible emulator to run the game(s).

Credits:
--------
Programming and Graphics by: Martijn Wenting

Distribution:
-------------
This package can be freely distributed in its original form.
If you would like to include this game in your rom package, please let me know.

Watch out for more releases soon!


	Martijn Wenting / Revival Studios




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
