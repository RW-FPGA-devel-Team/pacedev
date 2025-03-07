;
; *** COCO registers
;

PIA0				.equ		0xFF00
PIA1				.equ		0xFF20

KEYCOL			.equ		PIA0+2
KEYROW			.equ		PIA0

;
; *** GIME registers  	
;

INIT0				.equ		0xFF90
INIT1				.equ		0xFF91
IRQENR			.equ		0xFF92
FIRQENR			.equ		0xFF93
TMRMSB			.equ		0xFF94
TMRLSB			.equ		0xFF95
VMODE				.equ		0xFF98
VRES				.equ		0xFF99
BRDR				.equ		0xFF9A
VSC					.equ		0xFF9C
VOFFMSB			.equ		0xFF9D
VOFFLSB			.equ		0xFF9E
HOFF				.equ		0xFF9F
MMUTSK1			.equ		0xFFA0
MMUTSK2			.equ		0xFFA8
PALETTE			.equ		0xFFB0
CPU089			.equ		0xFFD8
CPU179			.equ		0xFFD9
ROMMODE			.equ		0xFFDE
RAMMODE			.equ		0xFFDF

HGR1_MSB		.equ		0x00
HGR2_MSB		.equ		0x40

						.macro HGR1
						lda			#(VIDEOPAGE<<2)-1     ; screen at page $38
						sta			VOFFMSB
						.endm

						.macro HGR2
						lda			#((VIDEOPAGE+2)<<2)-1 ; screen at page $40
						sta			VOFFMSB
						.endm

;
; *** LODE RUNNER SPECIFIC CONFIGURATION HERE
;

;.define       CARTRIDGE
;.define			GFX_1BPP
; The MONO build is only used to generate graphics
; - the COLOUR version of the code is always run
; - the loader patches the line character
;.define			GFX_MONO
.define       GFX_RGB

.ifndef GFX_1BPP
	.define		GFX_2BPP
.endif
.ifndef GFX_MONO
	.define		GFX_COLOUR
.endif

.ifndef GFX_RGB
  .define   GFX_COMPOSITE
.endif

; *** These macros are only used for the experimental mode
; *** where the title screen was colourised on-the-fly
; *** from the original monochrome tile data
; *** - no longer used
;
.ifdef GFX_MONO
					.macro GFX_BYTE
						lsra												; b0->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b1->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b2->C
						rorb												; C->b7
						asrb												; b7->b7..b6
						lsra												; b3->C
						rorb												; C->b7
						asrb												; b7->b7..b6
					.endm
.else
					.macro GFX_NIBBLE
						pshs		a
						lsra												; b0->C
						rorb												; C->b7
						lsra												; b1->C
						rorb												; C->b7, b7->b6
						puls		a
						lsra												; b0->C
						rorb												; C->b7, b7..6->b6..5
						lsra												; b1->C
						rorb												; C->b7, b7..5->b6..4
					.endm
					.macro GFX_BYTE
						GFX_NIBBLE
						GFX_NIBBLE
					.endm
.endif						

.ifdef GFX_1BPP
	VIDEO_BPP			.equ	1
.else
	VIDEO_BPP			.equ	2
.endif

VIDEO_BPL     	.equ  VIDEO_BPP*40
VIDEO_RM				.equ	VIDEO_BPP*5
APPLE_BPL				.equ	VIDEO_BPL-VIDEO_RM
						
;
; Memory Map		Page
; ------------  ----
; $0000-$3BFF   $30-$31		HGR1
; $3F00-$3FFF   $31				Zero Page
; $4000-$7BFF   $32-$33		HGR2
; $7C00-$7FFF		$33				Level Data 1,2
; $8000-$9AXX   $34				Tile Graphics Data
; $A000-$BXXX		$35				Title Screen, Game Over Data
; $C000-$F965   $36-$37		Program Code & ROM Data
; $FA00-$FCFF   $37       RAM
;      -$FE00   $37				6809 System Stack
;

;RAMBASE			.equ				0x3c00
ZEROPAGE				.equ			0x3c00
ldu1						.equ			0x7c00
ldu2						.equ			0x7e00
tile_data	  		.equ	  	0x8000
gameover_data		.equ			0xbc00
.ifdef GFX_1BPP
	GO_BPL				.equ			13
.else
	GO_BPL				.equ			26
.endif
gol1						.equ			0xbc00+0*GO_BPL
gol2						.equ			0xbc00+1*GO_BPL
gol3						.equ			0xbc00+2*GO_BPL
gol4						.equ			0xbc00+3*GO_BPL
gol5						.equ			0xbc00+4*GO_BPL
gol6						.equ			0xbc00+5*GO_BPL
gol7						.equ			0xbc00+6*GO_BPL
gol8						.equ			0xbc00+7*GO_BPL
gol9						.equ			0xbc00+8*GO_BPL
gol10						.equ			0xbc00+9*GO_BPL
gol11						.equ			0xbc00+10*GO_BPL
codebase				.equ		  0xc000
stack						.equ		  0xfe00

.define	HAS_TITLE
.define	TITLE_EXTERNAL
.ifdef TITLE_EXTERNAL
	.ifdef GFX_1BPP
  	title_data	.equ	  0xa3c0
 .else
  	title_data	.equ	  0xa000
 .endif
.endif

.define HAS_SOUND
.ifdef HAS_SOUND
  .define USE_1BIT_SOUND
  .ifdef USE_1BIT_SOUND
    SOUND_ADDR  .equ		PIA1+2
    SOUND_MASK  .equ    (1<<1)
  .else
    .define USE_DAC_SOUND
    SOUND_ADDR  .equ		PIA1
    SOUND_MASK  .equ    0xfc
  .endif
.endif
  
; MMU page mappings
VIDEOPAGE   .equ        0x38
GFXPAGE			.equ				0x34
CODEPAGE		.equ				0x36

;.define			LEVELS_EXTERNAL
