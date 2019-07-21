# ESPboy chip8/hires/schip emulator by RomanS

```sh
Special thanks to:
- Igor (corax89) https://github.com/corax89
-  DmitryL (Plague) https://github.com/PlagueRus
- John Earnest https://github.com/JohnEarnest/Octo 
and Alvaro Alea Fernandez https://github.com/alvaroalea for his Chip-8 emulator 
```

Implemented all known quirks to provide wide compatibility

Used information from
https://github.com/JohnEarnest/Octo
http://mattmik.com/chip8.html
https://github.com/Chromatophore/HP48-Superchip

The games should be with extention ".ch8" as <gamename.ch8> 
To upload games to SPIFFS check: https://www.youtube.com/watch?v=25eLIdLKgHs

For correct compilation, change settings in file «User_Setup.h» of TFT_eSPI library
* 50 #define TFT_WIDTH 128
* 53 #define TFT_HEIGHT 128
* 67 #define ST7735_GREENTAB3
* 149 #define TFT_CS -1
* 150 #define TFT_DC PIN_D8
* 152 #define TFT_RST -1
* 224 #define LOAD_GLCD
* 255 #define SPI_FREQUENCY 27000000

## GAMENAME PREFIXES:
- SC – super chip game
- OJ – OCTO JAM game https://johnearnest.github.io/chip8Archive/
- ! – recommended for play game
- D – playable demo, not completed game
- HR – hires game

## CHIP8 GAMES in this package

| Game | Author
| ------ | ------
| Airplane |
| Animal Race | Brian Astle
| Astro Dodge | Martijn Wenting / Revival Studios
| Blinky | Hans Christian Egeberg
| Blitz	| David Winter
| Bowling | Gooitzen van der Wal
| Breakout (Brix hack) | David Winter
| Breakout | Carmelo Cortez
| Brick (Brix hack) |
| Brix | Andreas Gustafsson
| Cave |
| Connect 4 | David Winter
| Deflection | John Fort
| Guess | David Winter
| Hidden | David Winter
| Landing |
| Lunar Lander |
| Mastermind | Robert Lindley
| Merlin | David Winter
| Missile | David Winter
| Most Dangerous Game | Peter Maruhnic
| NIM | Carmelo Cortez
| Paddles |
| Pong (1 player) | 
| Pong 2 (Pong hack) | David Winter
| Pong | Paul Vervalin
| Reversi | Philip Baltzer
| Rocket Launch | Jonas Lindstedt
| Rocket |
| Rush Hour |
| Shooting Stars | Philip Baltzer |
| Slide | Joyce Weisbecker
| Soccer |
| Space Flight |
| Space Invaders | David Winter
| Squash | David Winter
| Syzygy | Roy Trevino
| Tank |
| Tapeworm | JDR
| Tetris | Fran Dachille
| TicTacToe | David Winter
| Timebomb |
| UFO |
| Vertical Brix | Paul Robson
| Wall | David Winter
| Wipe Off | Joseph Weisbecker
| WormV4 | Martijn Wenting / Revival Studios

## HIRES GAMES in this package
| Game | Author
| ------ | ------
|Astro Dodge| Martijn Wenting / Revival Studios
|WormV4| Martijn Wenting / Revival Studios

## SUPER CHIP GAMES in this package
| Game | Author
| ------ | ------
| Alien | Jonas Lindstedt
| Ant  In Search of Coke | Erin S. Catto
| Astro Dodge| Martijn Wenting / Revival Studios
| Blinky | Hans Christian Egeberg
| Car | Klaus von Sengbusch
| Field! | Al Roland
| H.Piper | Paul Raines
| Joust | Erin S. Catto
| Loopz | Andreas Daumann
| Magic Square | David Winter
| Mines!  The minehunter | David Winter
| Sokoban | hap
| Spacefight 2091 | Carsten Soerensen
| UBoat | Michael Kemper
| WormV3 | RB
| WormV4 | Martijn Wenting

## OCTO JAM GAMES 
https://johnearnest.github.io/chip8Archive/

| Game | Author
| ------ | ------
| RPS | SystemLogoff
| Octo: a Chip 8 Story | SystemLogoff
| Pumpkin "Dreess" Up | SystemLogoff
| Rockto | SupSuper
| Flight Runner | TodPunk
| Turnover '77 |				
| Ultimate Tictactoe |
| Super Square | tann
| Eaty The Alien | JohnEarnest
| Octopeg | Chromatophore
| Masquer8 | Chromatophore
| Fuse | JohnEarnest
| Black Rainbow	| JohnEarnest
| 8CE Attourny  Disc 1, 2, 3 | SystemLogoff
| DVN8 | SystemLogoff
| SubTerr8nia |
| Slippery Slope | JohnEarnest
| Octo Rancher | SystemLogoff
| Tank!	| Rectus
| Carbon8 | Chromatophore
| ChipWar | JohnEarnest
| Cave Explorer	| JohnEarnest
| Outlaw | JohnEarnest
| Bad Kaiju Ju | MattBooth
| Piper	| Aeris, JordanMecom, LillianWang


## Tested games are not in this package due to numerous keys using or something else 
| Game | Author
| ------ | ------
| Bingo | Andrew Modla (hybrid)
| Blockout | Steve Houkx
| 15 Puzzle | Roger Ivie
| Biorhythm | Jef Winsor
| Blackjack | Andrew Modla (hybrid)
| Craps |
| Figures |
| Filter |
| Fishie | hap
| Pinball | Andrew Modla (hybrid)
| Programmable Spacefighters | Jef Winsor
| Puzzle |
| Robot |
| Sequence Shoot | Joyce Weisbecker
| Spooky Spot | Joseph Weisbecker
| Sum Fun | Joyce Weisbecker
| Tron |
| Video Display Drawing Game | Joseph Weisbecker (hybrid)
| Addition Problems | Paul C. Moews
| Bounce | Les Harris
| Robot |
| Worms |
| Car Race Demo | Erik Bryntse
| Single Dragon (Bomber Section) | David Nurser
| Single Dragon (Stages 12) | David Nurser
| XMirror |
| Sens8tion	| Chromatophore
| Grad School Simulator 2014 | JohnEarnest
| Loopz | Andreas Daumann
| Matches |
| Syzygy2 |

# CONFIG FILE 
You is able to make <gamename.k> configuration files and upload them to the SPIFFS togather with games.
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

# CONFIG FILE <gamename.k> INSTRUCTIONS
It's important not to change layout of first 9 lines of this file.
- key mapping separated by spaces
- foreground color
- background color
- delay
- compatibility flags
- quantity of opcodes run before TFT updates
- timers frequency
- sound tone frequency
- .ch8 file description about 300 symbols


### 1. KEY MAPPING
first line is the list of chi8 keys separated with spaces corresponded to ESPboy keys

ESPboy keys
0-LEFT, 1-UP, 2-DOWN, 3-RIGHT, 4-ACT, 5-ESC, 6-LFT side button, 7-RGT side button

```sh
Chip8 keys
>1     2     3     C[12]
>4     5     6     D[13]
>7     8     9     E[14]
>A[10] 0[0] B[11]  F[15]
```

### 2. FOREGROUND COLOR
no of color according to the list  
0-BLACK  1-NAVY  2-DARKGREEN  3-DARKCYAN  4-MAROON 
5-PURPLE  6-OLIVE  7-LIGHTGREY  8-DARKGREY  9-BLUE  
10-GREEN  11-CYAN  12-RED  13-MAGENTA  14-YELLOW
15-WHITE  16-ORANGE  17-GREENYELLOW  18-PINK

### 3. BACKGROUND COLOR
no of color according to the same list 

### 4. DELAY
delay in microseconds before each instruction

### 5. COMPATIBILITY FLAGS
are used to turn on/off few emulator tricks
details https://github.com/Chromatophore/HP48-Superchip


>8XY6/8XYE opcode
Bit shifts a register by 1, VIP: shifts rY by one and places in rX, SCHIP: ignores rY field, shifts existing value in rX.
bit1 = 1    <<= amd >>= takes vx, shifts, puts to vx, ignore vy
bit1 = 0    <<= and >>= takes vy, shifts, puts to vx

>FX55/FX65 opcode
Saves/Loads registers up to X at I pointer - VIP: increases I by X, SCHIP: I remains static.
bit2 = 1    load and store operations leave i unchaged
bit2 = 0    I is set to I + X + 1 after operation

>8XY4/8XY5/8XY7/ ??8XY6??and??8XYE??
bit3 = 1    arithmetic results write to vf after status flag
bit3 = 0    vf write only status flag


>DXYN
bit4 = 1    wrapping sprites
bit4 = 0    clip sprites at screen edges instead of wrapping

>BNNN (aka jump0)
Sets PC to address NNN + v0 - VIP: correctly jumps based on value in v0. SCHIP: also uses highest nibble of address to select register, instead of v0 (high nibble pulls double duty). Effectively, making it jumpN where target memory address is N##. Very awkward quirk.
bit5 = 1    Jump to CurrentAddress+NN ;4 high bits of target address determines the offset register of jump0 instead of v0.
bit5 = 0    Jump to address NNN+V0

>DXYN check bit 8
bit6 = 1    drawsprite returns number of collised rows of the sprite + rows out of the screen lines of the sprite (check for bit8)
bit6 = 0    drawsprite returns 1 if collision/s and 0 if no collision/s

>EMULATOR TFT DRAW
bit7 = 1    draw to TFT just after changing pixel by drawsprite() not on timer
bit7 = 0    redraw all TFT from display on timer

>DXYN OUT OF SCREEN check bit 6
bit8 = 1    drawsprite does not add "number of out of the screen lines of the sprite" in returned value 
bit8 = 0    drawsprite add "number of out of the screen lines of the sprite" in returned value 

>0x1E ADI I = I + VX. SET reg I OVERFLOW BIT IN reg VF OR NOT
bit9 = 1 set VF=1 in case of I ovelflow, overwise VF=0
bit9 = 0 VX stay unchanged after oveflowing reg I operation I = I + VX 


for example for AstroDodge game should be set as (binary)01000011 = (decimal)67 

### 6. Quantity of opcodes 
Quantity of opcodes runs till screen update. Works if you don't use TFT_DRAW bit7 of COMPATIBILITY FLAGS

### 7. TIMERS FREQUENCY
Setting up the frequency of CHIP8 timers. Standart is 60Hz

### 8. SOUND TONE
the freq tone of sound

### 9. GAME INFO
write 314 symbols of information you'll see before the game starts 

