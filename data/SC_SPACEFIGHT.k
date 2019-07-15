3 10 10 12 10 10 3 12
10
5
0
67
30
60
200
Space Fight by Carsten Soerensen <u920659@daimi.aau.dk>, 1992. Space invaders clone.


===============================
							Aarhus, DK
							16/9-92


SpaceFight2091  - The doc

Ok, here's a little Super-Chip game for all you mad S-Chip-freaks out there!




PURPOSE:

The purpose of the game is.... TO WIN (say what?)
  In order to complete this quite difficult task your body (yes only your body
and not your mind (this remark shows that I believe that the body merely serves
as a tool for the brain)) have been warped through 87 different time-warps
due to some foolish scientists who didn't know what they were doing. This
resulted in a rather big waste of resources but that's of course another story.
When you finally arrive you can't recognize anything and two weird-looking
dudes tell you that this is the year 2091!!! Frightening eh?
  You are of course not very happy about your situation partly because you only
have 25 dollars in your wallet and the prizes have gone up about 30000% but
mainly because IBM and the fucking PC clones have completely taken over all of
the computer-market resulting in the Amiga's death!
  In a Holo-BiDirectional-FullDuplex-TV-store you see a newsflash concerning
some evil aliens about to invade the good ol' EARTH. Scientists think that they
are being drawn towards the Earth due to the massive pollution the PC's cause.
However if people had bought Amiga's instead (which don't pollute) they would
have been no aliens now!
  This is your call! You sneak into a Warp-Transporter without a ticket and you
end up at NASA where you get to talk to the boss and you tell him : "OK you
listen to me you scumbag! I wanna get into a spacecraft, get up there and KICK
SOME ALIEN BUTT!". "But why?" the boss says. "Personal motives" you answer. If
you can save the Amigas existence you're ready to do anything!
  You get the newest spacecraft (ZX-81) and you take off!!! TO SAVE THE AMIGA!
  Battle you way through the 6 (increasingly harder) levels!!!




CONTROLLING THE ZX-81

  Though being very advanced the ZX-81 is extremely easy to control:

  HexPad    Amiga    HP    Function

    3         /      9      LEFT
    C         *      /      RIGHT
    A         1      0      FIRE




ABOUT THE GAME

  It was written because I wanted to test my newly written S-Chip assembler for
the Amiga. It only took me 2 days to make this game (I'm so proud of myself!).
I know that some of the code could have been programmed smarter (or smaller!)
but then again it was my first attempt so get off my back!

  SourceSize: about 30 k
  AsmSize:    2840 bytes
  783 bytes of graphics and 200 bytes of buffers, reducing the codesize to
  1857 bytes

Contact me for anything concerning CHIP like ideas for more games...

Slammer
Carsten Soerensen
Kronhjortevej 4
DK-8270  Hoejbjerg
Denmark

E-Mail: u920659@daimi.aau.dk
=================================




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
