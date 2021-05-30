/*
ESPboy chip8/schip emulator by RomanS
Special thanks to Igor (corax69), DmitryL (Plague), John Earnest (https://github.com/JohnEarnest/Octo/tree/gh-pages/docs) for help, Alvaro Alea Fernandez for his Chip-8 emulator

ESPboy project page:
https://hackaday.io/project/164830-espboy-beyond-the-games-platform-with-wifi
*/

//#pragma GCC optimize ("-Ofast")
//#pragma GCC push_options

#include "ROM1.h" //AstroDodge SCHIP
//#include "ROM2.h" //Sub-Terr8nia SCHIP
//#include "ROM3.h" // Turnover77 SCHIP
//#include "ROM4.h" // Ant SCHIP

#include "ESPboyCHIP8fonts.h"
#include <FS.h>
#include "lib/ESPboyInit.h"
#include "lib/ESPboyInit.cpp"


//system
#define FONTCHIP_OFFSET       0x38 //small chip8 font 8x5
#define FONTSUPERCHIP_OFFSET  0x88 //large super chip font 8x10
#define NLINEFILES            14 //no of files in menu

//default emu parameters
#define DEFAULTCOMPATIBILITY    0b0000000001000011 //compatibility bits: bit16,...bit8,bit7...bit1;
#define DEFAULTOPCODEPERFRAME   40
#define DEFAULTTIMERSFREQ       60 // freq herz
#define DEFAULTBACKGROUND       0  // check colors []
#define DEFAULTDELAY            1000
#define DEFAULTSOUNDTONE        300

#define MAX_FPS_PART_DRAW 20
#define MAX_FPS_FULL_DRAW 8

//default keymapping
//0-LEFT, 1-UP, 2-DOWN, 3-RIGHT, 4-ACT, 5-ESC, 6-LFT side button, 7-RGT side button
static uint8_t default_buttons[8] = { 4, 2, 8, 6, 5, 11, 4, 6 };
//1     2    3     C[12]
//4     5    6     D[13]
//7     8    9     E[14]
//A[10] 0    B[11] F[15]


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

BNNN (aka jump0)ыуе
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

0x1E ADI I = I + VX. SET reg I OVERFLOW BIT IN reg VF OR NOT
bit9 = 1 set VF=1 in case of I ovelflow, overwise VF=0
bit9 = 0 VX stay unchanged after oveflowing reg I operation I = I + VX 
*/

//compatibility bits
#define BIT1CTL (compatibility_emu & 1)
#define BIT2CTL (compatibility_emu & 2)
#define BIT3CTL (compatibility_emu & 4)
#define BIT4CTL (compatibility_emu & 8)
#define BIT5CTL (compatibility_emu & 16)
#define BIT6CTL (compatibility_emu & 32)
#define BIT7CTL (compatibility_emu & 64)
#define BIT8CTL (compatibility_emu & 128)
#define BIT9CTL (compatibility_emu & 256)


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



//lib colors table
uint16_t colors[] = { 
            TFT_BLACK, TFT_NAVY, TFT_DARKGREEN, TFT_DARKCYAN, TFT_MAROON,
					  TFT_PURPLE, TFT_OLIVE, TFT_LIGHTGREY, TFT_DARKGREY, TFT_BLUE, TFT_GREEN, TFT_CYAN,
					  TFT_RED, TFT_MAGENTA, TFT_YELLOW, TFT_WHITE, TFT_ORANGE, TFT_GREENYELLOW, TFT_PINK
};


ESPboyInit myESPboy;


//emulator vars
uint8_t *mem; 
static int16_t        stack[0x10]     __attribute__ ((aligned));; 
static uint8_t        reg[0x10]       __attribute__ ((aligned));;    
static uint8_t        schip_reg[0x10] __attribute__ ((aligned));;
static uint_fast8_t   sp, VF = 0xF; 
static uint_fast8_t   stimer, dtimer;
static uint_fast64_t  emutimer;
static uint_fast16_t  pc, I;
static uint_fast8_t   schip_exit_flag = false;

//loaded parameters
static uint8_t   keys[8]={0};
static uint8_t   foreground_emu;
static uint8_t   background_emu;
static uint16_t  compatibility_emu;   // look above
static uint16_t  opcodesperframe_emu; // how many opcodes should be done before screen updates
static uint8_t   timers_emu;          // freq of timers. standart 60hz
static uint16_t  soundtone_emu;       // sound base tone check buzz();
static uint16_t  delay_emu;           // delay in microseconds before next opcode done

static uint32_t opcodescounter=0;
static uint32_t opcodesafterlastdrawcounter=0;
static uint8_t updatedisplayflag=0;


String                description_emu;     // file description
static const char     *no_config_desc = (char *)"No configuration\nfile found\n\nUsing unoptimal\ndefault parameters";

//diff vars button
static uint_fast16_t  buttonspressed;

//diff vars display
static uint8_t        display2[128 * 64]  __attribute__ ((aligned));
static uint_fast8_t   screen_width;
static uint_fast8_t   screen_height;


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


//interpr.errors
enum DOCPU_RET_CODES: int_fast8_t{
    DOCPU_NOTHING =              0,
    DOCPU_HALT =                 1,
    DOCPU_UNKNOWN_OPCODE =      -1,
    DOCPU_UNKNOWN_OPCODE_0 =    -2,
    DOCPU_UNKNOWN_OPCODE_00E =  -3,
    DOCPU_UNKNOWN_OPCODE_00F =  -4,
    DOCPU_UNKNOWN_OPCODE_8 =    -5,
    DOCPU_UNKNOWN_OPCODE_E =    -6,
    DOCPU_UNKNOWN_OPCODE_F =    -7,
};

//opcodes
enum{
  
  CHIP8_JP =          0x1,
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
  HIRES_ON =          0x2AC,
  HIRES_CLS =         0x230,
  CHIP8_CLS =         0xE0,
  CHIP8_RTS =         0xEE,
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




void IRAM_ATTR update_timers(){
    if ((millis()-emutimer) > (1000 / timers_emu))
    {
      emutimer = millis();
      if (dtimer) dtimer--;
      if (stimer) stimer--;
    }
}



void init_display(){
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
//  memset(display1, 0, sizeof(display1));
  switch (emumode){
    case CHIP8:
      myESPboy.tft.fillRect(0, 16, 128, 64, colors[background_emu]);
      break;
    case HIRES:
      myESPboy.tft.fillRect(0, 0, 128, 128, colors[background_emu]);
      break;
    case SCHIP:
      myESPboy.tft.fillRect(0, 16, 128, 64, colors[background_emu]);
      break;
  }
}



void IRAM_ATTR updatedisplay(){    
  static uint16_t bufLine[256] __attribute__ ((aligned));
  static uint16_t drawcolor, drawcolorback;
  static uint32_t i, j, addr, drawaddr;

  addr=0;
  drawcolor = colors[foreground_emu];
  drawcolorback = colors[background_emu];
  
  switch (emumode){
    
    case CHIP8:
    case HIRES:
      for (i = 0; i < screen_height; i++){
        drawaddr = 0;
        for (j = 0; j < screen_width; j++){ 
          if (display2[addr++]){
            bufLine[drawaddr++] = drawcolor;
            bufLine[drawaddr++] = drawcolor;
          }
          else{
            bufLine[drawaddr++] = drawcolorback;
            bufLine[drawaddr++] = drawcolorback;
          }
        }
        
      memcpy(&bufLine[128], &bufLine[0], 256);
      if (emumode == CHIP8)
        myESPboy.tft.pushImage(0, i*2+16, 128, 2, bufLine);
      else
        myESPboy.tft.pushImage(0, i*2, 128, 2, bufLine);
      }
    break;

    case SCHIP:
      for (i = 0; i < screen_height; i++){
        for (j = 0; j < screen_width; j++)
          if (display2[addr++])
            bufLine[j] = drawcolor;
          else
            bufLine[j] = drawcolorback;
        myESPboy.tft.pushImage(0, i+16, 128, 1, bufLine);
      }
      break;
  }
}


uint8_t IRAM_ATTR drawsprite16x16(uint8_t x, uint8_t y){
  static uint_fast8_t xs, ys, yss, c, d, ret, preret, drw;
  static uint_fast16_t addrdisplay, mask, masked, data;
  static uint32_t timepassed;
    ret = 0; 
    preret = 0;
    drw = 0;
    for(c = 0; c < 16; c++){
      data = (((mem[I + c * 2])<<8) | mem[I + c * 2 + 1]);
      mask=32768;
      preret=0;
      if (BIT4CTL) ys = (y+c) % screen_height;
      else ys = (y % screen_height) + c;
      if(ys >= screen_height && BIT6CTL && !BIT8CTL) ret++;
      yss = ys * screen_width;
      for (d = 0; d < 16; d++){
        if (BIT4CTL) xs = (x + d) % screen_width;
        else xs = (x % screen_width) + d;
        addrdisplay = yss + xs;
        masked = !(!(data & mask));
        if (BIT4CTL || (xs < screen_width && ys < screen_height)){
          if (masked && display2[addrdisplay]) preret++;
          if (display2[addrdisplay] ^= masked) drw++;
        }
        mask >>= 1;
      }
      if (preret) ret++;
    }
    if (BIT7CTL && drw && millis()-timepassed > 1000/MAX_FPS_PART_DRAW) {
      timepassed = millis();
      updatedisplay();
    }
    if (BIT6CTL) return (ret);
    else return (ret?1:0);
}


uint8_t IRAM_ATTR drawsprite(uint8_t x, uint8_t y, uint8_t size){
 static uint_fast8_t data, mask, masked, xs, ys, yss, c, d, ret, preret;
 static uint_fast16_t addrdisplay, drw;
 static uint32_t timepassed;

 opcodesafterlastdrawcounter=0;
 updatedisplayflag=1;
 
 if (!size)
      return (drawsprite16x16(x, y));
 else   
  {
    drw = 0;
    ret = 0; 
    preret = 0;
    for(c = 0; c < size; c++){
      data = mem[I+c];
      mask=128;
      preret=0;
      if (BIT4CTL) ys = (y+c) % screen_height;
      else ys = (y % screen_height) + c;
      if(ys >= screen_height && BIT6CTL && !BIT8CTL) ret++;
      yss = ys * screen_width;
      for (d = 0; d < 8; d++){
        if (BIT4CTL) xs = (x + d) % screen_width;
        else xs = (x % screen_width) + d;
        addrdisplay = yss + xs;    
        masked = !(!(data & mask));
        if (BIT4CTL || (xs < screen_width && ys < screen_height)){
          if (masked && display2[addrdisplay]) preret++;
          if(display2[addrdisplay] ^= masked) drw++; 
        }
        mask >>= 1;
      }
      if (preret) ret++;
    }
    if (BIT7CTL && drw && millis()-timepassed > 1000/MAX_FPS_PART_DRAW) {
      timepassed = millis();
      updatedisplay();
    }
    if (BIT6CTL) return (ret);
    else return (ret?1:0);
  }
}




void chip8_reset(){
  emumode = CHIP8;
  init_display();
  stimer = 0;
  dtimer = 0;
  buzz();
  memcpy_P(&mem[FONTCHIP_OFFSET], fontchip, 16 * 5);
  memcpy_P(&mem[FONTSUPERCHIP_OFFSET], fontschip, 16 * 10);
  pc = 0x200;
  sp = 0;
}



uint_fast16_t checkbuttons(){
  buttonspressed = myESPboy.getKeys();
  return (buttonspressed);
}


uint_fast8_t iskeypressed(uint8_t key){
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


uint_fast8_t waitanykey(){
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


uint_fast16_t waitkeyunpressed(){
	unsigned long starttime = millis();
	while (checkbuttons())
		delay(5);
	return (millis() - starttime);
}


uint_fast8_t readkey(){
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


void loadrom(String filename){
	File f;
	String data;
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
		description_emu = no_config_desc;
	}
	chip8_reset();
}


void buzz(){
	static uint8_t flagbuzz = 0;
	if (stimer > 1 && !flagbuzz)
	{
		flagbuzz++;
		myESPboy.playTone(soundtone_emu);
    myESPboy.myLED.setRGB(10, 0, 0);
	}
	if (stimer < 1 && flagbuzz)
	{
		flagbuzz = 0;
		myESPboy.noPlayTone();
		myESPboy.myLED.setRGB(0, 0, 0);
	}
}




int_fast8_t do_cpu(){
	uint_fast16_t inst, op2, wr, xxx;
	uint_fast8_t cr;
	uint_fast8_t op, x, y, zz, z;

	inst = (mem[pc] << 8) + mem[pc+1];
	pc += 2;
	op = (inst >> 12) & 0xF;
	x = (inst >> 8) & 0xF;
	y = (inst >> 4) & 0xF;
  z = inst & 0xF;
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
		reg[x] = (rand() % 256) & zz;
		break;

	case CHIP8_DRW: //draw sprite
    reg[VF] = drawsprite(reg[x], reg[y], z);
		break;
	case CHIP8_EXT0: //extended instructions chip8/schip
	{ 
		switch (zz)
		{
		case CHIP8_CLS:
			init_display();
			break;
		case CHIP8_RTS: 
			sp = (sp-1) & 0xF;
			pc = stack[sp] & 0xFFF;
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
      return DOCPU_HALT;
      break;  
    case SCHIP_LOW:
      emumode = CHIP8;
      init_display();
      break;  
    case SCHIP_HIGH:
      emumode = SCHIP;
      init_display();
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
    switch (xxx)
    {
      case HIRES_ON:
        emumode = HIRES;
        init_display();
        pc = 0x02BE;
        break;
      case HIRES_CLS:
        init_display();
        break;
    }
  }
  break;

	case CHIP8_MATH: //extended math instructions
		op2 = z;
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
    default:
      return DOCPU_UNKNOWN_OPCODE_8;
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
    default:
      return DOCPU_UNKNOWN_OPCODE_E; 
		}
		break;

	case CHIP8_EXTF: //extended instruction
		switch (zz)
		{
		case CHIP8_EXTF_GDELAY: // getdelay
      //updatedisplay();
			reg[x] = dtimer;
			break;
		case CHIP8_EXTF_KEY: //waitkey
      //updatedisplay();
			reg[x] = waitanykey();
			break;
		case CHIP8_EXTF_SDELAY: //setdelay
      //if (BIT7CTL) updatedisplay();
			dtimer = reg[x];
			break;
		case CHIP8_EXTF_SSOUND: //setsound
			stimer = reg[x];
			break;
		case CHIP8_EXTF_ADI: //add i+r(x)
			I += reg[x];
      if(BIT9CTL) 
        if (I > 0xFFF) reg[VF] = 1;
        else reg[VF] = 0;
      if (I > 0xFFF)
        I %= 0xFFF;        
			break;
		case CHIP8_EXTF_FONT: //fontchip i
			I = FONTCHIP_OFFSET + (reg[x] * 5);
			break;
    case CHIP8_EXTF_XFONT: //font schip i
      I = FONTSUPERCHIP_OFFSET + (reg[x] * 10);
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
    default:
      return DOCPU_UNKNOWN_OPCODE_F;
		}
		break;
  default:
    return DOCPU_UNKNOWN_OPCODE;
	}
    return DOCPU_NOTHING;
}




void do_emulation(){
  static uint_fast64_t tme;
  static uint32_t updatelasttime;

  myESPboy.tft.setTextColor(TFT_MAGENTA, TFT_BLACK);

	init_display();
	
	while (true)
	{
			do_cpu();
      update_timers();
			buzz();

      delay(0);
      
      if(delay_emu) {
        tme = micros(); 
        while ((micros() - tme) < delay_emu) delay(0);}
        
			if (!BIT7CTL &&  opcodescounter++ > opcodesperframe_emu){
        opcodescounter = 0;
			  updatedisplay();
			}


      if (BIT7CTL && updatedisplayflag && (opcodesafterlastdrawcounter++ > opcodesperframe_emu) && millis()-updatelasttime > 1000/MAX_FPS_FULL_DRAW){
        updatelasttime = millis();
        updatedisplay();
        updatedisplayflag=0;
      }
          
      checkbuttons();
		  if (LFT_BUTTON && RGT_BUTTON){
			    chip8_reset();
			    if (waitkeyunpressed() > 300)
				  break;
		  }

      if (ACT_BUTTON && LFT_BUTTON){
        if(opcodesperframe_emu)opcodesperframe_emu--;
        myESPboy.tft.setCursor(0,0);
        myESPboy.tft.print(opcodesperframe_emu);
        myESPboy.tft.print(" ");
        delay(20);
      }
        
      if (ACT_BUTTON && RGT_BUTTON){
        opcodesperframe_emu++;
        myESPboy.tft.setCursor(0,0);
        myESPboy.tft.print(opcodesperframe_emu);
        myESPboy.tft.print(" ");
        delay(20);
      }


      if (ACT_BUTTON && ESC_BUTTON){
        compatibility_emu ^= 64;
        myESPboy.tft.setCursor(0,8);
        myESPboy.tft.print("BIT7 ");
        myESPboy.tft.print(!(!(compatibility_emu & 64)));
        myESPboy.tft.print(" ");
        delay(500);
      }
    
      if (ESC_BUTTON && LFT_BUTTON){
        background_emu++;
        if(background_emu > 19) background_emu = 0;
        delay(200);
      }
        
      if (ESC_BUTTON && RGT_BUTTON){
        foreground_emu++;
        if(foreground_emu > 19) foreground_emu = 0;
        delay(200);
      }

     
      if (schip_exit_flag)
      {
          schip_exit_flag = false;
          break;
      }
	}
}




void setup(){

  //Init ESPboy  
  myESPboy.begin("CHIP8/SCHIP");


  mem = new (uint8_t[0x1000]);
  
  myESPboy.tft.setTextColor(TFT_GREEN);
  myESPboy.tft.setCursor(0, 0);
  myESPboy.tft.println(F("FILE SYSTEM INIT..."));
	SPIFFS.begin();
  myESPboy.tft.println(F("DONE"));
  delay(1000);
  myESPboy.tft.fillScreen(TFT_BLACK);

}



void loop(){
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
		myESPboy.tft.setTextColor(TFT_YELLOW);
		myESPboy.tft.setTextSize(1);
		myESPboy.tft.setCursor(0, 0);
		myESPboy.tft.print(F(
			"upload .ch8 to SPIFFS\n"
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
			" - EXIT  - longpress"));
		waitkeyunpressed();
		waitanykey();
		waitkeyunpressed();
		selectedfilech8 = 1;
		if (maxfilesch8)
			emustate = APP_SHOW_DIR;
    else{
        myESPboy.tft.fillScreen(TFT_BLACK);
        myESPboy.tft.setCursor(0, 0);
        myESPboy.tft.setTextColor(TFT_MAGENTA);
        myESPboy.tft.println(F("Chip8 ROMs not found"));
        myESPboy.tft.println(F("upload to SPIFFS"));
        myESPboy.tft.println("");
        delay(1000);
        myESPboy.tft.println(F("Loading default..."));
        delay(2000);

        memcpy_P(&mem[0x200], &ROM[0], sizeof(ROM));
        for (uint8_t i = 0; i < 8; i++) keys[i] = atoi(ROMCFG[i]);
        foreground_emu = atoi(ROMCFG[8]);
        background_emu = atoi(ROMCFG[9]);
        delay_emu = atoi(ROMCFG[10]);
        compatibility_emu = atoi(ROMCFG[11]);
        opcodesperframe_emu = atoi(ROMCFG[12]);
        timers_emu = atoi(ROMCFG[13]);
        soundtone_emu = atoi(ROMCFG[14]);
        description_emu = ((String)ROMCFG[14]).substring(0, 314);

        chip8_reset();
        emustate = APP_EMULATE;
    }
		break;
	case APP_SHOW_DIR:
		dir = SPIFFS.openDir("/");
		countfilesch8 = 0;
		while (countfilesch8+1 < ((selectedfilech8 / (NLINEFILES)) * (NLINEFILES)))
		{
			dir.next();
			filename = String(dir.fileName());
			filename.toLowerCase();
			if (filename.lastIndexOf(String(".ch8")) > 0)
				countfilesch8++;
		}
		myESPboy.tft.fillScreen(TFT_BLACK);
		myESPboy.tft.setCursor(0, 0);
		myESPboy.tft.setTextColor(TFT_YELLOW);
		myESPboy.tft.print("SELECT GAME:");
		myESPboy.tft.setTextColor(TFT_MAGENTA);
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
					myESPboy.tft.setTextColor(TFT_YELLOW);
				}
				else
				{
					myESPboy.tft.setTextColor(TFT_MAGENTA);
				}
				myESPboy.tft.setCursor(0, countfilesonpage * 8 + 12);
				myESPboy.tft.print(filename);
				countfilesonpage++;
			}
		}
		emustate = APP_CHECK_KEY;
		break;
	case APP_CHECK_KEY:
		//waitkeyunpressed();
		waitanykey();
    delay(100);
		if (UP_BUTTON && selectedfilech8 > 1)
			selectedfilech8--;
		if (DOWN_BUTTON && (selectedfilech8 < maxfilesch8))
			selectedfilech8++;
		if (ACT_BUTTON)
		{
			chip8_reset();
			selectedfilech8name.trim();
			loadrom("/" + selectedfilech8name + ".ch8");
      myESPboy.tft.fillScreen(TFT_BLACK);
			myESPboy.tft.setCursor((((21 - selectedfilech8name.length())) / 2) * 6, 0);
			myESPboy.tft.setTextColor(TFT_YELLOW);
			myESPboy.tft.print(selectedfilech8name);
			myESPboy.tft.setCursor(0, 12);
			myESPboy.tft.setTextColor(TFT_MAGENTA);
			myESPboy.tft.print(description_emu);
			//waitkeyunpressed();
			waitanykey();
			//waitkeyunpressed();
			emustate = APP_EMULATE;
		}
		else
			emustate = APP_SHOW_DIR;
		//waitkeyunpressed();
		break;
	case APP_EMULATE: //chip8 emulation
		myESPboy.tft.fillScreen(TFT_BLACK);
		do_emulation();
    myESPboy.tft.fillScreen(TFT_BLACK);
		emustate = APP_HELP;
		break;
	}
}
