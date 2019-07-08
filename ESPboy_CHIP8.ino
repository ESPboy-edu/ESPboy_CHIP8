/*
ESPboy chip8/schip emulator by RomanS
Special thanks to Alvaro Alea Fernandez for his Chip-8 emulator, Igor (corax69), DmitryL (Plague), John Earnest (https://github.com/JohnEarnest/Octo/tree/gh-pages/docs) for help

ESPboy project page:
https://hackaday.io/project/164830-espboy-beyond-the-games-platform-with-wifihttps://hackaday.io/project/164830-espboy-beyond-the-games-platform-with-wifi
*/

#include <FS.h>
#include <TFT_eSPI.h>
#include <Wire.h>
#include <Adafruit_NeoPixel.h>
#include <Adafruit_MCP23017.h>
#include <Adafruit_MCP4725.h>
#include <ESP8266WiFi.h>
#include "ESPboyLogo.h"
#include <pgmspace.h>
#include <Ticker.h>


//system
#define fontchip_OFFSET       30 //???0x38
#define NLINEFILES            14 //no of files in menu
#define csTFTMCP23017pin      8
#define LEDquantity           1
#define MCP23017address       0 // actually it's 0x20 but in <Adafruit_MCP23017.h> lib there is (x|0x20) :)
#define MCP4725dacresolution  8
#define MCP4725address        0

/*compatibility_emu var
8XY6/8XYE opcode
Bit shifts a register by 1, VIP: shifts rY by one and places in rX, SCHIP: ignores rY field, shifts existing value in rX.
bit1 = 1    <<= and >>= takes vx, shifts, puts to vx, ignore vy
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

DXYN checkbit8
bit6 = 1    drawsprite returns number of collised rows of the sprite + rows out of the screen lines of the sprite (check for bit8)
bit6 = 0    drawsprite returns 1 if collision/s and 0 if no collision/s

EMULATOR TFT DRAW
bit7 = 1    draw to TFT just after changing pixel by drawsprite() not on timer
bit7 = 0    redraw all TFT from display on timer

DXYN OUT OF SCREEN checkbit6
bit8 = 1    drawsprite does not add "number of out of the screen lines of the sprite" in returned value
bit8 = 0    drawsprite add "number of out of the screen lines of the sprite" in returned value

*/


#define BIT1CTL (compatibility_emu & 1)
#define BIT2CTL (compatibility_emu & 2)
#define BIT3CTL (compatibility_emu & 4)
#define BIT4CTL (compatibility_emu & 8)
#define BIT5CTL (compatibility_emu & 16)
#define BIT6CTL (compatibility_emu & 32)
#define BIT7CTL (compatibility_emu & 64)
#define BIT8CTL (compatibility_emu & 128)
#define BIT9CTL (compatibility_emu & 256)

#define DEFAULTCOMPATIBILITY    0b0000000001000011 //bit bit8,bit7...bit1;
#define DEFAULTOPCODEPERFRAME   40
#define DEFAULTTIMERSFREQ       60 // freq herz
#define DEFAULTBACKGROUND       0  // check colors []
#define DEFAULTDELAY            1
#define DEFAULTSOUNDTONE        300


//buttons
#define LEFT_BUTTON   (buttonspressed & 1)
#define UP_BUTTON     (buttonspressed & 2)
#define DOWN_BUTTON   (buttonspressed & 4)
#define RIGHT_BUTTON  (buttonspressed & 8)
#define ACT_BUTTON    (buttonspressed & 16)
#define ESC_BUTTON    (buttonspressed & 32)
#define LFT_BUTTON    (buttonspressed & 64)
#define RGT_BUTTON    (buttonspressed & 128)
#define LEFT_BUTTONn  0
#define UP_BUTTONn    1
#define DOWN_BUTTONn  2
#define RIGHT_BUTTONn 3
#define ACT_BUTTONn   4
#define ESC_BUTTONn   5
#define LFT_BUTTONn   6
#define RGT_BUTTONn   7

//pins
#define LEDPIN    D4
#define SOUNDPIN  D3

//lib colors
uint16_t colors[] = { TFT_BLACK, TFT_NAVY, TFT_DARKGREEN, TFT_DARKCYAN, TFT_MAROON,
					 TFT_PURPLE, TFT_OLIVE, TFT_LIGHTGREY, TFT_DARKGREY, TFT_BLUE, TFT_GREEN, TFT_CYAN,
					 TFT_RED, TFT_MAGENTA, TFT_YELLOW, TFT_WHITE, TFT_ORANGE, TFT_GREENYELLOW, TFT_PINK };


static const uint8_t PROGMEM fontchip[16 * 5] = {
	0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
	0x20, 0x60, 0x20, 0x20, 0x70, // 1
	0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
	0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
	0x90, 0x90, 0xF0, 0x10, 0x10, // 4
	0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
	0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
	0xF0, 0x10, 0x20, 0x40, 0x40, // 7
	0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
	0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
	0xF0, 0x90, 0xF0, 0x90, 0x90, // A
	0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
	0xF0, 0x80, 0x80, 0x80, 0xF0, // C
	0xE0, 0x90, 0x90, 0x90, 0xE0, // D
	0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
	0xF0, 0x80, 0xF0, 0x80, 0x80, // F
};


static const uint8_t PROGMEM fontschip[16 * 10] = {
  0x00, 0x3C, 0x42, 0x42, 0x42, 0x42, 0x42, 0x42, 0x3C, 0x00, //0
  0x00, 0x08, 0x38, 0x08, 0x08, 0x08, 0x08, 0x08, 0x3E, 0x00, //1
  0x00, 0x38, 0x44, 0x04, 0x08, 0x10, 0x20, 0x44, 0x7C, 0x00, //2
  0x00, 0x38, 0x44, 0x04, 0x18, 0x04, 0x04, 0x44, 0x38, 0x00, //3
  0x00, 0x0C, 0x14, 0x24, 0x24, 0x7E, 0x04, 0x04, 0x0E, 0x00, //4
  0x00, 0x3E, 0x20, 0x20, 0x3C, 0x02, 0x02, 0x42, 0x3C, 0x00, //5
  0x00, 0x0E, 0x10, 0x20, 0x3C, 0x22, 0x22, 0x22, 0x1C, 0x00, //6
  0x00, 0x7E, 0x42, 0x02, 0x04, 0x04, 0x08, 0x08, 0x08, 0x00, //7
  0x00, 0x3C, 0x42, 0x42, 0x3C, 0x42, 0x42, 0x42, 0x3C, 0x00, //8
  0x00, 0x3C, 0x42, 0x42, 0x42, 0x3E, 0x02, 0x04, 0x78, 0x00, //9
  0x00, 0x18, 0x08, 0x14, 0x14, 0x14, 0x1C, 0x22, 0x77, 0x00, //A
  0x00, 0x7C, 0x22, 0x22, 0x3C, 0x22, 0x22, 0x22, 0x7C, 0x00, //B
  0x00, 0x1E, 0x22, 0x40, 0x40, 0x40, 0x40, 0x22, 0x1C, 0x00, //C
  0x00, 0x78, 0x24, 0x22, 0x22, 0x22, 0x22, 0x24, 0x78, 0x00, //D
  0x00, 0x7E, 0x22, 0x28, 0x38, 0x28, 0x20, 0x22, 0x7E, 0x00, //E
  0x00, 0x7E, 0x22, 0x28, 0x38, 0x28, 0x20, 0x20, 0x70, 0x00  //F
 };


uint8_t   mem[0x1000]; 
int16_t   stack[0x10]; 
uint8_t   sp, VF = 0xF; 
volatile static uint8_t stimer, dtimer;
uint16_t  pc, I;
uint8_t   schip_exit_flag = false;
uint8_t   reg[0x10];    
uint8_t   schip_reg[0x10];

static uint8_t   keys[8]={0};
static uint8_t   foreground_emu;
static uint8_t   background_emu;
static uint16_t  compatibility_emu;   // look above
static uint8_t   delay_emu;           // delay in microseconds before next opcode done
static uint8_t   opcodesperframe_emu; // how many opcodes should be done before screen updates
static uint8_t   timers_emu;          // freq of timers. standart 60hz
String           description_emu;     // file description
static uint16_t  soundtone_emu;

static uint16_t buttonspressed;

uint8_t screen_width;
uint8_t screen_height;
uint8_t display1[128 * 64];
uint8_t display2[128 * 64];


enum EMUSTATE {
  APP_HELP,
  APP_SHOW_DIR,
  APP_CHECK_KEY,
  APP_EMULATE
};
EMUSTATE emustate = APP_HELP;

enum EMUMODE {
  CHIP8,
  HIRES,
  SCHIP,
};
EMUMODE emumode = CHIP8;


TFT_eSPI tft = TFT_eSPI();
Adafruit_MCP23017 mcp;
Adafruit_NeoPixel pixels(LEDquantity, LEDPIN);
Adafruit_MCP4725 dac;
Ticker timers;

//keymapping 0-LEFT, 1-UP, 2-DOWN, 3-RIGHT, 4-ACT, 5-ESC, 6-LFT side button, 7-RGT side button
static uint8_t default_buttons[8] = { 4, 2, 8, 6, 5, 11, 4, 6 };
//1     2    3     C[12]
//4     5    6     D[13]
//7     8    9     E[14]
//A[10] 0    B[11] F[15]


void chip8timers()
{
	if (dtimer)
		dtimer--;
	if (stimer)
		stimer--;
}


uint16_t checkbuttons()
{
	buttonspressed = ~mcp.readGPIOAB() & 255;
	return (buttonspressed);
}



void chip8_cls()
{
  switch (emumode){
    case CHIP8:
      screen_width = 64;
      screen_height = 32;
      break;
    case HIRES:
      screen_width = 64;
      screen_height = 64;
      break;
    case SCHIP:
      screen_width = 128;
      screen_height = 64;
      break;
  }  
  memset(display2, 0, sizeof(display2));
  memset(display1, 1, sizeof(display2));
  tft.fillScreen(TFT_BLACK);
  updatedisplay();
  
}


void updatedisplay()
{    
  static uint8_t drawcolor, i, j;
  static uint16_t addr;
  //static unsigned long tme;
  //  tme=millis();
  for (i = 0; i < screen_height; i++)
    for (j = 0; j < screen_width; j++) 
    {
      if (emumode == SCHIP)
          addr = (i << 7) + j;
      else
          addr = (i << 6) + j;
      if (display1[addr] ^= display2[addr])
      {
       if (display2[addr])
          drawcolor = foreground_emu;
        else
          drawcolor = background_emu;
        switch (emumode){
          case CHIP8:
            tft.fillRect(j << 1, (i << 1) + 16, 2, 2, colors[drawcolor]);
            break;
          case HIRES:
            tft.fillRect(j << 1, i << 1, 2, 2, colors[drawcolor]);
            break;
          case SCHIP:
            tft.drawPixel(j, i+16, colors[drawcolor]);
            break;
        }
      }
    }
    memcpy(display1, display2, sizeof(display1));
  //   Serial.println(millis()-tme);
}




uint8_t drawsprite(uint8_t x, uint8_t y, uint8_t size)
{
 static uint8_t data, mask, masked, xs, ys, c, d, ret, preret;
 static uint16_t addrdisplay;
 if (!size && emumode == SCHIP)
      return (drawsprite16x16(x, y));
 else   
  {
    ret=0; 
    preret=0;
    if (!size) size = 16;
    for(c=0; c<size; c++){
      data = mem[I+c];
      mask=128;
      preret=0;
      ys = y+c;
      if (BIT4CTL)
        ys %= screen_height;
      if(ys > (screen_height - 1) && BIT6CTL && !BIT8CTL) ret++;
      for (d = 0; d < 8; d++){
        xs = x + d;
        if (BIT4CTL)
          xs %= screen_width;
        if (emumode == SCHIP)
            addrdisplay = (ys << 7);
        else
            addrdisplay = (ys << 6);
        addrdisplay += xs;    
        masked = !!(data & mask);
        if ((xs < screen_width) && (ys < screen_height)){
          if (masked && display2[addrdisplay]) preret++;
          display2[addrdisplay] ^= masked;
        }
        mask >>= 1;
      }
      if (preret) ret++;
    }
    if (BIT7CTL) updatedisplay();
    if (BIT6CTL) return (ret);
    else return (ret?1:0);
  }
}


uint8_t drawsprite16x16(uint8_t x, uint8_t y)
{
  static uint8_t xs, ys, c, d, ret, preret;
  static uint16_t addrdisplay, mask, masked, data;
    ret=0; 
    preret=0;
    for(c=0; c<16; c++){
      data = (((mem[I+(c<<1)])<<8) + mem[I+(c<<1)+1]);
      mask=32768;
      preret=0;
      ys = y+c;
      if (BIT4CTL)
          ys %= screen_height;
      if(ys > (screen_height - 1) && BIT6CTL && !BIT8CTL) ret++;
      for (d = 0; d < 16; d++){
        xs = x + d;
        if (BIT4CTL)
            xs %= screen_width;
        addrdisplay = (ys << 7) + xs;
        masked = !!(data & mask);
        if ((xs < screen_width) && (ys < screen_height)){
          if (masked && display2[addrdisplay]) preret++;
          display2[addrdisplay] ^= masked;
        }
        mask >>= 1;
      }
      if (preret) ret++;
    }
    if (BIT7CTL) updatedisplay();
    if (BIT6CTL) return (ret);
    else return (ret?1:0);
}


void chip8_reset()
{
  emumode = CHIP8;
  chip8_cls();
  stimer = 0;
  dtimer = 0;
  buzz();
  pc = 0x200;
  sp = 0;
}


uint8_t iskeypressed(uint8_t key)
{
	uint8_t ret = 0;
	checkbuttons();
	if (LEFT_BUTTON && keys[LEFT_BUTTONn] == key)
		ret++;
	if (UP_BUTTON && keys[UP_BUTTONn] == key)
		ret++;
	if (DOWN_BUTTON && keys[DOWN_BUTTONn] == key)
		ret++;
	if (RIGHT_BUTTON && keys[RIGHT_BUTTONn] == key)
		ret++;
	if (ACT_BUTTON && keys[ACT_BUTTONn] == key)
		ret++;
	if (ESC_BUTTON && keys[ESC_BUTTONn] == key)
		ret++;
	if (LFT_BUTTON && keys[LFT_BUTTONn] == key)
		ret++;
	if (RGT_BUTTON && keys[RGT_BUTTONn] == key)
		ret++;
	return (ret ? 1 : 0);
}

uint8_t waitanykey()
{
	uint8_t ret = 0;
	while (!checkbuttons())
		delay(5);
	if (LEFT_BUTTON)
		ret = keys[LEFT_BUTTONn];
	if (UP_BUTTON)
		ret = keys[UP_BUTTONn];
	if (DOWN_BUTTON)
		ret = keys[DOWN_BUTTONn];
	if (RIGHT_BUTTON)
		ret = keys[RIGHT_BUTTONn];
	if (ACT_BUTTON)
		ret = keys[ACT_BUTTONn];
	if (ESC_BUTTON)
		ret = keys[ESC_BUTTONn];
	if (RGT_BUTTON)
		ret = keys[RGT_BUTTONn];
	if (LFT_BUTTON)
		ret = keys[LFT_BUTTONn];
	return ret;
}

uint16_t waitkeyunpressed()
{
	unsigned long starttime = millis();
	while (checkbuttons())
		delay(5);
	return (millis() - starttime);
}

uint8_t readkey()
{
	checkbuttons();
	if (LEFT_BUTTON)
		return LEFT_BUTTONn;
	if (UP_BUTTON)
		return UP_BUTTONn;
	if (DOWN_BUTTON)
		return DOWN_BUTTONn;
	if (RIGHT_BUTTON)
		return RIGHT_BUTTONn;
	if (ACT_BUTTON)
		return ACT_BUTTONn;
	if (ESC_BUTTON)
		return ESC_BUTTONn;
	if (LFT_BUTTON)
		return LFT_BUTTONn;
	if (RGT_BUTTON)
		return RGT_BUTTONn;
	if (!buttonspressed)
		return 255;
	return 0;
}

void loadrom(String filename)
{
	File f;
	String data;
	char *desc;
	uint16_t c;
	f = SPIFFS.open(filename, "r");
	f.read(&mem[0x200], f.size());
	f.close();
	filename.setCharAt(filename.length() - 3, 'k');
	filename = filename.substring(0, filename.length() - 2);
	if (SPIFFS.exists(filename))
	{
		f = SPIFFS.open(filename, "r");
		for (c = 0; c < 7; c++)
		{
			data = f.readStringUntil(' ');
			keys[c] = data.toInt();
		}
		data = f.readStringUntil('\n');
		keys[7] = data.toInt();
		data = f.readStringUntil('\n');
		foreground_emu = data.toInt();
		data = f.readStringUntil('\n');
		background_emu = data.toInt();
		data = f.readStringUntil('\n');
		delay_emu = data.toInt();
		data = f.readStringUntil('\n');
		compatibility_emu = data.toInt();
		data = f.readStringUntil('\n');
		opcodesperframe_emu = data.toInt();
		data = f.readStringUntil('\n');
		timers_emu = data.toInt();
		data = f.readStringUntil('\n');
		soundtone_emu = data.toInt();
		description_emu = f.readStringUntil('\n');
		description_emu = description_emu.substring(0, 314);
		f.close();
		if (foreground_emu == 255)
			foreground_emu = random(17) + 1;
//		compatibility_emu = DEFAULTCOMPATIBILITY;
    if (foreground_emu > 18) foreground_emu = 15;
    if (background_emu > 18) background_emu = 0;
	}
	else
	{
		for (c = 0; c < 8; c++)
			keys[c] = default_buttons[c];
		foreground_emu = random(10) + 9;
		background_emu = DEFAULTBACKGROUND;
		compatibility_emu = DEFAULTCOMPATIBILITY;
		delay_emu = DEFAULTDELAY;
		opcodesperframe_emu = DEFAULTOPCODEPERFRAME;
		timers_emu = DEFAULTTIMERSFREQ;
		soundtone_emu = DEFAULTSOUNDTONE;
		desc = (char *)"No configuration\nfile found\n\nUsing unoptimal\ndefault parameters";
		description_emu = desc;
	}
	chip8_reset();
}

void buzz()
{
	static uint8_t flagbuzz = 0;
	if (stimer > 1 && !flagbuzz)
	{
		flagbuzz++;
		tone(SOUNDPIN, soundtone_emu);
		pixels.setPixelColor(0, pixels.Color(30, 0, 0));
		pixels.show();
	}
	if (stimer < 1 && flagbuzz)
	{
		flagbuzz = 0;
		noTone(SOUNDPIN);
		pixels.setPixelColor(0, pixels.Color(0, 0, 0));
		pixels.show();
	}
}

enum
{
	CHIP8_JP =          0x1,
  HIRES_ON =          0x260,
  
	CHIP8_CALL =        0x2,
	CHIP8_SEx =         0x3,
	CHIP8_SNEx =        0x4,
	CHIP8_SExy =        0x5,
	CHIP8_MOVx =        0x6,
	CHIP8_ADDx =        0x7,
	CHIP8_SNExy =       0x9,
	CHIP8_MOVi =        0xa,
	CHIP8_JMP =         0xb,
	CHIP8_RND =         0xc,
	CHIP8_DRW =         0xd,
  
	CHIP8_EXT0 =        0x0,
	CHIP8_CLS =         0xE0,
	CHIP8_RTS =         0xEE,
  HIRES_CLS =         0x30,
  SCHIP_SCD =         0xC,
  SCHIP_SCR =         0xFB,
  SCHIP_SCL =         0xFC,
  SCHIP_EXIT =        0xFD,
  SCHIP_LOW =         0xFE,
  SCHIP_HIGH =        0xFF,

	CHIP8_EXTF =        0xF,
	CHIP8_EXTF_GDELAY = 0x07,
	CHIP8_EXTF_KEY =    0x0a,
	CHIP8_EXTF_SDELAY = 0x15,
	CHIP8_EXTF_SSOUND = 0x18,
	CHIP8_EXTF_ADI =    0x1e,
	CHIP8_EXTF_FONT =   0x29,
	CHIP8_EXTF_XFONT =  0x30,
	CHIP8_EXTF_BCD =    0x33,
	CHIP8_EXTF_STR =    0x55,
	CHIP8_EXTF_LDR =    0x65,
  SCHIP_EXTF_MOV =    0xF,
  SCHIP_EXTF_LDr =    0x75,
  SCHIP_EXTF_LDxr =   0x85, 

	CHIP8_MATH =        0x8,
	CHIP8_MATH_MOV =    0x0,
	CHIP8_MATH_OR =     0x1,
	CHIP8_MATH_AND =    0x2,
	CHIP8_MATH_XOR =    0x3,
	CHIP8_MATH_ADD =    0x4,
	CHIP8_MATH_SUB =    0x5,
	CHIP8_MATH_SHR =    0x6,
	CHIP8_MATH_RSB =    0x7,
	CHIP8_MATH_SHL =    0xe,

	CHIP8_SK =          0xe,
	CHIP8_SK_RP =       0x9e,
	CHIP8_SK_UP =       0xa1, 
};


uint8_t do_cpu()
{
	uint16_t inst, op2, wr, xxx;
	uint8_t cr;
	uint8_t op, x, y, zz;

	inst = (mem[pc] << 8) + mem[pc+1];
	pc += 2;
	op = (inst >> 12) & 0xF;
	x = (inst >> 8) & 0xF;
	y = (inst >> 4) & 0xF;
	zz = inst & 0x00FF;
	xxx = inst & 0x0FFF;

	switch (op)
{
	case CHIP8_CALL: // call xyz
		stack[sp] = pc;
		sp = (sp+1) & 0x0F;
		pc = inst & 0xFFF;
		break;

	case CHIP8_JP: // jp xyz
    if (xxx == HIRES_ON && emumode == CHIP8) 
    {
      emumode = HIRES;
      chip8_cls();
    }
    else
      pc = xxx;
		break;

	case CHIP8_SEx: // sex:  skip next opcode if r(x)=zz
		if (reg[x] == zz)
			pc += 2;
		break;

	case CHIP8_SNEx: //snex: skip next opcode if r(x)<>zz
		if (reg[x] != zz)
			pc += 2;
		break;

	case CHIP8_SExy: //sexy: skip next opcode if r(x)=r(y)
		if (reg[x] == reg[y])
			pc += 2;
		break;

	case CHIP8_MOVx: // mov xxx
		reg[x] = zz;
		break;

	case CHIP8_ADDx: // add xxx
		reg[x] = reg[x] + zz;
		break;

	case CHIP8_SNExy: //skne: skip next opcode if r(x)<>r(y)
		if (reg[x] != reg[y])
			pc += 2;
		break;

	case CHIP8_MOVi: // mvi xxx
		I = xxx;
		break;

	case CHIP8_JMP: // jmp xxx		
		if (BIT5CTL)
			pc = xxx + reg[x];
		else
			pc = xxx + reg[0];
		break;
	case CHIP8_RND: //rand xxx
		reg[x] = random(256) & zz;
		break;

	case CHIP8_DRW: //draw sprite
    reg[VF] = drawsprite(reg[x], reg[y], inst & 0xF);
		break;

    
	case CHIP8_EXT0: //extended instructions chip8/schip
	{ 
		switch (zz)
		{
		case CHIP8_CLS:
			chip8_cls();
			break;
		case CHIP8_RTS: 
			sp = (sp-1) & 0xF;
			pc = stack[sp] & 0xFFF;
			break;
    case HIRES_CLS:
      chip8_cls();
      break;
    case SCHIP_SCR:
      for (cr=0; cr<screen_height; cr++)
        {
          memmove(&display2[cr*screen_width+4], &display2[cr*screen_width], sizeof(uint8_t)*screen_width-4);
          memset(&display2[cr*screen_width], 0, sizeof(uint8_t)*4);
        }
      if (BIT7CTL) updatedisplay();  
      break;  
    case SCHIP_SCL:
      for (cr=0; cr<screen_height; cr++)
      {
          memmove(&display2[cr*screen_width], &display2[cr*screen_width+4], sizeof(uint8_t)*screen_width-4);
          memset(&display2[cr*screen_width+screen_width-4], 0, sizeof(uint8_t)*4);
      }
      if (BIT7CTL) updatedisplay();   
      break;  
    case SCHIP_EXIT:
      schip_exit_flag = true;
      break;  
    case SCHIP_LOW:
      emumode = CHIP8;
      chip8_cls();
      break;  
    case SCHIP_HIGH:
      emumode = SCHIP;
      chip8_cls();
      break;  
		}
    switch (y)
    {
      case SCHIP_SCD: //scroll display n lines down
        memmove (&display2[screen_width*(inst&0x000F)], display2, sizeof(display2)-sizeof(uint8_t)*screen_width*(inst&0x000F));
        memset (display2, 0, sizeof(uint8_t)*screen_width*(inst&0x000F));
        if (BIT7CTL) updatedisplay();
      break;
    }
  }
  break;

	case CHIP8_MATH: //extended math instructions
		op2 = inst & 0xF;
		switch (op2)
		{
		case CHIP8_MATH_MOV: //mov r(x)=r(y)
			reg[x] = reg[y];
			break;
		case CHIP8_MATH_OR: //or
			reg[x] |= reg[y];
			break;
		case CHIP8_MATH_AND: //and
			reg[x] &= reg[y];
			break;
		case CHIP8_MATH_XOR: //xor
			reg[x] ^= reg[y];
			break;
		case CHIP8_MATH_ADD: //add
			if (BIT3CTL)
			{   // carry first
				wr = reg[x];
				wr += reg[y];
				reg[VF] = wr > 0xFF;
				reg[x] = reg[x] + reg[y];
			}
			else
			{
				wr = reg[x];
				wr += reg[y];
				reg[x] = wr;
				reg[VF] = wr > 0xFF;
			}
			break;
		case CHIP8_MATH_SUB: //sub
			if (BIT3CTL)
			{   // carry first
				reg[VF] = reg[y] <= reg[x];
				reg[x] = reg[x] - reg[y];
			}
			else
			{
				cr = reg[y] <= reg[x];
				reg[x] = reg[x] - reg[y];
				reg[VF] = cr;
			}
			break;
		case CHIP8_MATH_SHR: //shr
			if (BIT3CTL)
			{   // carry first
				if (BIT1CTL)
				{
					reg[VF] = reg[x] & 0x1;
					reg[x] >>= 1;
				}
				else 
				{
					reg[VF] = reg[y] & 0x1;
					reg[x] = reg[y] >> 1;
				}
			}
			else
			{
				if (BIT1CTL)
				{
					cr = reg[x] & 0x1;
					reg[x] >>= 1;
					reg[VF] = cr;
				}
				else
				{
					cr = reg[y] & 0x1;
					reg[x] = reg[y] >> 1;
					reg[VF] = cr;
				}
			}
			break;
		case CHIP8_MATH_RSB: //rsb
			if (BIT3CTL)
			{   // carry first
				reg[VF] = reg[y] >= reg[x];
				reg[x] = reg[y] - reg[x];
			}
			else 
			{
				cr = reg[y] >= reg[x];
				reg[x] = reg[y] - reg[x];
				reg[VF] = cr;
			}
			break;
		case CHIP8_MATH_SHL: //shl
			if (BIT3CTL)
			{   // carry first
				if (BIT1CTL)
				{
					reg[VF] = reg[x] >> 7;
					reg[x] <<= 1;
				}
				else
				{
					reg[VF] = reg[y] >> 7;
					reg[x] = reg[y] << 1;
				}
			}
			else
			{
				if (BIT1CTL)
				{
					cr = reg[x] >> 7;
					reg[x] <<= 1;
					reg[VF] = cr;
				}
				else
				{
					cr = reg[y] >> 7;
					reg[x] = reg[y] << 1;
					reg[VF] = cr;
				}
			}
			break;
		} 
		break;

	case CHIP8_SK: //extended instruction
		switch (zz)
		{
		case CHIP8_SK_RP: // skipifkey
			if (iskeypressed(reg[x]))
				pc += 2;
			break;
		case CHIP8_SK_UP: // skipifnokey
			if (!iskeypressed(reg[x]))
				pc += 2;
			break;
		}
		break;

	case CHIP8_EXTF: //extended instruction
		switch (zz)
		{
		case CHIP8_EXTF_GDELAY: // getdelay
			reg[x] = dtimer;
			break;
		case CHIP8_EXTF_KEY: //waitkey
			reg[x] = waitanykey();
			break;
		case CHIP8_EXTF_SDELAY: //setdelay
			dtimer = reg[x];
			break;
		case CHIP8_EXTF_SSOUND: //setsound
			stimer = reg[x];
			break;
		case CHIP8_EXTF_ADI: //add i+r(x)
			I += reg[x];
      if( I > 0xFFF)
      {
        I %= 0xFFF;
        reg[VF] = 1;
      }
      else 
        reg[VF] = 0;
			break;
		case CHIP8_EXTF_FONT: //fontchip i
      memcpy_P(&mem[fontchip_OFFSET], fontchip, 16 * 5);
			I = fontchip_OFFSET + (reg[x] * 5);
			break;
    case CHIP8_EXTF_XFONT: //font schip i
      memcpy_P(&mem[fontchip_OFFSET], fontschip, 16 * 10);
      I = fontchip_OFFSET + (reg[x] * 10);
      break;  
		case CHIP8_EXTF_BCD: //bcd
			mem[I] = reg[x] / 100;
			mem[I + 1] = (reg[x] / 10) % 10;
			mem[I + 2] = reg[x] % 10;
			break;
		case CHIP8_EXTF_STR: //save
			memcpy(&mem[I], reg, sizeof(uint8_t) * x + 1);
			if (!BIT2CTL)
				I = I + x + 1;
			break;
		case CHIP8_EXTF_LDR: //load
			memcpy(reg, &mem[I], sizeof(uint8_t) * x + 1);
			if (!BIT2CTL)
				I = I + x + 1;
			break;
     case SCHIP_EXTF_LDr:
      memcpy (schip_reg, reg, sizeof(uint8_t) * ((x&7)+1));
      break;
     case SCHIP_EXTF_LDxr:
      memcpy (reg, schip_reg, sizeof(uint8_t) * ((x&7)+1));
      break;
		}
		break;
	}
    return (0);
}


void do_emulation()
{
	uint16_t c = 0;
	timers.attach_ms((uint8_t)(1000.0f / (float)timers_emu), chip8timers);
	chip8_cls();
	while (1)
	{
		if (c < opcodesperframe_emu)
		{
			do_cpu();
			buzz();
			delay(delay_emu);
			c++;
		}
		else
		{
			if (!BIT7CTL) updatedisplay();
			c = 0;
		}
    checkbuttons();
		if (LFT_BUTTON && RGT_BUTTON)
		{
			chip8_reset();
			if (waitkeyunpressed() > 300)
				break;
		}
    if (schip_exit_flag)
    {
      schip_exit_flag = false;
      break;
    }
	}
	timers.detach();
}



void draw_loading(bool reset = false)
{
	static bool firstdraw = true;
	static uint8_t index = 0;
	int32_t pos, next_pos;
	constexpr auto x = 29, y = 96, w = 69, h = 8, cnt = 5, padding = 3;
	if (reset)
	{
		firstdraw = true;
		index = 0;
	}
	if (firstdraw)
	{
		tft.fillRect(x+1, y+1, w-2, h-2, TFT_BLACK);
		tft.drawRect(x, y, w, h, TFT_YELLOW);
		firstdraw = false;
	}
	pos = ((index * (w - padding - 1)) / cnt);
	index++;
	next_pos = ((index * (w - padding - 1)) / cnt);
	tft.fillRect(x + padding + pos, y + padding, next_pos - pos - padding + 1, h - padding*2, TFT_YELLOW);
}


void setup()
{
	// DISPLAY FIRST
	//buttons on mcp23017 init
	mcp.begin(MCP23017address);
	//delay(10);
	for (int i = 0; i < 8; i++)
	{
		mcp.pinMode(i, INPUT);
		mcp.pullUp(i, HIGH);
	}

	// INIT SCREEN FIRST
	//TFT init
	mcp.pinMode(csTFTMCP23017pin, OUTPUT);
	mcp.digitalWrite(csTFTMCP23017pin, LOW);
	tft.init();
	tft.setRotation(0);
	tft.fillScreen(TFT_BLACK);

	draw_loading();

	//draw ESPboylogo
	tft.drawXBitmap(30, 24, ESPboyLogo, 68, 64, TFT_YELLOW);
	tft.setTextSize(1);
	tft.setTextColor(TFT_YELLOW);
	tft.setCursor(4, 118);
	tft.print("Chip8/Schip emulator");

	Serial.begin(115200); //serial init
	if (!SPIFFS.begin())
	{
		SPIFFS.format();
		SPIFFS.begin();
	}
	delay(100);
	WiFi.mode(WIFI_OFF); // to safe some battery power
	draw_loading();

	//LED init
	pinMode(LEDPIN, OUTPUT);
	pixels.begin();
	delay(100);
	pixels.setPixelColor(0, pixels.Color(0, 0, 0));
	pixels.show();
	draw_loading();

	//sound init and test
	pinMode(SOUNDPIN, OUTPUT);
	tone(SOUNDPIN, 200, 100);
	delay(100);
	tone(SOUNDPIN, 100, 100);
	delay(100);
	noTone(SOUNDPIN);
	draw_loading();

	//DAC init
	dac.begin(0x60);
	delay(100);
	dac.setVoltage(4095, true);
	draw_loading();

	//clear TFT
	delay(1500);
	tft.fillScreen(TFT_BLACK);
}

void loop()
{
	static uint16_t selectedfilech8, countfilesonpage, countfilesch8, maxfilesch8;
	Dir dir;
	static String filename, selectedfilech8name;
	dir = SPIFFS.openDir("/");
	maxfilesch8 = 0;
	while (dir.next())
	{
		filename = String(dir.fileName());
		filename.toLowerCase();

		if (filename.lastIndexOf(String(".ch8")) > 0)
			maxfilesch8++;
	}

	switch (emustate)
	{
	case APP_HELP:
		tft.setTextColor(TFT_YELLOW);
		tft.setTextSize(1);
		tft.setCursor(0, 0);
		tft.print(
			"upload .ch8 to spiffs\n"
			"\n"
			"add config file for\n"
			" - keys remap\n"
			" - fore/back color\n"
			" - compatibility ops\n"
			" - opcodes per redraw\n"
			" - timers freq hz\n"
			" - sound tone\n"
			" - description\n"
			"\n"
			"during the play press\n"
			"both side buttons for\n"
			" - RESET - shortpress\n"
			" - EXIT  - longpress");
		waitkeyunpressed();
		waitanykey();
		waitkeyunpressed();
		selectedfilech8 = 1;
		if (maxfilesch8)
			emustate = APP_SHOW_DIR;
    else{
        tft.fillScreen(TFT_BLACK);
        tft.setCursor(0, 60);
        tft.setTextColor(TFT_MAGENTA);
        tft.print(" Chip8 ROMs not found");
        tft.setCursor(0, 70);
        tft.print("   upload to SPIFFS");
        while (1) 
            delay(5000);
    }
		break;
	case APP_SHOW_DIR:
		dir = SPIFFS.openDir("/");
		countfilesch8 = 0;
		while (countfilesch8 < (selectedfilech8 / (NLINEFILES + 1)) * (NLINEFILES + 1) - 1)
		{
			dir.next();
			filename = String(dir.fileName());
			filename.toLowerCase();

			if (filename.lastIndexOf(String(".ch8")) > 0)
				countfilesch8++;
		}
		tft.fillScreen(TFT_BLACK);
		tft.setCursor(0, 0);
		tft.setTextColor(TFT_YELLOW);
		tft.print("SELECT GAME:");
		tft.setTextColor(TFT_MAGENTA);
		countfilesonpage = 0;
		while (dir.next() && (countfilesonpage < NLINEFILES))
		{
			filename = String(dir.fileName());
			String tfilename = filename;
			tfilename.toLowerCase();

			if (tfilename.lastIndexOf(String(".ch8")) > 0)
			{
				if (filename.indexOf(".") < 17)
					filename = filename.substring(1, filename.indexOf("."));
				else
					filename = filename.substring(1, 16);
				filename = "  " + filename;
				countfilesch8++;
				if (countfilesch8 == selectedfilech8)
				{
					selectedfilech8name = filename;
					filename.trim();
					filename = String("> " + filename);
					tft.setTextColor(TFT_YELLOW);
				}
				else
				{
					tft.setTextColor(TFT_MAGENTA);
				}
				tft.setCursor(0, countfilesonpage * 8 + 12);
				tft.print(filename);
				countfilesonpage++;
			}
		}
		emustate = APP_CHECK_KEY;
		break;
	case APP_CHECK_KEY:
		waitkeyunpressed();
		waitanykey();
		if (UP_BUTTON && selectedfilech8 > 1)
			selectedfilech8--;
		if (DOWN_BUTTON && (selectedfilech8 < maxfilesch8))
			selectedfilech8++;
		if (ACT_BUTTON)
		{
			chip8_reset();
			selectedfilech8name.trim();
			loadrom("/" + selectedfilech8name + ".ch8");
      tft.fillScreen(TFT_BLACK);
			tft.setCursor((((21 - selectedfilech8name.length())) / 2) * 6, 0);
			tft.setTextColor(TFT_YELLOW);
			tft.print(selectedfilech8name);
			tft.setCursor(0, 12);
			tft.setTextColor(TFT_MAGENTA);
			tft.print(description_emu);
			waitkeyunpressed();
			waitanykey();
			waitkeyunpressed();
			emustate = APP_EMULATE;
		}
		else
			emustate = APP_SHOW_DIR;
		waitkeyunpressed();
		break;
	case APP_EMULATE: //chip8 emulation
		tft.fillScreen(TFT_BLACK);
		do_emulation();
		emustate = APP_SHOW_DIR;
		break;
	}
}
