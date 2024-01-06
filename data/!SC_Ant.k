3 10 10 12 10 10 3 12
14
2
100
227
30
60
200
ANT by Erin S Catto <catto@ecn.purdue.edu> 1991. In search of Coke. Your mission as Bink to find a safe path to the Coke can so that others may follow. Beware, however, for Zoom has set many treacherous obsticles to block you and booby traps to zap you.



(Comp.sys.handhelds)
Item: 3797 by catto at author.ecn.purdue.edu
Author: [Erin S Catto]
  Subj: Ant v1.0 Library for HP48sx
  Date: Fri Aug 02 1991


Ant v1.0, "In Search of Coke"
=============================

   Rumours through the grape vine of the local ant community indicate that
   there is a partially empty Coke can in Zoom's room.  So far many brave ants
   have gone in search of the mystic can, yet none have returned.  They are
   feared to be dead.  It is your mission as Bink to find a safe path to the
   Coke can so that others may follow.  Beware, however, for Zoom has set many
   treacherous obstacles to block you and booby traps to zap you.  Bink has
   only his cool nerves and jumping ability (the only jumping ant in the world)
   to help him on this journey.


What is: Ant v1.0 is a SCHIP v1.1 game contained in a library which includes
         SCHIP v1.1 and accessory programs written in System RPL.  SCHIP v1.1
         is accessible to run other games, such as H. Piper and Joust.

How:     Ant v1.0 was programmed using the Chipper assembler.  The System RPL
         bits were written using Hewlett Packard's System RPL compiler.
         Graphics and animation were developed on the HP48 using the graphics
         interface and User RPL.  The final directory containing the programs
         and GROBs was con- verted into a library using HP's PC based program
         USRLIB.EXE.

Play:    Enter the library menu.  Enter the Ant library.  Execute INFO.  Read
         the credits.  Press any key.  Read the key assignments.  Press any
         key.  Press BEEP (actually BEeP) menu key to toggle the RPL music.
         Press ANT to enter the title screen.  Press any key (except ATTN, will
         abort) to play the game.  Use the key assignments noted in the INFO
         program.

Using SCHIP:  Put your SCHIP program string into level one. Press SCHIP.
              You may want to put the SCHIP command in your CST menu.

Hints:    1) Pressing the jump key and the right key simultaneously will help
             clearing large obstacles.  Actually, press the jump key slightly
             ahead of the right key.  
          2) Being of little mass, Bink can stop on a dime and change course in
             mid-air at will.
          3) This game has no randomization.  Learn the terrain.

Credits:  1) Erik Bryntse:  SCHIP v1.1.
          2) Christian Egeberg:  Chipper Assembler v1.12.
          3) Andreas Gustafsson:  Original adaption of CHIP to the HP48
          4) I take full credit for the design and development of Ant v1.0.
             The game theme is original as far as I know.

Notice:   1) I take no blame for worn calculator keys.
          2) There are many tricks to getting around Ant v1.0.  Be aware of
             spoilers when posting to the net.
          3) Surprisingly only about 3.2 kbytes out of the 11 kbytes library
             are used by the SCHIP Ant game.  About 2.2 kbytes are taken by
             SCHIP.  It would not be unresonable for me to release an
             abreviated version if requests are given.
          4) Have fun and give me feedback.


                            Be an Ant,

                            Zoom
                            catto@ecn.purdue.edu

[Note: See also ANTMENU on this disk.  -jkh-]
 



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
