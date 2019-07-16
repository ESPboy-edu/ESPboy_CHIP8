7 3 6 8 14 15 14 15
0
18
700
72
30
60
200
SYZYGY2 by Roy Trevino. SCHIP, 30.10.1990. Seek out "targets" with your syzygy.  Initially small, the syzygy will grow by some amount each time a target is hit.


=================================
(Comp.sys.handhelds)
Item: 1014 by rtrevino at cpocd5.intel.com
Author: [Roy Trevino]
  Subj: syzygy v0.1 - a chip-48 game
  Date: Tue Oct 30 1990 10:54 

SYZYGY v0.1 for HP48SX using CHIP48

[Note: This game is run by the CHIP48 interpreter, found on the HORN1 disk
 from EduCALC.  I imagine this game as flying a BD-5J inside the Astrodome
 while leaving a contrail that is so violently turbulent that running into
 it causes instant death, but the goal is to fly through briefly visible
 air pockets that lengthen the contrail.  He who dies with the longest
 contrail wins! -jkh-]

One of the first games I remember playing on a computer was 
called "syzygy" on a now ancient TRS-80 Model 1.  It has since
appeared on other computers under various names.  Why it was
called syzygy, I have no idea (consult Websters).  However, since
the HP48SX has approximately the same memory, graphics and cpu
power as my TRS-80 did (something like 16kB, 128x64, and a 1.2Mhz Z80),
I thought it would be amusing to play it again.  Now, approximately
to my recollection, and with many apologies to the original author,
here is a CHIP48 version of SYZYGY for the HP48.  Enough drivel.

The object of the game is to seek out "targets".  You do this with
your syzygy.  Initially small, the syzygy will grow by some amount
each time a target is hit.  Eventually, your syzygy will
be so long as to make tougher and tougher to get any points (and easier
and easier to get killed).  Confused?  Just try it.

Anyways, the syzygy is not allowed to run into anything except targets.
It cannot run into the screen border (if present), or itself (this 
includes backing into itself).  Fast and immediate death will result.
Don't worry if you die quickly a few times.  The keys take a few 
minutes to get used to.

To start:     +      start/restart game with border
              -      start/restart borderless game
       
To play:      9      up
              6      down
              1      left
              2      right

[Hint for frustrated beginners: hold left hand on 1 & 2, and right hand on
 6 & 9 keys.  Alternate between left hand, right hand, left hand...  -jkh-]

After death:  SPC    display score, etc, then + or - to start

Chip48:       <-     chip48 exit (backspace key)
              +/-    chip48 toggle sound
              ENTER  chip48 restart game from beginning
       
Good luck!  (I realize the program is rather huge, but consider 
the price. :-)  The program works fine on my REV-D hp48sx under
CHIP-48 v2.25.  Source code may be posted if demand warrants.

Fine print (borrowed from Andreas Gustafsson, author of CHIP-48):

  SYZYGY is (c) copyright 1990 by Roy Trevino (RTT)

  Noncommercial distribution allowed, provided that this
  copyright message is preserved, and any modified versions
  are clearly marked as such.

  SYZYGY, via CHIP-48, makes use of undocumented low-level features
  of the HP48SX calculator, and may or may not cause loss of data,
  excessive battery drainage, and/or damage to the calcultor
  hardware.  The Author takes no responsibility whatsoever for
  any damage caused by the use of this program.
  
  THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE.

Roy

  --------------------------------------------------------------
  Roy Trevino                                        Intel Corp.
  E-mail: rtrevino@sedona.intel.com          Tel: (602) 554 2816
  UUCP:  decwrl!apple!oliveb!orc!inews!rtrevino@sedona.intel.com

==========================




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
