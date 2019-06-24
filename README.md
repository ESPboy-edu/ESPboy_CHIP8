ESPboy chip8/schip accurate emulator by RomanS based on ideas of Alvaro Alea Fernandez Chip-8 emulator.
================

Special thanks to Igor (corax69), DmitryL (Plague) and John Earnest (https://github.com/JohnEarnest/Octo) for help

Implemented almost all known features and "bugs"
Super Chip implementation is on the way )

Used information from
https://github.com/JohnEarnest/Octo
http://mattmik.com/chip8.html
https://github.com/Chromatophore/HP48-Superchip

The games should be with extantion ".ch8" as <gamename.ch8> To upload games to SPIFFS check. 
https://www.youtube.com/watch?v=25eLIdLKgHs

For correct compilation, change settings in file «User_Setup.h» of TFT_eSPI library
* 50 #define TFT_WIDTH 128
* 53 #define TFT_HEIGHT 128
* 67 #define ST7735_GREENTAB3
* 149 #define TFT_CS -1
* 150 #define TFT_DC PIN_D8
* 152 #define TFT_RST -1
* 224 #define LOAD_GLCD
* 255 #define SPI_FREQUENCY 27000000


You is able to make <gamename.k> configuration file and upload them to the SPIFFS togather with games.
It looks like simple txt file. Check below


The name of the configuration file should be the same as the game's name but with extention ".k" as <gamename.k>

```sh
4 2 8 6 5 11 4 6
13
0
1
67
30
60
200
Here could be description of the game about 300 symbols
```

<gamename.k> CONFIG FILE INSTRUCTIONS
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
1     2     3     C[13]
4     5     6     D[14]
7     8     9     E[15]
A[11] 0[10] B[12] F[16]

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

