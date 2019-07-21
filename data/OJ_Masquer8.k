1 2 3 4 15 10 4 6
15
12
1000
64
30
60
200
Masquer8by Chromatophore. https://github.com/Chromatophore. CHIP8 30.10.2015. Cuttlefish pattern matching game for chip8. Details: https://github.com/JohnEarnest/chip8Archive/tree/master/src/masquer8


===============================
Masquer8 is another submission for Octo-ber jam II: http://octojam.com/octojam-ii/games/masquer8 It's written for Octo, a high-level assembler for Chip 8, an 8 bit assembly language from the 1970s: https://github.com/JohnEarnest/Octo
Masquer8 is a game where you control Cammy Cuttlefish, a master of disguise.
!! Using V on the "Press Key" menu page will continue from the last level you were on !!
Blend in with your surroundings perfectly so that the Shark can't see you!
You have a HUD in the bottom right corner.
You start with access to Vertical Lines on keys 1-4. Every time you change your pattern, the shark will get slightly closer. There is an icon for the Shark in the HUD. If you can see its eyes, it's really close!
At any time, press V to try and blend in. If you're not quite a perfect match, you will lose a lot of time and the shark will get closer. You must be lined up both horizontally and vertically. This can be very hard with some patterns.
The HUD has an indicator that shows which patterns you have active. Try cycling them a little bit to see how it works. You can use this to work out how to get back to normal.
After a few levels you will unlock horizontal lines on keys Q-R.
After a few more, you will unlock Patterns mode, which is REALLY HARD. These are on keys A-F and Z to C. A pro tip to get started is that, remember these puzzles are only 2 or 3 layered patterns, so, find one you think must be involved and try toggling on other patterns.
If you get a game over, press V on the title screen (or just navigate all menus with V) to Continue from the level you were on.
The game has 10 levels.
After you get the ending screen, you will enter infinite mode, where you will be presented with random puzzles to match. In this mode, the Shark will ignore you. If you can't beat a puzzle, or get your camouflage in a muddle, mash V a bunch and it will give you a game over and allow you get a new puzzle.
You can press Z on the title screen to jump straight to infinite mode, also.
Infinite mode is really, really hard, and I often see a puzzle on it and go 'how the hell can you do that??', so, don't feel bad.
The game was designed to be playable even at 7 cycles / frame. It also has a loading screen where it generates all of the patterns for Cammy, instead of having to program them in yourself. This means that there's about 1K of 0s at the end of the code, which hopefully would have been easier to type in.
After going back and revising the game a little bit, I have managed to get the memory footprint to be under 3.2k, which hopefully means that this game would have been genuinely playable on original hardware.
====================================


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
