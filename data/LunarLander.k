4 1 2 6 2 3 5 6
18
0
2000
200
30
60
200
LunarLander by Udo Pernisz, 1979. You are descending to the floor of a 250-foot crater. Opt1: start at 250 feet, 150 pounds of fuel.  Land at 5 feet per second or less!  Opt2: Start at 250 feet, 200 pounds of fuel.  Land at 3 feet per second or less! Opt3: Start at 32 feet, 100 pounds of fuel.  Land at 3 feet per second or less.


=========================
15. Lunar Lander

You are descending to the floor of a 250-foot crater.  The right side of the TV display
shows amount of fuel, feet from bottom and fall rate per cycle.  Lenght of fall rate
cycle changes from about 1/4 second to one second.  The fall rate increases by one
foot per second/per cycle.  The computer will update the display only at the end of
each cycle.

The left side of the display shows the Lunar Lander descending from 250 feet.  The
Lander will first appear at one of sixteen locations.  It will then slowly drop down
the crater.  The crater walls have rock formations protruding from them which must
be avoided.  If either rocket motor should touch any part of the crater, the Lander
will explode in a cloud of smoke and disintegrate.  (Remember, these are atomic
thrusters and react like miniature atomic bombs upon impact).

When you reach 32 feet, the display will change, and you will see the crater floor.
You must now ladn between the rock formations on the floo and maintain a minimum fall
rate.  As you drop your fall rate to zero, you soon discover that the Lander becomes
more and more unstable just as any hovering object would.  And now with perfect skill
you guide the ship in for a perfect touch down, or?

How to Play VIP Lunar Lander

1. Load the CHIP-8 interpreter at 0000-01FF and teh game starting at 0200.

2. Key 2 controls the thrust of the Lunar Lander.  One tone beep equals one pound
   of fuel and one foot of thrust.

3. Key 4 controlls the horizontal stabilizing engine,  and moves the Lander one
   foot to the left per one pound of fuel.

4. Key 6 controls the stabilization to the right.

5. Stabilization controls only react after: (a) a complete fall cycle, or (b) after
   the Key 2 thrust control is pressed.  You must be aware of this at all times or
   you will crash even though either key 4 or 6 is pressed.

6. At the end of each cycle, the Lunar Lander will move randomly at the rate of one
   foot either right or left.  Therefore, as the fall rate approaches zero, the Lander
   becomes more uncontrollable, and your horizontal stabilizers react more quickly.
   (Just like the real thing).

7. If you land too fast, the Lander will bounce and flip over.

8. If you run out of fuel, the Lander will crash.

9. You will not be allowed to go above 250 feet.  If you try to do so, you will just
   waste precious fuel.

10. Once you reach 32 feet and move into the landing display, you will not be allowed
    to rise above 26 feet.  Trying to do so will waste more precious fuel.

11. Game options
  
    You may select one of three options at the begining of the game.

    Option 1: You start at 250 feet.  You are given 150 pounds of fuel.  You must land
              at 5 feet per second or less.  The initial descent display is easy to
              maneuver through.

    Option 2: You start at 250 feet.  You have 200 pounds of fuel.  You must land at 3 feet
              per second or less.  The initial descent display is hard to maneuver through.

    Option 3: You start at 32 feet.  You have 100 pounds of fuel.  You must land at 3 feet
              per second or less.  This display allows you to practice landing.  

    You should consider Option 2 as the complete game when trying for Astronaut Ratings.

12. Astronaut Ratings

    The computer will award you with ratings depending on how good a lander you are.

    You will obtain the rating of Astronaut by landing without regard to fall rate or
    fuel.  You must not exceed fall rate, or zero fuel.
    
    You will obtain the rating of Astronaut Pilot, by ladning with regard to fuel.  80
    pounds or more if you land between the two rock formations on the floor, and 50
    pounds or more if you land between the crater wall and a rock formation.

    You will obtain the rating of Astronaut Captain by landing the ship with regard to
    fuel as per above and if the fall rate is two feet per second or less.  (Not an
    easy task, as you will soon discover).

13. About Graphics

    This game has some interesting graphic displays when you run out of fuel, crash,
    land too fast, when you land successfully.  I will leave them to your discovery,
    as they are fun to watch.

14. Landing Sites

    The final landing display will appear somewhat like the illustration below
    (VIPG1-15.jpg).  You may land in any of the three locations pointed to.  To land
    between the crater walls and rock formations, you will have to first bring the
    Lander to a zero fall rate while hovering in the center landing area.  Then bring
    the ship up and just over the rock formation, and let it drop down to the landing
    site.  At the last moment, a few taps on the thruster button will slow the lander
    to the required fall rate.  It will take you many tries to land here, but don't
    give up, it can be done!!

NOTE:  VIP Lunar Lander requires at least 3K of RAM.  RAM memories are available to
       increase your VIP from 2K to 3K at your local computer store or by contacting:
                        RCA VIP Marketing
                        New Holland Avenue
                        Lancaster, PA 17604

======================



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
