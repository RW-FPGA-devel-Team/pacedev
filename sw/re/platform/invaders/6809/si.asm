;
;	SPACE INVADERS
; - ported from the original arcade game
; - by tcdev 2016 msmcdoug@gmail.com
;
				.list		(meb)										; macro expansion binary
				
       	.area   idaseg (ABS)

.define			PLATFORM_COCO3

.iifdef PLATFORM_COCO3	.include "coco3.asm"

; *** BUILD OPTIONS
;.define BUILD_OPT_ENABLE_PROFILING
.define BUILD_OPT_SKIP_COCO_SPLASH
;.define BUILD_OPT_DISABLE_DEMO
.define BUILD_OPT_ROTATED
; *** end of BUILD OPTIONS

; *** derived - do not edit

.ifndef BUILD_OPT_INVALID
  .define GFX_1BPP
  VIDEO_BPL   .equ    0x20
.else
  .define GFX_2BPP
  VIDEO_BPL   .equ    0x40
.endif

; *** end of derived

; *** INVADERS stuff here
;
    .macro LDX_VRAM addr
      .ifndef BUILD_OPT_ROTATED
        ldx     #vram+addr
      .else
        ldx     #vram+(31-<addr)*256+>addr
      .endif
    .endm
    
    .macro DEF_VRAM addr
      .ifndef BUILD_OPT_ROTATED
        .dw     #vram+addr
      .else
        .dw     #vram+(31-<addr)*256+>addr
      .endif
    .endm

    .macro LDB_SPRW w
      .ifndef BUILD_OPT_ROTATED
        ldb     #w
      .else
        ldb     #(w+7)/8
      .endif
    .endm

    .macro DEF_SPRW w
      .ifndef BUILD_OPT_ROTATED
        .db     #w
      .else
        .db     #(w+7)/8
      .endif
    .endm
        
DIP_DISPLAY_COINAGEn  .equ    (1<<7)
DIP_BONUS_LIFE        .equ    (1<<3)
DIP_TILT              .equ    (1<<2)
DIP_LIVES_MASK        .equ    0x03
DIP_LIVES_3           .equ    (0<<0)
DIP_LIVES_4           .equ    (1<<0)
DIP_LIVES_5           .equ    (2<<0)
DIP_LIVES_6           .equ    (3<<0)
;
INP_RIGHT             .equ    (1<<6)
INP_LEFT              .equ    (1<<5)
INP_FIRE              .equ    (1<<4)

; 3 lives and bonus at 1,500
DEFAULT_DIP_SETTING   .equ    DIP_LIVES_3
; 3 lives and bonus at 1,000
;DEFAULT_DIP_SETTING   .equ    DIP_LIVES_3|DIP_BONUS_LIFE

;NUM_ALIENS    .equ    3
.ifndef NUM_ALIENS
  NUM_ALIENS  .equ    55
.endif  

        .org    WRAM
wram    .equ    .                       ; 1KB

; $2000
wait_on_draw:                   .ds   1
                                .ds   1
alien_is_exploding:             .ds   1                
exp_alien_timer:                .ds   1
alien_row:                      .ds   1
alien_frame:                    .ds   1
alien_cur_index:                .ds   1
ref_alien_dyr:                  .ds   1
ref_alien_dxr:                  .ds   1
ref_alien_xr:                   .ds   1     ; switched for 6809
ref_alien_yr:                   .ds   1     ; switched for 6809
alien_pos_msb:                  .ds   1     ; switched for 6809
alien_pos_lsb:                  .ds   1     ; switched for 6809
rack_direction:                 .ds   1
rack_down_delta:                .ds   1
                                .ds   1
; $2010
; '''GameObject0 (Move/draw the player)'''
obj0_timer_msb:                 .ds   1                                
obj0_timer_lsb:                 .ds   1                                
obj0_timer_extra:               .ds   1                                
obj0_handler_msb:               .ds   1     ; switched for 6809        
obj0_handler_lsb:               .ds   1     ; switched for 6809        
player_alive:                   .ds   1                                
exp_animate_timer:              .ds   1                                
exp_animate_cnt:                .ds   1                                
plyr_spr_pic_m:                 .ds   1     ; switched for 6809
plyr_spr_pic_l:                 .ds   1     ; switched for 6809        
player_xr:                      .ds   1     ; switched for 6809        
player_yr:                      .ds   1     ; switched for 6809        
plyr_spr_siz:                   .ds   1                                
next_demo_cmd:                  .ds   1                                
hid_mess_seq:                   .ds   1                                
                                .ds   1
; $2020
; '''GameObject1 (Move/draw the player shot)'''
obj1_timer_msb:                 .ds   1                                
obj1_timer_lsb:                 .ds   1                                
obj1_timer_extra:               .ds   1                                
obj1_handler_msb:               .ds   1     ; switched for 6809        
obj1_handler_lsb:               .ds   1     ; switched for 6809        
plyr_shot_status:               .ds   1                                
blow_up_timer:                  .ds   1                                
obj1_image_msb:                 .ds   1     ; switched for 6809        
obj1_image_lsb:                 .ds   1     ; switched for 6809        
obj1_coor_xr:                   .ds   1     ; switched for 6809        
obj1_coor_yr:                   .ds   1     ; switched for 6809        
obj1_image_size:                .ds   1                                
shot_delta_x:                   .ds   1                                
fire_bounce:                    .ds   1                                
                                .ds   2
; $2030
; '''GameObject2 (Alien rolling-shot)'''
obj2_timer_msb:                 .ds   1                                
obj2_timer_lsb:                 .ds   1                                
obj2_timer_extra:               .ds   1                                
obj2_handler_msb:               .ds   1     ; switched for 6809        
obj2_handler_lsb:               .ds   1     ; switched for 6809        
rol_shot_status:                .ds   1                                
rol_shot_step_cnt:              .ds   1                                
rol_shot_track:                 .ds   1                                
rol_shot_c_fir_msb:             .ds   1     ; switched for 6809        
rol_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
rol_shot_blow_cnt:              .ds   1                                
rol_shot_image_msb:             .ds   1     ; switched for 6809        
rol_shot_image_lsb:             .ds   1     ; switched for 6809        
rol_shot_xr:                    .ds   1     ; switched for 6809        
rol_shot_yr:                    .ds   1     ; switched for 6809        
rol_shot_size:                  .ds   1                                
; $2040
; '''GameObject3 (Alien plunger-shot)'''
obj3_timer_msb:                 .ds   1
obj3_timer_lsb:                 .ds   1
obj3_timer_extra:               .ds   1                                
obj3_handler_msb:               .ds   1     ; switched for 6809        
obj3_handler_lsb:               .ds   1     ; switched for 6809        
plu_shot_status:                .ds   1                                
plu_shot_step_cnt:              .ds   1                                
plu_shot_track:                 .ds   1                                
plu_shot_c_fir_msb:             .ds   1     ; switched for 6809        
plu_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
plu_shot_blow_cnt:              .ds   1                                
plu_shot_image_msb:             .ds   1     ; switched for 6809        
plu_shot_image_lsb:             .ds   1     ; switched for 6809        
plu_shot_xr:                    .ds   1     ; switched for 6809        
plu_shot_yr:                    .ds   1     ; switched for 6809        
plu_shot_size:                  .ds   1                                
; $2050
; '''GameObject4 (Flying saucer OR alien squiggly shot)'''
obj4_timer_msb:                 .ds   1                                
obj4_timer_lsb:                 .ds   1                                
obj4_timer_extra:               .ds   1                                
obj4_handler_msb:               .ds   1     ; switched for 6809        
obj4_handler_lsb:               .ds   1     ; switched for 6809        
squ_shot_status:                .ds   1                                
squ_shot_step_cnt:              .ds   1                                
squ_shot_track:                 .ds   1                                
squ_shot_c_fir_msb:             .ds   1     ; switched for 6809
squ_shot_c_fir_lsb:             .ds   1     ; switched for 6809        
squ_shot_blow_cnt:              .ds   1                                
squ_shot_image_msb:             .ds   1     ; switched for 6809        
squ_shot_image_lsb:             .ds   1     ; switched for 6809        
squ_shot_xr:                    .ds   1     ; switched for 6809        
squ_shot_yr:                    .ds   1     ; switched for 6809        
squ_shot_size:                  .ds   1                                
; $2060
end_of_tasks:                   .ds   1
collision:                      .ds   1
exp_alien_msb:                  .ds   1     ; switched for 6809
exp_alien_lsb:                  .ds   1     ; switched for 6809
exp_alien_xr:                   .ds   1     ; switched for 6809
exp_alien_yr:                   .ds   1     ; switched for 6809
exp_alien_size:                 .ds   1
player_data_msb:                .ds   1
player_ok:                      .ds   1
enable_alien_fire:              .ds   1
alien_fire_delay:               .ds   1
one_alien:                      .ds   1
temp_206C:                      .ds   1
invaded:                        .ds   1
skip_plunger:                   .ds   1
                                .ds   1
; $2070
other_shot_1:                   .ds   1
other_shot_2:                   .ds   1
vblank_status:                  .ds   1
a_shot_status:                  .ds   1
a_shot_step_cnt:                .ds   1
a_shot_track:                   .ds   1
a_shot_c_fir_msb:               .ds   1     ; switched for 6809
a_shot_c_fir_lsb:               .ds   1     ; switched for 6809
a_shot_blow_cnt:                .ds   1
a_shot_image_msb:               .ds   1     ; switched for 6809
a_shot_image_lsb:               .ds   1     ; switched for 6809
alien_shot_xr:                  .ds   1     ; switched for 6809
alien_shot_yr:                  .ds   1     ; switched for 6809
alien_shot_size:                .ds   1
alien_shot_delta:               .ds   1
shot_pic_end:                   .ds   1
; $2080
shot_sync:                      .ds   1
tmp_2081:                       .ds   1
num_aliens:                     .ds   1
saucer_start:                   .ds   1
saucer_active:                  .ds   1
saucer_hit:                     .ds   1
saucer_hit_time:                .ds   1
saucer_pri_pic_msb:             .ds   1     ; switched for 6809
saucer_pri_pic_lsb:             .ds   1     ; switched for 6809
saucer_pri_loc_msb:             .ds   1     ; switched for 6809
saucer_pri_loc_lsb:             .ds   1     ; switched for 6809
saucer_pri_size:                .ds   1
saucer_delta_y:                 .ds   1
sau_score_msb:                  .ds   1     ; switched for 6809
sau_score_lsb:                  .ds   1     ; switched for 6809
shot_count_msb:                 .ds   1     ; switched for 6809
; $2090
shot_count_lsb:                 .ds   1     ; switched for 6809
till_saucer_msb:                .ds   1     ; switched for 6809
till_saucer_lsb:                .ds   1     ; switched for 6809
wait_start_loop:                .ds   1
sound_port_3:                   .ds   1
change_fleet_snd:               .ds   1
fleet_snd_cnt:                  .ds   1
fleet_snd_reload:               .ds   1
sound_port_5:                   .ds   1
extra_hold:                     .ds   1
tilt:                           .ds   1
fleet_snd_hold:                 .ds   1
                                .ds   4
; $20A0
; '''In the ROM mirror copied to RAM this is the image of the alien sprite pulling the upside down Y. The code expects it to be 
; 0030 below the second animation picture at 1BD0. This RAM area must be unused. The copy is wasted. '''
                                .ds   16
; $20B0
                                .ds   16
; ''' End of inialization copy from ROM mirror'''
; $20C0
; ''' Splash screen animation structure '''
isr_delay:                      .ds   1
isr_splash_task:                .ds   1
splash_an_form:                 .ds   1
splash_delta_x:                 .ds   1
splash_delta_y:                 .ds   1
splash_xr:                      .ds   1     ; switched for 6809
splash_yr:                      .ds   1     ; switched for 6809
splash_image_msb:               .ds   1     ; switched for 6809
splash_image_lsb:               .ds   1     ; switched for 6809
splash_image_size:              .ds   1
splash_target_y:                .ds   1
splash_reached:                 .ds   1
splash_im_rest_msb:             .ds   1     ; switched for 6809
splash_im_rest_lsb:             .ds   1     ; switched for 6809
two_players:                    .ds   1
a_shot_reload_rate:             .ds   1
; $20D0
; This is where the alien-sprite-carying-the-Y ...
; ... lives in ROM
                                .ds   16
; $20E0
                                .ds   5
player1_ex:                     .ds   1
player2_ex:                     .ds   1
player1_alive:                  .ds   1
player2_alive:                  .ds   1
suspend_play:                   .ds   1
coin_switch:                    .ds   1
num_coins:                      .ds   1
splash_animate:                 .ds   1
demo_cmd_ptr_msb:               .ds   1     ; switched for 6809
demo_cmd_ptr_lsb:               .ds   1     ; switched for 6809
game_mode:                      .ds   1
; $20F0
                                .ds   1
adjust_score:                   .ds   1
score_delta_msb:                .ds   1     ; switched for 6809
score_delta_lsb:                .ds   1     ; switched for 6809
hi_scor_m:                      .ds   1     ; switched for 6809
hi_scor_l:                      .ds   1     ; switched for 6809
hi_scor_lo_m:                   .ds   1     ; switched for 6809
hi_scor_lo_l:                   .ds   1     ; switched for 6809
p1_scor_m:                      .ds   1     ; switched for 6809
p1_scor_l:                      .ds   1     ; switched for 6809
p1_scor_lo_m:                   .ds   1     ; switched for 6809
p1_scor_lo_l:                   .ds   1     ; switched for 6809
p2_scor_m:                      .ds   1     ; switched for 6809
p2_scor_l:                      .ds   1     ; switched for 6809
p2_scor_lo_m:                   .ds   1     ; switched for 6809
p2_scor_lo_l:                   .ds   1     ; switched for 6809

; $2100
; Player 1 specific data
byte_0_2100:
                                .ds   55    ; Player 1 alien ship indicators (0=dead) 11*5 = 55
                                .ds   11    ; Unused 11 bytes (room for another row of aliens?)
                                .ds   0xB0  ; Player 1 shields remembered between rounds 44 bytes * 4 shields ($B0 bytes)
                                .ds   9     ; Unused 9 bytes
; $21FB                                
p1_ref_alien_dx:                .ds   1     ; Player 1 reference-alien delta X
p1_ref_alien_x:                 .ds   1     ; Player 1 reference-alien X coordiante (swapped for 6809)
p1_ref_alien_y:                 .ds   1     ; Player 1 reference-alien Y coordinate (swapped for 6809)
p1_rack_cnt:                    .ds   1     ; Player 1 rack-count (starts at 0 but get incremented to 1-8)
p1_ships_rem:                   .ds   1     ; Ships remaining after current dies

; $2200
; Player 2 specific data
byte_0_2200:
                                .ds   55
                                .ds   11
                                .ds   0xB0
                                .ds   9
; $22FB                                
p2_ref_alien_dx:                .ds   1
p2_ref_alien_xr:                .ds   1     ; (swapped for 6809)
p2_ref_alien_yr:                .ds   1     ; (swapped for 6809)
p2_rack_cnt:                    .ds   1
p2_ships_rem:                   .ds   1

; $2300
; stack on the original game goes here
; low water-mark around $23DE

; guard buffer just in case
        .ds     256

        .bndry  0x100
dp_base:            .ds     256        
dp_base_isr:        .ds     256        
z80_b               .equ    0x00
z80_c               .equ    0x01
z80_d               .equ    0x02
z80_e               .equ    0x03
z80_h               .equ    0x04
z80_l               .equ    0x05
z80_a_              .equ    0x06
z80_f_              .equ    0x07
z80_r               .equ    0x08

; rgb/composite video selected (bit 4)
dips:               .ds     1
cmp:                .ds     1
shft_base:          .ds     2

; stack is here on Coco port
        
				.org		code_base

start_coco:
				orcc		#(1<<6)|(1<<4)          ; disable interrupts
				lds			#stack

.ifdef PLATFORM_COCO3

; switch in 32KB cartridge
        lda     #COCO|MMUEN|MC3|MC1|MC0 ; 32KB internal ROM
        sta     INIT0
; setup MMU to copy ROM
        lda     #CODE_PG1
        ldx     #MMUTSK1                ; $0000-$7FFF
        ldb     #4
1$:     sta     ,x+
        inca
        decb
        bne     1$                      ; map pages $30-$33
; copy ROM into RAM        
        ldx     #0x8000                 ; start of 32KB ROM
        ldy     #0x0000                 ; destination
2$:     lda     ,x+
        sta     ,y+
        cmpx    #0xff00                 ; done?
        bne     2$                      ; no, loop
; setup MMU mapping for game
        lda     #CODE_PG1
        ldx     #MMUTSK1+4              ; $8000-$FFFF
        ldb     #4
4$:     sta     ,x+
        inca
        decb
        bne     4$                      ; map pages $30-33
        lda     #VRAM_PG
        ldx     #MMUTSK1                ; $0000-
        ldb     #4
5$:     sta     ,x+
        inca
        decb
        bne     5$                      ; map pages $38-$3B        
; switch to all-RAM mode
        sta     RAMMODE        

; set default DIPSWITCH VALUES
        lda     #DEFAULT_DIP_SETTING
        sta     dips
        
display_splash:

        lda     #0x00                   ; 32 chars/line
        sta     VRES

        ldx     #0x400
        lda     #96                     ; green space
1$:     sta     ,x+
        cmpx    #0x600
        bne     1$
        ldx     #splash
        ldy     #0x420
2$:     pshs    y
        ldb     ,x+                     ; read 'attr'
        stb     attr
        lda     ,x                      ; leading null?
        beq     5$
3$:     lda     ,x+
        beq     4$
        eora    attr
        sta     ,y+
        bra     3$
4$:     puls    y
        leay    32,y
        bra     2$
5$:     ldx			#PIA0
        ldb     #0                      ; flag rgb
6$:     lda     #~(1<<2)
				sta     2,x
				lda     ,x
				bita    #(1<<2)                 ; 'R'?
				beq     7$
        lda     #~(1<<3)
				sta			2,x											; column strobe
				lda			,x											; active low
				bita    #(1<<0)                 ; 'C'?
.ifndef BUILD_OPT_SKIP_COCO_SPLASH				
				bne     6$                      ; try again
.endif				
				ldb     #(1<<4)                 ; flag component
7$:     stb     cmp

setup_gime_for_game:

; initialise PLATFORM_COCO3 hardware
; - disable PIA interrupts
				lda			#0x34
				sta			PIA0+1									; PIA0, CA1,2 control
				sta			PIA0+3									; PIA0, CB1,2 control
				sta			PIA1+1									; PIA1, CA1,2 control
				sta			PIA1+3									; PIA1, CB1,2 control
; - initialise GIME
				lda			#MMUEN|#IEN|#FEN        ; enable GIME MMU, IRQ, FIRQ
				sta			INIT0     							
				lda			#0x00										; slow timer, task 1
				sta			INIT1     							
				lda			#TMR|VBORD              ; Timer, VBLANK IRQs
				sta			IRQENR    							
				lda			#0                      ; no FIRQ enabled
				sta			FIRQENR   							
				lda			#BP										  ; graphics mode, 60Hz, 1 line/row
				sta			VMODE     							
	  .ifdef GFX_1BPP				
				lda			#0x68										; 225 scanlines, 32 bytes/row, 2 colours (225x256)
;				lda			#0x6C										; 225 scanlines, 40 bytes/row, 2 colours (225x320)
	  .else				
				lda			#0x11										; 192 scanlines, 64 bytes/row, 4 colours (256x192)
	  .endif				
				sta			VRES      							
				lda			#0x00										; black
				sta			BRDR      							
				lda			#(VRAM_PG<<2)           ; screen at page $38
				sta			VOFFMSB
;				lda     #0
				lda			#32*(VIDEO_BPL/8)
				sta			VOFFLSB   							
				lda			#0x00										; normal display, horiz offset 0
				sta			HOFF      							

				ldx			#PALETTE
				ldy     #rgb_pal
				ldb     #16
inipal:
				lda     ,y+
				sta     ,x+
				decb
				bne     inipal
				
				sta			CPU179									; select fast CPU clock (1.79MHz)

  ; stop the timer
        clra
        sta     TMRLSB
        sta     TMRMSB

  ; install FIRQ handler and enable CPU FIRQ
				lda			FIRQENR									; ACK any pending FIRQ in the GIME
;        lda     #0x7E                   ; jmp
;        sta     0xFEF4
;				ldx     #cpu_fisr              ; address
;				stx     0xFEF5
;        andcc   #~(1<<6)                ; enable FIRQ in CPU
  ; install IRQ handler and enable CPU IRQ
				lda			IRQENR									; ACK any pending IRQ in the GIME
        lda     #0x7E                   ; jmp
        sta     0xFEF7
        ldx     #cpu_isr
        stx     0xFEF8
;        andcc   #~(1<<4)                ; enable IRQ in CPU    

  ; setup the PIAS for joystick sampling
  
  ; configure joystick axis selection as outputs
  ; and also select left/right joystick
        lda     PIA0+CRA
        ldb     PIA0+CRB
        ora     #(1<<5)|(1<<4)          ; CA2 as output
        orb     #(1<<5)|(1<<4)          ; CB2 as output
.ifdef LEFT_JOYSTICK
        orb     #(1<<3)                 ; CB2=1 left joystick
.else
        andb    #~(1<<3)                ; CB2=0 right joystick
.endif
        sta     PIA0+CRA
        stb     PIA0+CRB
  ; configure comparator as input
        lda     PIA0+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA0+CRA
        lda     PIA0+DDRA
        anda    #~(1<<7)                ; PA7 as input
        sta     PIA0+DDRA
        lda     PIA0+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA0+CRA
  ; configure sound register as outputs
        lda     PIA1+CRA
        anda    #~(1<<2)                ; select DDRA
        sta     PIA1+CRA
        lda     PIA1+DDRA
        ora     #0xfc                   ; PA[7..2] as output
        sta     PIA1+DDRA
        lda     PIA1+CRA
        ora     #(1<<2)                 ; select DATAA
        sta     PIA1+CRA
          
  .ifdef HAS_SOUND				
				lda			PIA1+CRB
				ora			#(1<<5)|(1<<4)					; set CB2 as output
				ora			#(1<<3)									; enable sound
				sta			PIA1+CRB
				; bit2 sets control/data register
				lda     PIA1+CRB
				anda    #~(1<<2)                ; select DDRB
				sta     PIA1+CRB
				lda     PIA1+DDRB
				ora     #(1<<1)                 ; PB1 output
				sta     PIA1+DDRB
        ; setup for data register				
				lda     PIA1+CRB
				ora     #(1<<2)                 ; select DATAB
				sta     PIA1+CRB
  .endif  ; HAS_SOUND

.endif	; PLATFORM_COCO3
			
				lda			#>dp_base
				tfr			a,dp

; Build the shift tables to emulate 
; the hardware shift register
; - 1st run seeds low values
        ldb     #0
        clr     *z80_c
2$:     lda     *z80_c
        ldx     #shift_tbl+0x80
        sta     a,x
        leax    0x100,x
        clr     a,x
        inc     *z80_c
        decb
        bne     2$
; next 7 runs shift the previous entries
        ldb     #7
        ldu     #shift_tbl+0x80
3$:     pshs    b
        ldb     #0
        clr     *z80_c
4$:     pshs    b
        lda     *z80_c
        tfr     u,x                     ; base for this shift
        ldb     a,x                     ; byte #1
        pshs    b
        leax    0x100,x
        ldb     a,x                     ; byte #2
        puls    a
        lsra
        rorb
        pshs    d                       ; b then a
        lda     *z80_c
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #1 shifted
        leax    0x100,x
        puls    b
        stb     a,x                     ; byte #2 shifted
        inc     *z80_c
        puls    b
        decb
        bne     4$
        leau    0x200,u                 ; base for next shift
        puls    b
        decb
        bne     3$
				
; This is only necessary so that in demo mode
; the game shows 3 bases left
; otherwise it shows no bases left
        ldx     #wram
1$:     clr     ,x+
        cmpx    #wram+1024
        bne     1$
                				
        jmp     start                   ; space invaders
        
rgb_pal:
    ;.db RGB_DARK_BLACK, RGB_DARK_BLUE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_BLACK, RGB_WHITE, RGB_DARK_RED, RGB_DARK_MAGENTA
    .db RGB_DARK_GREEN, RGB_DARK_CYAN, RGB_DARK_YELLOW, RGB_GREY
    .db RGB_BLACK, RGB_BLUE, RGB_RED, RGB_MAGENTA
    .db RGB_GREEN, RGB_CYAN, RGB_YELLOW, RGB_WHITE
cmp_pal:    
    ;.db CMP_DARK_BLACK, CMP_DARK_BLUE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_BLACK, CMP_WHITE, CMP_DARK_RED, CMP_DARK_MAGENTA
    .db CMP_DARK_GREEN, CMP_DARK_CYAN, CMP_DARK_YELLOW, CMP_GREY
    .db CMP_BLACK, CMP_BLUE, CMP_RED, CMP_MAGENTA
    .db CMP_GREEN, CMP_CYAN, CMP_YELLOW, CMP_WHITE


splash:
;       .asciz  "01234567890123456789012345678901"
        .db 0
        .asciz  "`````ARCADE`SPACE`INVADERS"
        .db 0
        .asciz  "``````FOR`THE`TRSmxp`COCOs"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "````j`MONOCHROME`GRAPHICS`j"
        .db 0
        .asciz  "`````````hVERSION`pnyi"
        .db 0
        .asciz  "`"
        .db 0
;       .asciz  "01234567890123456789012345678901"
        .asciz  "``````````DIPSWITCHES"
        .db 0
        .asciz  "````````````LIVESz`s"
        .db 0
        .asciz  "````````BONUS`LIFEz`qupp"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "```````hRiGBohCiOMPOSITE"
        .db 0
        .asciz  "`"
        .db 0
        .asciz  "`"
        .db 0x40
        .asciz  "|WWWnRETROPORTSnBLOGSPOTnCOMnAU~"
        .dw     0


attr:   .ds     1

; Coco3 interrupt service routines

.if 0
cpu_fisr:
; temp hack - should do LFSR or something
; and also tune frequency
        tst     FIRQENR                 ; ACK FIRQ
        inc     *z80_r
        rti
.endif

cpu_isr:
        DI                              ; interrupts disabled in the 8080 ISR
        lda     IRQENR                  ; ACK GIME IRQ on the Coco3
        bita    #TMR
        bne     scan_line_96
        bita    #VBORD
        bne     scan_line_224
        EI                              ; should never get here
        rti

; $0008
scan_line_96:

.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_BLUE
        sta     PALETTE+1
.endif

; stopping the timer by setting registers to zero
; holds IRQ asserted on real hardware
; - so set the timer to expire well after the next VBORD
        lda     #<TMR_260ms
        sta     TMRLSB
        lda     #>TMR_260ms
        sta     TMRMSB
				lda			#>dp_base_isr
				tfr			a,dp
; $008C
        clr     vblank_status           ; Flag that tells objects on the upper half of screen to draw/move
        tst     suspend_play            ; Are we moving game objects?
        beq     9$                      ; No ... restore and return
        tst     game_mode               ; Are we in game mode?
        bne     1$                      ; Yes .... process game objects and out
        lda     isr_splash_task         ; Splash-animation tasks
        asra                            ; If we are in demo-mode then we'll process the tasks anyway
        bcc     9$                      ; Not in demo mode ... done
1$:     ldx     #obj1_timer_msb         ; Game object table (skip player-object at 2010)
        jsr     loc_024B                ; Process all game objects (except player object)
        jsr     cursor_next_alien       ; Advance cursor to next alien (move the alien if it is last one)
9$:     
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI
        rti                             ; restores DP

; $0010
scan_line_224:

.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_RED
        sta     PALETTE+1
.endif
; start the timer to simulate the scan line 96 interrupt
        lda     #<TMR_9m5s
        sta     TMRLSB
        lda     #>TMR_9m5s
        sta     TMRMSB                  ; and start the timer
				lda			#>dp_base_isr
				tfr			a,dp

        lda     #0x80                   ; Flag that tells objects ...
        sta     vblank_status           ; ... on the lower half of the screen to draw/move
        dec     isr_delay               ; Decrement the general countdown (used for pauses)
        
        jsr     check_handle_tilt       ; Check and handle TILT
;       in      a,(INP1)
;       rrca
;       jp      c,loc_0067              ; coin switch
        ldx     #KEYROW
        lda     #~(1<<5)                ; Column 5 (keybd '5')
        sta     2,x
        lda     ,x                      ; Read coin switch
        bita    #(1<<4)                 ; Has a coin been deposited (keybd '5')?
        beq     5$                      ; Yes ... note that switch is closed and continue at 3F with A=1
        tst     coin_switch             ; Switch is now open. Was it closed last time?
        beq     3$                      ; No ... skip registering the credit
; $002D
; Handle bumping credit count        
        lda     num_coins               ; Number of credits in BCD
        cmpa    #0x99                   ; 99 credits already?
        beq     1$                      ; Yes ... ignore this (better than rolling over to 00)
        adda    #1                      ; Bump number of credits
        daa                             ; Make it binary coded decimal
        sta     num_coins               ; New number of credits
        jsr     draw_num_credits        ; Draw credits on screen
1$:     clra                            ; Credit switch ...
2$:     sta     coin_switch             ; ... has opened
; $0042
3$:     tst     suspend_play            ; Are we moving game objects?
        beq     loc_0086                ; No ... out
        tst     game_mode               ; Are we in game mode?
        bne     6$                      ; Yes ... go process game-play things and out
        tst     num_coins               ; Are there any credits (player standing there)?
        bne     4$                      ; Yes ... skip any ISR animations for the splash screens
        jsr     isr_spl_tasks           ; Process ISR tasks for splash screens
        bra     loc_0086                ; out
; $005D
; At this point no game is going and there are credits
4$:     tst     wait_start_loop         ; Are we in the "press start" loop?
        bne     loc_0086                ; Yes ... out
        jmp     wait_for_start          ; Start the "press start" loop
; $0067        
; Mark credit as needing registering
5$:     lda     #1                      ; Remember switch ...
        sta     coin_switch             ; ... state for debounce
        bra     2$                      ; Continue
; $006F
; Main game-play timing loop
6$:     jsr     time_fleet_sound        ; Time down fleet sound and sets flag if needs new delay value
loc_0072:
        lda     obj2_timer_extra        ; Use rolling shot's timer to sync ...
        sta     shot_sync               ; ... other two shots
        bsr     draw_alien              ; Draw the current alien (or exploding alien)
        jsr     run_game_objs           ; Process game objects (including player object)
        jsr     time_to_saucer          ; Count down time to saucer

loc_0086:
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI
        rti                             ; restores DP

; $00B1
; Initialize the player's rack of aliens. Copy the reference-location and deltas from the
; player's data bank.
init_rack:
        jsr     get_al_ref_ptr          ; 2xFC Get current player's ref-alien position pointer
        pshs    x                       ; Hold pointer
        ldx     ,x                      ; Get player's ref-alien coordinates
        stx     ref_alien_xr            ; Set game's reference alien's X,Y
        stx     alien_pos_msb           ; Set game's alien cursor bit position
        puls    x                       ; Restore pointer
        leax    -1,x                    ; 21FB or 22FB ref alien's delta (left or right)
        lda     ,x                      ; Get ref alien's delta X
        cmpa    #3                      ; If there is one alien it will move right at 3
        bne     1$                      ; Not 3 ... keep it
        deca                            ; If it is 3, back it down to 2 until it switches again
1$:     sta     ref_alien_dxr           ; Store alien deltaY
        clrb                            ; Value of 0 for rack-moving-right
        cmpa    #0xfe                   ; Moving left?
        bne     2$                      ; Not FE ... keep the value 0 for right
        incb                            ; It IS FE ... use 1 for left
2$:     stb     rack_direction          ; Store rack direction
        rts

; $00D7
sub_00D7:
        lda     #2                      ; Set ...
        sta     p1_ref_alien_dx         ; ... player 1 and 2 ...
        sta     p2_ref_alien_dx        ; ... alien delta to 2 (right 2 pixels)
        jmp     loc_08E4

; $0100
; 2006 holds the index into the alien flag data grid. 2067 holds the MSB of the pointer (21xx or 22xx).
; If there is an alien exploding time it down. Otherwise draw the alien if it alive (or skip if
; it isn't). If an alien is drawn (or blank) then the 2000 alien-drawing flag is cleared.
draw_alien:
        ldx     #alien_is_exploding     ; Is there an ...
        tst     ,x                      ; ... alien exploding?
        lbne    a_explode_time          ; Yes ... go time it down and out
        pshs    x
        ldb     alien_cur_index         ; Get alien index for the 21xx or 22xx pointer
        lda     player_data_msb         ; Get MSB of data area (21xx or 22xx)
        tfr     d,x
        tst     ,x                      ; Get alien status flag. Is the alien alive?
        puls    x
        beq     sub_0136                ; No alien ... skip drawing alien sprite (but flag done)
        leax    2,x                     ; HL=2004 Point to alien's row
        lda     ,x                      ; Get alien type
        leax    1,x                     ; HL=2005 Bump descriptor
        ldb     ,x                      ; Get animation number
        anda    #0xfe                   ; Translate row to type offset as follows: ...
        asla                            ; ... 0,1 -> 32 (type 1) ...
        asla                            ; ... 2,3 -> 16 (type 2) ...
        asla                            ; ...   4 -> 32 (type 3) on top row
        ldy     #alien_spr_a            ; Position 0 alien sprites
        leay    a,y                     ; Offset to sprite type
        tstb                            ; Animation frame number. Is it position 0?
        beq     1$
        bsr     sub_013B                ; No ... add 30 and use position 1 alien sprites
1$:     ldx     alien_pos_msb           ; Pixel position
        LDB_SPRW  16                    ; 16 rows in alien sprites
        jsr     draw_sprite             ; Draw shifted sprite
; $0136        
sub_0136:
        clr     wait_on_draw            ; Let the ISR routine advance the cursor to the next alien
        rts
; $013B
sub_013B:
        leay    0x30,y                  ; Offset sprite pointer to animation frame 1 sprites
        rts        

; $0141
; This is called from the mid-screen ISR to set the cursor for the next alien to draw. 
; When the cursor moves over all aliens then it is reset to the beginning and the reference 
; alien is moved to its next position.
;
; The flag at 2000 keeps this in sync with the alien-draw routine called from the end-screen ISR. 
; When the cursor is moved here then the flag at 2000 is set to 1. This routine will not change 
; the cursor until the alien-draw routine at 100 clears the flag. Thus no alien is skipped.
cursor_next_alien:
        tst     player_ok               ; Is the player blowing up?
        beq     9$                      ; Yes ... ignore the aliens
        tst     wait_on_draw            ; Still waiting on this alien to be drawn?
        bne     9$                      ; Yes ... leave cursor in place
        lda     player_data_msb         ; Load alien-data ...
        sta     *z80_h                  ; ... MSB (either 21xx or 22xx)
        lda     alien_cur_index         ; Load the xx part of the alien flag pointer
        ldb     #2
        stb     *z80_d                  ; When all are gone this triggers 1A1 to return from this stack frame
1$:     inca                            ; Have we drawn all aliens ...
        cmpa    #NUM_ALIENS             ; ... at last position?
        bne     2$
        bsr     move_ref_alien          ; Yes ... move the bottom/right alien and reset index to 0
2$:     sta     *z80_l                  ; HL now points to alien flag
        ldx     *z80_h
        ldb     ,x                      ; Is alien ...
        decb                            ; ... alive?
        bne     1$                      ; No ... skip to next alien
        sta     alien_cur_index         ; New alien index
        bsr     get_alien_coords        ; Calculate bit position and type for index
        lda     *z80_c                  ; The calculation returns the MSB in C
        ldb     *z80_l
        std     alien_pos_msb           ; Store new bit position
        cmpb    #0x28                   ; Has this alien reached the end of screen?
        lbcs    loc_1971                ; Yes ... kill the player
        lda     *z80_d                  ; This alien's ...
        sta     alien_row               ; ... row index
        lda     #1                      ; Set the wait-flag for the ...
        sta     wait_on_draw            ; ... draw-alien routine to clear
9$:     rts

; $017A
get_alien_coords:
; Convert alien index in L to screen bit position in C,L.
; Return alien row index (converts to type) in D.
        clr     *z80_d                  ; Row 0
        tfr     x,d
        tfr     b,a
        ldx     #ref_alien_xr
        ldb     ,x+                     ; Get alien Y ...
        stb     *z80_c                  ; ... to C
        ldb     ,x                      ; Get alien X ...
        stb     *z80_b                  ; ... to B
1$:     cmpa    #11                     ; Can we take a full row off of index?
        bmi     2$                      ; No ... we have the row
        sbca    #11                     ; Subtract off 11 (one whole row)
        sta     *z80_e                  ; Hold the new index
        lda     *z80_b                  ; Add ...
        adda    #0x10                   ; ... 16 to bit ...
        sta     *z80_b                  ; ... position Y (1 row in rack)
        lda     *z80_e                  ; Restore tallied index
        inc     *z80_d                  ; Next row
        bra     1$                      ; Keep skipping whole rows
2$:     ldb     *z80_b                  ; We have the LSB (the row)
        stb     *z80_l
3$:     tsta                            ; Are we in the right column?
        bne     4$
        rts                             ; Yes ... X and Y are right
4$:     sta     *z80_e                  ; Hold index
        lda     *z80_c                  ; Add ...
        adda    #0x10                   ; ... 16 to bit ...
        sta     *z80_c                  ; ... position X (1 column in rack)
        lda     *z80_e                  ; Restore index
        deca                            ; We adjusted for 1 column
        bra     3$                      ; Keep moving over column

; $01A1
; The "reference alien" is the bottom left. All other aliens are drawn relative to this
; reference. This routine moves the reference alien (the delta is set elsewhere) and toggles
; the animation frame number between 0 and 1.
move_ref_alien:
        dec     *z80_d                  ; This decrements with each call to move
        beq     return_two              ; Return out of TWO call frames (only used if no aliens left)
        ldx     #alien_cur_index        ; Set current alien ...
        clr     ,x+                     ; ... index to 0. Point to DeltaX
        lda     ,x
        sta     *z80_c                  ; Load DX into C
        clr     ,x                      ; Set DX to 0
        bsr     add_delta               ; Move alien
        ldx     #alien_frame            ; Alien animation frame number
        lda     ,x                      ; Toggle ...
        inca                            ; ... animation ...
        anda    #1                      ; ... number between ...
        sta     ,x                      ; ... 0 and 1
        lda     player_data_msb         ; Restore H ... (L doesn't matter)
        tfr     d,x                     ; ... to player data MSB (21 or 22)
        clra                            ; Alien index in A is now 0
        rts

; $01C0
init_aliens:
; Initialize the 55 aliens from last to 1st. 1 means alive.
        ldx     #byte_0_2100            ; Start of alien structures (this is the last alien)
loc_01C3:
        ldb     #NUM_ALIENS             ; Count to 55 (that's five rows of 11 aliens)
        lda     #1
1$:     sta     ,x+                     ; Bring alien to life. Next alien
        decb                            ; All done?
        bne     1$                      ; No ... keep looping
        rts        

; $01CD
return_two:
        puls    x                       ; Drop return to caller
        rts                             ; Return to caller's caller

; $01CF
; Draw a 1px line across the player's stash at the bottom of the screen.
draw_bottom_line:
.ifndef BUILD_OPT_ROTATED
        lda     #(1<<7)                 ; Bit 7 set ... going to draw a 1-pixel stripe down left side
        ldb     #0xe0                   ; All the way down the screen
        ldx     #vram+2                 ; Screen coordinates (3rd byte from upper left)
        jmp     sub_14CC                ; Draw line down left side 
.else
        ldb     #VIDEO_BPL              ; screen width in bytes
        ldx     #vram+(32+207)*VIDEO_BPL  ; location
        lda     #0xff
1$:     sta     ,x+
        decb
        bne     1$
        rts
.endif

; $01D9
; HL/X points to descriptor: DX DY XX YY except DX is already loaded in C
; ** Why the "already loaded" part? Why not just load it here?
add_delta:
        leax    1,x                     ; We loaded delta-x already ... skip over it
        ldb     ,x+                     ; Get delta-y
        lda     *z80_c                  ; Add delta-x ...
; note that X,Y are swapped on 6809        
        addb    ,x                      ; Add delta-y to y
        stb     ,x+                     ; Store new y
        adda    ,x                      ; ... to x
        sta     ,x                      ; Store new x
        rts

; $01E4
; Block copy ROM mirror 1B00-1BBF to initialize RAM at 2000-20BF.
copy_ram_mirror:
        ldb     #0xc0                   ; Number of bytes
sub_01E6:
        ldy     #byte_0_1B00            ; RAM mirror in ROM
        ldx     #wram                   ; Start of RAM
        jmp     block_copy              ; Copy [DE/Y]->[HL/X] and return

; $01EF
draw_shield_pl1:
        ldx     #byte_0_2100+0x42       ; Player 1 shield buffer (remember between games in multi-player)
        bra     loc_01F8                ; Common draw point
draw_shield_pl2:
        ldx     #byte_0_2200+0x42       ; Player 2 shield buffer (remember between games in multi-player)
loc_01F8:
        ldb     #4                      ; Going to draw 4 shields
        ldy     #shield_image           ; Shield pixel pattern
1$:     pshs    b,y                     ; Hold the start for the next shield
        ldb     #44                     ; 44 bytes to copy
        jsr     block_copy              ; Block copy DE/Y to HL/X (B bytes)
        puls    b,y                     ; Restore start of shield pattern
        decb                            ; Drawn all shields?
        bne     1$                      ; No ... go draw them all
        rts

; $0209
; Copy shields on the screen to player 1's data area.
remember_shields_1:
        lda     #1                      ; Not zero means remember
        bra     loc_021B                ; Shuffle-shields player 1
        
; $020E
; Copy shields on the screen to player 2's data area.
remember_shields_2:
        lda     #1                      ; Not zero means remember
        bra     loc_0214                ; Shuffle-shields player 2
        
; $0213
; Copy shields from player 2's data area to screen.
restore_shields_2:
        clra                            ; Zero means restore
loc_0214:        
        ldy     #byte_0_2200+0x42       ; Player 2 shield buffer (remember between games in multi-player)
        bra     copy_shields            ; Shuffle-shields player 2

; $021A
; Copy shields from player 1's data area to screen.
restore_shields_1:
        clra                            ; Zero means restore
loc_021B:        
        ldy     #byte_0_2100+0x42       ; Player 1 shield buffer (remember between games in multi-player)

; $021E
; A is 1 for screen-to-buffer, 0 for to buffer-to-screen
; HL/X is screen coordinates of first shield. There are 23 rows between shields.
; DE/Y is sprite buffer in memory.
copy_shields:
        sta     tmp_2081                ; Remember copy/restore flag
        ldu     #0x1602                 ; 22 rows, 2 bytes/row (for 1 shield pattern)
        LDX_VRAM  0x0406                ; Screen coordinates
        ldb     #4                      ; Four shields to move
1$:     pshs    b                       ; Hold shield count
        stu     *z80_b                  ; B=rows, C=bytes
        lda     tmp_2081                ; Get back copy/restore flag
        bne     4$                      ; Not zero means remember shields
        jsr     restore_shields         ; Restore player's shields
2$:     puls    b
        decb                            ; Have we moved all shields?
        bne     3$
        rts
3$:     
.ifndef BUILD_OPT_ROTATED
        leax    0x02e0,x                ; Add 2E0 (23 rows) to get to next shield on screen
.else
        leax    -0x02e0+6,x							; will need to rotate and shift shield graphics
.endif        
        bra     1$        
4$:     jsr     remember_shields        ; Remember player's shields
        bra     2$                      ; Continue with next shield

; $0248
; Process game objects. Each game object has a 16 byte structure. The handler routine for the object
; is at xx03 and xx04 of the structure. The pointer to xx04 is pushed onto the stack before calling
; the handler.
;
; All game objects (except task 0 ... the player) are called at the mid-screen and end-screen renderings.
; Each object decides when to run based on its Y (not rotated) coordinate. If an object is on the lower
; half of the screen then it does its work when the beam is at the top of the screen. If an object is
; on the top of the screen then it does its work when the beam is at the bottom. This keeps the
; object from updating while it is being drawn which would result in an ugly flicker.
;
;
; The player is only processed at the mid-screen interrupt. I am not sure why.
;
; The first three bytes of the structure are used for status and timers.
; 
; If the first byte is FF then the end of the game-task list has been reached.
; If the first byte is FE then the object is skipped.
;
; If the first-two bytes are non-zero then they are treated like a two-byte counter
; and decremented as such. The 2nd byte is the LSB (moves the fastest).
;
; If the first-two bytes are zero then the third byte is treated as an additional counter. It
; is decremented as such.
;
; When all three bytes reach zero the task is executed.
;
; The third-byte-counter was used as a speed-governor for the player's object, but evidently even the slowest
; setting was too slow. It got changed to 0 (fastest possible).
run_game_objs:
        ldx     #obj0_timer_msb         ; First game object (active player)
loc_024B:
        lda     ,x                      ; Have we reached the ...
        cmpa    #0xff                   ; ... end of the object list?
        bne     1$
        rts                             ; Yes ... done
1$:     cmpa    #0xfe                   ; Is object active?
        beq     loc_0281                ; No ... skip it
        leax    1,x
        ldb     ,x                      ; First byte to B
        sta     *z80_c                  ; Hold 1st byte
        ora     ,x                      ; OR 1st and 2nd byte
        pshs    cc
        lda     *z80_c                  ; Restore 1st byte
        puls    cc
        bne     loc_0277                ; If word at xx00,xx02 is non zero then decrement it
loc_025C:
        leax    1,x                     ; xx02
        tst     ,x                      ; Get byte counter. Is it 0?
        bne     loc_0288                ; No ... decrement byte counter at xx02
        leax    1,x                     ; xx03
        ldy     ,x+                     ; Get handler address. xx04
        pshs    x                       ; Remember pointer to MSB XXX LSB on 6809!?!
        exg     x,y                     ; Handler address to HL/X
; this was a dog's breakfast on the 8080
; using PUSH HL, LD HL,$026F, EX (SP),HL        
        ldu     #loc_026F               ; Return address to 026F
        pshs    u                       ; Return address (026F) now on stack. Handler (still) in HL/X.
        pshs    y                       ; Push pointer to data struct (xx04) for handler to use
        jmp     ,x                      ; Run object's code (will return to next line)
loc_026F:        
        puls    x                       ; Restore pointer to xx04
        leax    12,x                    ; Offset to next game task (12+4=16)
        bra     loc_024B                ; Do next game task

; Word at xx00 and xx01 is non-zero. Decrement it and move to next task. 
loc_0277:
        decb                            ; Decrement ...
        incb                            ; ... two ...
        bne     1$                      ; ... byte ...
        deca                            ; ... value ...
1$:     decb                            ; ... at ...
        stb     ,x                      ; ... xx00 ...
        leax    -1,x                    ; ... and ...
        sta     ,x                      ; ... xx01
        
loc_0281:
        leax    0x10,x                  ; Next object descriptor
        bra     loc_024B                ; Keep processing game objects

loc_0288:
        dec     ,x                      ; Decrement the xx02 counter
        leax    -2,x                    ; Back up to start of game task
        bra     loc_0281                ; Next game task

; $028E
; Game object 0: Move/draw the player
;
; This task is only called at the mid-screen ISR. It ALWAYS does its work here, even though
; the player can be on the top or bottom of the screen (not rotated).
game_obj_0:
        puls    x                       ; Get player object structure 2014
        leax    1,x                     ; Point to blow-up status
        lda     ,x                      ; Get player blow-up status
        cmpa    #0xff                   ; Player is blowing up?
        lbeq    loc_033B                ; No ... go do normal movement
; Handle blowing up player
        leax    1,x                     ; Point to blow-up delay count
        dec     ,x                      ; Decrement the blow-up delay
        beq     1$
0$:     rts                             ; Not time for a new blow-up sprite ... out
1$:     tfr     a,b                     ; Hold sprite image number
        clra
        sta     player_ok               ; Player is NOT OK ... player is blowing up
        sta     enable_alien_fire       ; Alien fire is disabled
        lda     #0x30                   ; Reset count ...
        sta     alien_fire_delay        ; ... till alien shots are enabled
        tfr     b,a                     ; Restore sprite image number (used if we go to 39B)
        ldb     #5
        stb     ,x+                     ; Reload time between blow-up changes. Point to number of blow-up changes
        dec     ,x                      ; Count down blow-up changes
        lbne    draw_player_die         ; Still blowing up ... go draw next sprite
; $02AE
; Blow up finished
        ldx     player_xr               ; Player's coordinates
        LDB_SPRW  16                    ; 16 Bytes
        jsr     erase_simple_sprite     ; Erase simple sprite (the player)
        ldx     #obj0_timer_msb         ; Restore player ...
        ldy     #byte_0_1B00+0x10       ; ... structure ...
        ldb     #0x10                   ; ... from ...
        jsr     block_copy              ; ... ROM mirror
        ldb     #0                      ; Turn off ...
        jsr     sound_bits_3_off        ; ... all sounds
        tst     invaded                 ; Has rack reached the bottom of the screen?
        bne     0$                      ; Yes ... done here
        tst     game_mode               ; Are we in game mode?
        beq     0$                      ; No ... return to splash screens
        lds     #stack                  ; We aren't going to return
				lda			#>dp_base
				tfr			a,dp
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI                              ; Enable interrupts (we just dropped the ISR context)
        jsr     disable_game_tasks      ; Disable game tasks
        jsr     sub_092E                ; Get number of ships for active player
        lbeq    loc_166D                ; Any left? No ... handle game over for player
        jsr     sub_18E7                ; Get player-alive status pointer
        lda     ,x                      ; Is player alive?
        beq     loc_032C                ; Yes ... remove a ship from player's stash and reenter game loop
        tst     two_players             ; Multi-player game. Only one player?
        beq     loc_032C                ; Yes ... remove a ship from player's stash and reenter game loop
loc_02ED:
        lda     player_data_msb         ; Player data MSB
        pshs    a                       ; Hold the MSB
        rora                            ; Player 1 is active player?
        bcs     loc_0332                ; Yes ... go store player 1 shields and come back to 02F8
        jsr     remember_shields_2      ; No ... go store player 2 shields
; $02F8
loc_02F8:        
        jsr     sub_0878                ; Get ref-alien info and pointer to storage
        sty     ,x                      ; Hold the ref-alien screen coordinates
        stb     -1,x                    ; Store ref-alien's delta (direction)
        jsr     copy_ram_mirror         ; Copy RAM mirror (getting ready to switch players)
        puls    a                       ; Restore active player MSB
        rora                            ; Player 1?
        lda     #>byte_0_2100           ; Player 1 data pointer
        ldb     #0                      ; Cocktail bit=0 (player 1)
        bcc     1$                      ; It was player one ... keep data for player 2
        ldb     #(1<<5)                 ; Cocktail bit=1 (player 2)
        lda     #>byte_0_2200           ; Player 2 data pointer
1$:     sta     player_data_msb         ; Change players 
        jsr     two_sec_delay           ; Two second delay
        clr     obj0_timer_lsb          ; Clear the player-object timer (player can move instantly after switching players)
;       ld      a,b
;       out     (sound2),a
        inca                            ; Fleet sound 1 (first tone)
;       ld      (soundport5),a
        jsr     clear_playfield         ; Clear center window
        jsr     remove_ship             ; Remove a ship and update indicators
        jmp     loc_07F9                ; Tell the players that the switch has been made
; $032C
loc_032C:
        jsr     remove_ship             ; Remove a ship and update indicators
        jmp     loc_0817                ; Continue into game loop
; $0332
loc_0332:
        jsr     remember_shields_1      ; Remember the shields for player 1
        bra     loc_02F8                ; Back to switching-players above

; $033B
; Player not blowing up ... handle inputs
loc_033B:
        ldx     #player_ok              ; Player OK flag
        lda     #1                      ; Flag 1 ... 
        sta     ,x+                     ; ... player is OK. 2069
        tst     ,x                      ; Alien shots enabled? Set flags
        bra     loc_03B0                ; Continue
; $0346
loc_0346:
        leax    -1,x                    ; 2069
        lda     #1
        sta     ,x                      ; Enable alien fire
; $034A
loc_034A:
        lda     player_xr               ; Current player coordinates
        sta     *z80_b                  ; Hold it
        tst     game_mode               ; Are we in game mode?
        bne     1$                      ; Yes ... use switches as player controls
        lda     next_demo_cmd           ; Get demo command
        rora                            ; Is it right?
        bcs     move_player_right       ; Yes ... do right
        rora                            ; Is it left?
        bcs     move_player_left        ; Yes ... do left
        bra     loc_036F                ; Skip over movement (draw player and out)
; $0363
; Player is in control
; original code used ROLA/JP C to test bits
1$:     jsr     read_inputs             ; Read active player controls
        bita    #INP_RIGHT              ; Test for right button
        bne     move_player_right       ; Yes ... handle move right
        bita    #INP_LEFT               ; Test for left button
        bne     move_player_left        ; Yes ... handle move left
; $036F
loc_036F:
; Draw player sprite
        ldx     #plyr_spr_pic_m         ; Active player descriptor
        jsr     read_desc               ; Load 5 byte sprite descriptor in order: EDLHB
        jsr     conv_to_scr             ; Convert HL to screen coordinates
        jsr     draw_simp_sprite        ; Draw player
        clr     obj0_timer_extra        ; Clear the task timer. Nobody changes this but it could have ...
        rts                             ; ... been speed set for the player with a value other than 0 (not XORA)

; $0381
; Handle player moving right
move_player_right:
        lda     *z80_b                  ; Player coordinate
        cmpa    #0xd9                   ; At right edge?
        beq     loc_036F                ; Yes ... ignore this
        inca                            ; Bump X coordinate
        sta     player_xr               ; New X coordinate
        bra     loc_036F                ; Draw player and out

; $038E
; Handle player moving left
move_player_left:
        lda     *z80_b                  ; Player coordinate
        cmpa    #0x30                   ; At left edge
        beq     loc_036F                ; Yes ... ignore this
        deca                            ; Bump X coordinate
        sta     player_xr               ; New X coordinate
        bra     loc_036F                ; Draw player and out

; $039B
; Toggle the player's blowing-up sprite between two pictures and draw it
draw_player_die:
        inca                            ; Toggle blowing-up ...
        anda    #1                      ; ... player sprite (0,1,0,1)
        sta     player_alive            ; Hold current state
        rola                            ; *2
        rola                            ; *4
        rola                            ; *8
        rola                            ; *16
        ldx     #plr_blow_up_sprites    ; Base blow-up sprite location
        tfr     a,b                     ; Offset sprite ...
        abx                             ; ... pointer
        stx     plyr_spr_pic_m          ; New blow-up sprite picture
        bra     loc_036F                ; Draw new blow-up sprite and out
        
; $03B0
loc_03B0:
        bne     loc_034A                ; Alien shots enabled ... move player's ship, draw it, and out
        leax    1,x                     ; To 206A
        dec     ,x                      ; Time until aliens can fire
        bne     loc_034A                ; Not time to enable ... move player's ship, draw it, and out
        bra     loc_0346                ; Enable alien fire ... move player's ship, draw it, and out

; $03BB
; Game object 1: Move/draw the player shot
;
; This task executes at either mid-screen ISR (if it is on the top half of the non-rotated screen) or
; at the end-screen ISR (if it is on the bottom half of the screen).
game_obj_1:
        ldy     #obj1_coor_xr           ; Object's Yn coordiante
        jsr     comp_y_to_beam          ; Compare to screen-update location
        puls    x                       ; Pointer to task data
        bcs     1$                      ; Make sure we are in the right ISR
0$:     rts
1$:     leax    1,x                     ; Point to 2025 ... the shot status
        lda     ,x                      ; Get shot status
        beq     0$                      ; Return if no shot is active
        cmpa    #1                      ; Shot just starting (requested elsewhere)?
        beq     init_ply_shot           ; Yes ... go initiate shot
        cmpa    #2                      ; Progressing normally?
        beq     move_ply_shot           ; Yes ... go move it
        leax    1,x                     ; 2026
        cmpa    #3                      ; Shot blowing up (not because of alien)?
        bne     loc_042A                ; No ... try other options
; Shot blowing up because it left the playfield, hit a shield, or hit another bullet
        dec     ,x                      ; Decrement the timer
        beq     end_of_blowup           ; If done then
        lda     ,x                      ; Get timer value
        cmpa    #0x0f                   ; Starts at 10 ... first decrement brings us here
        bne     0$                      ; Not the first time ... explosion has been drawn
; Draw explosion first pass through timer loop
        pshs    x                       ; Hold pointer to data
        bsr     read_ply_shot           ; Read shot descriptor
        jsr     erase_shifted           ; Erase the sprite
        puls    x                       ; 2026 (timer flag)
        inc     2,x                     ; point to sprite LSB. Change 1C90 to 1C91
        dec     4,x                     ; Drop X coordinate ...
        dec     4,x                     ; ... by 2
        dec     3,x                     ; Drop Y ...
        dec     3,x                     ; ... coordinate ...
        dec     3,x                     ; ... by 3
        lda     #8
        sta     5,x                     ; 202B 8 bytes in size of sprite
        bsr     read_ply_shot           ; Read player shot structure
        jmp     draw_shifted_sprite     ; Draw sprite and out
        
; $03FA
init_ply_shot:
        inca                            ; Type is now ...
        sta     ,x                      ; ... 2 (in progress)
        lda     player_xr               ; Players Y coordinate
        adda    #8                      ; To center of player
        sta     obj1_coor_xr            ; Shot's Y coordinate
        bsr     read_ply_shot           ; Read 5 byte structure
        jmp     draw_shifted_sprite     ; Draw sprite and out

; $040A
move_ply_shot:
        bsr     read_ply_shot           ; Read the shot structure
        pshs    b                       ; Hold sprite size (in B)
        pshs    x,y                     ; Hold sprite coordinates, pointer to sprite image
        jsr     erase_shifted           ; Erase the sprite from the screen
        puls    d,y                     ; Restore coords, pointer to sprite image
        addb    shot_delta_x            ;  Move the shot ...
        tfr     d,x                     ; ... up the screen
        stb     obj1_coor_yr            ; Store shot's new X coordinate
        puls    b                       ; Restore size
        jsr     draw_spr_collision      ; Draw sprite with collision detection
        lda     collision               ; Test for collision
        beq     9$                      ; No collision ... out
; Collision with alien detected
1$:     sta     alien_is_exploding      ; Set to not-0 indicating an alien is blowing up
9$:     rts
        
; $042A
; Other shot-status options
loc_042A:
        cmpa    #5                      ; Alien explosion in progress?
        bne     end_of_blowup           ; No, erase the shot and remove it from duty
        rts        

; $0430
read_ply_shot:
        ldx     #obj1_image_msb         ; Read 5 byte sprite structure for ...
        jmp     read_desc               ; ... player shot

; $0436
end_of_blowup:
        bsr     read_ply_shot           ; Read the shot structure
        jsr     erase_shifted           ; Erase the player's shot
        ldx     #plyr_shot_status       ; Reinit ...
        ldy     #byte_0_1B00+0x25       ; ... shot structure ...
        ldb     #7                      ; ... from ...
        jsr     block_copy              ; ... ROM mirror
        ldx     sau_score_msb           ; Get pointer to saucer-score table
        leax    1,x                     ; Every shot explosion advances it one
        tfr     x,d                     ; Have we passed ...
        cmpb    #0x63                   ; ... the end at 1D63 (bug! this should be $64 to cover all 16 values)
        bcs     1$                      ; No .... keep it
        ldb     #0x54                   ; Wrap back around to 1D54
1$:     tfr     d,x
        stx     sau_score_msb           ; New score pointer
        ldd     shot_count_msb          ; Increments with every shot ...
        incb                            ; ... but only LSB ** ...
        std     shot_count_msb          ; ... used for saucer direction
        tst     saucer_active           ; Is saucer on screen?
        bne     9$                      ; Yes ... don't reset it
; Setup saucer direction for next trip
        lda     ,x                      ; Shot counter
        ldu     #0x0229                 ; Xr delta of 2 starting at Xr=29
        anda    #1                      ; Lowest bit set?
        bne     2$                      ; Yes ... use 2/29
        ldu     #0xfee0                 ; No ... Xr delta of -2 starting at Xr=E0
2$:     tfr     u,d
        ldx     #saucer_pri_loc_msb     ; Saucer descriptor ??? RIGHT????
        stb     ,x                      ; Store Xr coordinate
        leax    3,x                     ; Point to delta Xr
        sta     ,x                      ; Store delta Xr
9$:     rts
        
; $0476
; Game object 2: Alien rolling-shot (targets player specifically)
;
; The 2-byte value at 2038 is where the firing-column-table-pointer would be (see other
; shots ... next game objects). This shot doesn't use that table. It targets the player
; specifically. Instead the value is used as a flag to have the shot skip its first
; attempt at firing every time it is reinitialized (when it blows up).
;
; The task-timer at 2032 is copied to 2080 in the game loop. The flag is used as a
; synchronization flag to keep all the shots processed on separate interrupt ticks. This
; has the main effect of slowing the shots down.
;
; When the timer is 2 the squiggly-shot/saucer (object 4 ) runs.
; When the timer is 1 the plunger-shot (object 3) runs.
; When the timer is 0 this object, the rolling-shot, runs.
game_obj_2:
        puls    x                       ; Game object data
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_GREEN
        sta     PALETTE+1
.endif
        
        lda     byte_0_1B00+0x32        ; Restore delay from ... 
        sta     obj2_timer_extra        ; ... ROM mirror (value 2)
        ldx     rol_shot_c_fir_msb      ; Get pointer to column-firing table. All zeros?
        bne     1$                      ; No ... must be a valid column. Go fire.
        leax    -1,x                    ; Decrement the counter
        stx     rol_shot_c_fir_msb      ; Store new counter value (run the shot next time)
        rts
1$:     ldy     #rol_shot_status        ; Rolling-shot data structure
        lda     #0xf9                   ; Last picture of "rolling" alien shot
        jsr     to_shot_struct          ; Set code to handle rolling-shot
        lda     plu_shot_step_cnt       ; Get the plunger-shot step count
        sta     other_shot_1            ; Hold it
        lda     squ_shot_step_cnt       ; Get the squiggly-shot step count
        sta     other_shot_2            ; Hold it
        jsr     handle_alien_shot       ; Handle active shot structure
        ldx     #rol_shot_status        ; Rolling-shot data structure
        lda     a_shot_blow_cnt         ; Blow up counter. Test if shot has cycled through blowing up
        lbne    from_shot_struct        ; If shot is still running, copy the updated data and out

; $04AB
reset_shot:
        ldy     #byte_0_1B00+0x30       ; Reload ...
        ldx     #obj2_timer_msb         ; ... object ...
        ldb     #0x10                   ; ... structure ...
        jmp     block_copy              ; ... from ROM mirror and out

; $04B6
; Game object 3: Alien plunger-shot
; This is skipped if there is only one alien left on the screen.
game_obj_3:
        puls    x                       ; Game object data
        tst     skip_plunger            ; One alien left? Skip plunger shot?
        beq     1$                      
0$:     rts                             ; Yes. Only one alien. Skip this shot.
1$:     lda     shot_sync               ; Sync flag (copied from GO-2's timer value)
        cmpa    #1                      ; GO-2 and GO-4 are idle?
        bne     0$                      ; No ... only one shot at a time
        ldy     #plu_shot_status        ; Plunger alien shot data structure
        lda     #0xed                   ; Last picture of "plunger" alien shot
        jsr     to_shot_struct          ; Copy the plunger alien to the active structure
        lda     rol_shot_step_cnt       ; Step count from rolling-shot
        sta     other_shot_1            ; Hold it
        lda     squ_shot_step_cnt       ; Step count from squiggly shot
        sta     other_shot_2            ; Hold it
        jsr     handle_alien_shot       ; Handle active shot structure
        lda     a_shot_c_fir_lsb        ; LSB of column-firing table
        cmpa    #0x10                   ; Been through all entries in the table?
        bcs     2$                      ; Not yet ... table is OK
        lda     byte_0_1B00+0x49        ; Been through all ..
        sta     a_shot_c_fir_lsb        ; ... so reset pointer into firing-column table
2$:     ldx     #plu_shot_status        ; Plunger shot data
        lda     a_shot_blow_cnt         ; Get the blow up timer. ; Zero means shot is done
        bne     from_shot_struct        ; If shot is still running, go copy the updated data and out
        ldy     #byte_0_1B00+0x40       ; Reload ...
        ldx     #obj3_timer_msb         ; ... object ...
        ldb     #0x10                   ; ... structure ...
        jsr     block_copy              ; ... from mirror
        lda     num_aliens              ; Number of aliens on screen
        deca                            ; Is there only one left?
        bne     3$                      ; No ... move on
        lda     #1                      ; Disable plunger shot ...
        sta     skip_plunger            ; ... when only one alien remains
3$:     ldx     a_shot_c_fir_msb        ; Set the plunger shot's ...
        jmp     loc_067E                ; ... column-firing pointer data

; Game task 4 when splash screen alien is shooting extra "C" with a squiggly shot
loc_050E:
        puls    x                       ; Ignore the task data pointer passed on stack
; GameObject 4 comes here if processing a squiggly shot
loc_050F:
        ldy     #squ_shot_status        ; Squiggly shot data structure
        lda     #<squiggly_shot_last
        bsr     to_shot_struct          ; Copy squiggly shot to
        lda     plu_shot_step_cnt       ; Get plunger ...
        sta     other_shot_1            ; ... step count
        lda     rol_shot_step_cnt       ; Get rolling ...
        sta     other_shot_2            ; ... step count
        bsr     handle_alien_shot       ; Handle active shot structure
        lda     a_shot_c_fir_lsb        ; LSB of column-firing table pointer
        cmpa    #0x15                   ; Have we processed all entries?
        bcs     1$                      ; No ... don't reset it
        lda     squ_shot_c_fir_lsb      ; Reset the pointer ...
        sta     a_shot_c_fir_lsb        ; ... back to the start of the table
1$:     ldx     #squ_shot_status        ; Squiggly shot data structure
        tst     a_shot_blow_cnt         ; Check to see if squiggly shot is done. 0 means blow-up timer expired
        bne     from_shot_struct        ; If shot is still running, go copy the updated data and out
        
; $053E
; Shot explosion is over. Remove the shot.
        ldy     #byte_0_1B00+0x50       ; Reload
        ldx     #obj4_timer_msb         ; ... object ...
        ldb     #0x10                   ; ... structure ...
        jsr     block_copy              ; ... from mirror
        ldx     a_shot_c_fir_msb        ; Copy pointer to column-firing table ...
        stx     squ_shot_c_fir_msb      ; ... back to data structure (for next shot)
        rts

; $0550
to_shot_struct:
        sta     shot_pic_end            ; LSB of last byte of last picture in sprite
        ldx     #a_shot_status          ; Destination is the shot-structure
        ldb     #11                     ; 11 bytes
        jmp     block_copy              ; Block copy and out

; $055B
from_shot_struct:
        ldy     #a_shot_status          ; Source is the shot-structure
        ldb     #11                     ; 11 bytes
        jmp     block_copy              ; Block copy and out

; $0563
; Each of the 3 shots copy their data to the 2073 structure (0B bytes) and call this.
; Then they copy back if the shot is still active. Otherwise they copy from the mirror.
;
; The alien "fire rate" is based on the number of steps the other two shots on the screen 
; have made. The smallest number-of-steps is compared to the reload-rate. If it is too
; soon then no shot is made. The reload-rate is based on the player's score. The MSB
; is looked up in a table to get the reload-rate. The smaller the rate the faster the
; aliens fire. Setting rate this way keeps shots from walking on each other.
handle_alien_shot:
        ldx     #a_shot_status          ; Start of active shot structure
        lda     ,x                      ; Get the shot status
        anda    #0x80                   ; Is the shot active?
        bne     loc_05C1                ; Yes ... go move it
        lda     isr_splash_task         ; ISR splash task
        cmpa    #(1<<2)                 ; Shooting the "C" ?
        pshs    cc
        lda     enable_alien_fire       ; Alien fire enabled flag
        puls    cc
        beq     loc_05B7                ; We are shooting the extra "C" ... just flag it active and out
        tsta                            ; Is alien fire enabled?
        beq     9$                      ; No ... don't start a new shot
        leax    1,x                     ; 2074 step count of current shot
        clr     ,x                      ; clear the step count
; Make sure it isn't too soon to fire another shot
        lda     other_shot_1            ; Get the step count of the 1st "other shot"
        beq     1$                      ; Any steps made? No ... ignore this count
        sta     *z80_b                  ; Shuffle off step count
        lda     a_shot_reload_rate      ; Get the reload rate (based on MSB of score)
        cmpa    *z80_b                  ; Too soon to fire again?
        bcc     9$                      ; Yes ... don't fire
; $0589        
1$:     lda     other_shot_2            ; Get the step count of the 2nd "other shot"
        beq     2$                      ; Any steps made? No steps on any shot ... we are clear to fire
        sta     *z80_b                  ; Shuffle off step count
        lda     a_shot_reload_rate      ; Get the reload rate (based on MSB of score)
        cmpa    *z80_b                  ; Too soon to fire again?
        bcs     2$
9$:     rts                             ; Yes ... don't fire
; $0596
2$:     leax    1,x                     ; 2075
        tst     ,x                      ; Get tracking flag. Does this shot track the player?
        lbeq    loc_061B                ; Yes ... go make a tracking shot
        ldx     a_shot_c_fir_msb        ; Column-firing table
        ldb     ,x+                     ; Get next column to fire from. Bump the ...
        stb     *z80_c
        stx     a_shot_c_fir_msb        ; ... pointer into column table
loc_05A5:        
        jsr     find_in_column          ; Find alien in target column
        bcs     1$
        rts                             ; No alien is alive in target column ... out
1$:     jsr     get_alien_coords        ; Get coordinates of alien (lowest alien in firing column)
        lda     *z80_c                  ; Offset ...
        adda    #7                      ; ... Y by 7
        ldb     *z80_l                  ; Offset ...
        subb    #10                     ; ... X down 10
        std     alien_shot_xr           ; Set shot coordinates below alien
; $05B7        
loc_05B7:
        ldx     #a_shot_status          ; Alien shot status
        lda     ,x                      ; Get the status
        ora     #0x80                   ; Mark this shot ...
        sta     ,x+                     ; ... as actively running. 2074 step count
        inc     ,x                      ; Give this shot 1 step (it just started)
        rts

; $05C1
; Move the alien shot
loc_05C1:
        ldy     #alien_shot_xr          ; Alien-shot Y coordinate
        jsr     comp_y_to_beam          ; Compare to beam position
        bcs     1$
        rts                             ; Not the right ISR for this shot
1$:     leax    1,x                     ; 2073 status
        lda     ,x                      ; Get shot status
        anda    #1                      ; Bit 0 is 1 if blowing up
        bne     shot_blowing_up         ; Go do shot-is-blowing-up sequence
        leax    1,x                     ; 2074 step count
        inc     ,x                      ; Count the steps (used for fire rate)
        jsr     sub_0675                ; Erase shot
        lda     a_shot_image_lsb        ; Get LSB of the image pointer
        adda    #3                      ; Next set of images
        ldx     #shot_pic_end           ; End of image
        cmpa    ,x                      ; Have we reached the end of the set?
        bcs     2$                      ; No ... keep it
        suba    #12                     ; Back up to the 1st image in the set
2$:     sta     a_shot_image_lsb        ; New LSB image pointer
        lda     alien_shot_yr           ; Get shot's Y coordinate
        adda    alien_shot_delta        ; Add delta to shot's coordinate
        sta     alien_shot_yr           ; New shot Y coordinate
        jsr     sub_066C                ; Draw the alien shot
        lda     alien_shot_yr           ; Shot's Y coordinate
        cmpa    #0x15                   ; Still in the active playfield?
        bcs     3$                      ; No ... end it
        tst     collision               ; Did shot collide with something?
        beq     9$                      ; No ... we are done here
        lda     alien_shot_yr           ; Shot's Y coordinate
        cmpa    #0x1e                   ; Is it below player's area?
        bcs     3$                      ; Yes ... end it
        cmpa    #0x27                   ; Is it above player's area?
        bcc     3$                      ; Yes ... end it
        clr     player_alive            ; Flag that player has been struck
; $0612        
3$:     lda     a_shot_status           ; Flag to ...
        ora     #1                      ; ... start shot ...
        sta     a_shot_status           ; ... blowing up
9$:     rts                

; $061B
; Start a shot right over the player
loc_061B:
        lda     player_xr               ; Player's X coordinate
        adda    #8                      ; Center of player
        sta     *z80_h
        jsr     find_column             ; Find the column
        lda     *z80_c                  ; Get the column right over player
        cmpa    #12                     ; Is it a valid column?
        lbcs    loc_05A5                ; Yes ... use what we found
        lda     #11                     ; Else use ...
        sta     *z80_c                  ; ... as far over as we can
        jmp     loc_05A5

; $062F        
; C contains the target column. Look for a live alien in the column starting with
; the lowest position. Return C=1 if found ... HL/X points to found slot.
find_in_column:
        dec     *z80_c                  ; Column that is firing
        lda     player_data_msb         ; Player's MSB (21xx or 22xx)
        ldb     *z80_c
        tfr     d,x
        lda     #5                      ; 5 rows of aliens
        sta     *z80_d
1$:     tst     ,x                      ; Get alien's status
        SCF                             ; In case not 0
        bne     9$                      ; Alien is alive? Yes ... return
        ldb     #11                     ; Jump to same column on next row of rack (+11 aliens per row)
        abx                             ; New alien index
        dec     *z80_d                  ; Tested all rows?
        bne     1$                      ; No ... keep looking for a live alien up the rack
        CCF
9$:     rts                             ; Didn't find a live alien. Return with C=0.

; $0644
; Alien shot is blowing up
shot_blowing_up:
        ldx     #a_shot_blow_cnt        ; Blow up timer
        dec     ,x                      ; Decrement the value
        lda     ,x                      ; Get the value
        cmpa    #3                      ; First tick, 4, we draw the explosion
        bne     1$                      ; After that just wait
        bsr     sub_0675                ; Erase the shot
        ldx     #a_shot_explo           ; Alien shot ...
        stx     a_shot_image_msb        ; ... explosion sprite
        ldx     #alien_shot_xr          ; Alien shot Y
        dec     ,x                      ; Left two for ...
        dec     ,x                      ; ... explosion
        leax    1,x                     ; Point alien shot X
        dec     ,x                      ; Up two for ...
        dec     ,x                      ; ... explosion
        lda     #6                      ; Alien shot descriptor ...
        sta     alien_shot_size         ; ... size 6
        bra     sub_066C                ; Draw alien shot explosion
; $0667
1$:     tsta                            ; Have we reached 0?
        beq     sub_0675                ; Erase the explosion and out
        rts                             ; No ... keep waiting
; $066C
sub_066C:
        ldx     #a_shot_image_msb       ; Alien shot descriptor
        jsr     read_desc               ; Read 5 byte structure
        jmp     draw_spr_collision      ; Draw shot and out
; $0675
sub_0675:
        ldx     #a_shot_image_msb       ; Alien shot descriptor
        jsr     read_desc               ; Read 5 byte structure
        jmp     erase_shifted           ; Erase the shot and out

loc_067E:
        stx     plu_shot_c_fir_msb      ; From 50B, update ...
        rts                             ; ... column-firing table pointer and out
                        
; $0682
game_obj_4:
; Game object 4: Flying Saucer OR squiggly shot
;
; This task is shared by the squiggly-shot and the flying saucer. The saucer waits until the 
; squiggly-shot is over before it begins.
        puls    x                       ; Pull data pointer from the stack (not going to use it)
        lda     shot_sync               ; Sync flag (copied from GO-2's timer value)
        cmpa    #2                      ; Are GO-2 and GO-3 idle?
        beq     1$
0$:     rts                             ; No ... only one at a time
1$:     ldx     #saucer_start           ; Time-till-saucer flag
        tst     ,x                      ; Is it time for a saucer?
        lbeq    loc_050F                ; No ... go process squiggly shot
        tst     squ_shot_step_cnt       ; Is there a squiggly shot going?
        lbne    loc_050F                ; Yes ... go handle squiggly shot
; $0698
        leax    1,x                     ; Saucer on screen flag
        tst     ,x                      ; (2084) Is the saucer already on the screen?
        bne     2$                      ; Yes ... go handle it
        lda     num_aliens              ; Number of aliens remaining
        cmpa    #8                      ; Less than ...
        lbcs    loc_050F                ; ... 8 ... no saucer
        lda     #1                      
        sta     ,x                      ; (2084) The saucer is on the screen
        lbsr    sub_073C                ; Draw the flying saucer
; $06AB
2$:     ldy     #saucer_pri_loc_msb     ; Saucer's Y coordinate
        jsr     comp_y_to_beam          ; Compare to beam position
        bcc     0$                      ; Not the right ISR for moving saucer
; $06B2
        ldx     #saucer_hit             ; Saucer hit flag
        tst     ,x                      ; Has saucer been hit?
        bne     3$                      ; Yes ... don't move it
; $06BA
        ldx     #saucer_pri_loc_msb     ; Saucer's structure
        lda     ,x                      ; Get saucer's Y coordinate
        leax    3,x                     ; Bump to delta Y
        adda    ,x                      ; Move saucer
        sta     saucer_pri_loc_msb      ; New coordinate
        bsr     sub_073C                ; Draw the flying saucer
        ldx     #saucer_pri_loc_msb     ; Saucer's structure
        lda     ,x                      ; Y coordinate
        cmpa    #0x28                   ; Too low? End of screen?
        bcs     4$                      ; Yes ... remove from play
        cmpa    #0xe1                   ; Too high? End of screen?
        bcc     4$                      ; Yes ... remove from play
        rts        
; $06D6        
3$:     ldb     #0xfe                   ; Turn off ...
        jsr     sound_bits_3_off        ; ... flying saucer sound
        leax    1,x                     ; (2086) show-hit timer
        dec     ,x                      ; Count down show-hit timer
        lda     ,x                      ; Get current value
        cmpa    #0x1f                   ; Starts at 20 ... is this the first tick of show-hit timer?
        beq     loc_074B                ; Yes ... go show the explosion
        cmpa    #0x18                   ; A little later ...
        beq     loc_070C                ; ... show the score besides the saucer and add it
        tsta                            ; Has timer expired?
        bne     0$                      ; No ... let it run
        ldb     #0xef                   ; 1110_1111 (mask off saucer hit sound)
        stb     *z80_b
        ldx     #sound_port_5           ; Get current ...
        lda     ,x                      ; ... value of port 5 sound
        anda    *z80_b                  ; Mask off the saucer-hit sound
        sta     ,x                      ; Set the new value
        anda    #0x20                   ; All sound off but cocktail cabinet bit
;       out     (sound2),a
; $06F9
4$:     bsr     sub_0742                ; Convert pixel pos from descriptor to HL screen and shift
        jsr     clear_small_sprite      ; Clear a one byte sprite at HL
        ldx     #saucer_start           ; Saucer structure
        ldb     #10                     ; 10 bytes in saucer structure
        bsr     sub_075F                ; Re-initialize saucer structure
; $0707
loc_0707:
        ldb     #0xfe                   ; Turn off UFO ...
        jmp     sound_bits_3_off        ; ... sound and out
; $070C
loc_070C:
        lda     #1                      ; Flag the score ...
        sta     adjust_score            ; ... needs updating
        ldx     sau_score_msb           ; Saucer score table
        ldb     ,x                      ; Get score for this saucer
        stb     *z80_b                  ; for 6809 CMPA
        lda     #4                      ; There are only 4 possibilities
        sta     *z80_c
        ldx     #byte_0_1D50            ; Possible scores table
        ldy     #byte_0_1D4C            ; Print strings for each score
1$:     lda     ,y                      ; Find ...
        cmpa    *z80_b                  ; ... the ...
        beq     2$                      ; ... print ...
        leax    1,x                     ; ... string ...
        leay    1,y                     ; ... for ...
        dec     *z80_c                  ; ... the ...
        bne     1$                      ; ... score
2$:     lda     ,x                      ; Get LSB of message (MSB is 2088 which is 1D)
        sta     saucer_pri_pic_lsb      ; Message's LSB (_50=1D94 100=1D97 150=1D9A 300=1D9D)
        lda     #16
        ldb     *z80_b
        mul
        std     score_delta_msb         ; Add score for hitting saucer (015 becomes 150 in BCD).
        bsr     sub_0742                ; Get the flying saucer score descriptor
        jmp     loc_08F1                ; Print the three-byte score and out
; $073C
sub_073C:
        bsr     sub_0742                ; Draw the ...
        jmp     draw_simp_sprite        ; ... flying saucer

; $0742
sub_0742:
        ldx     #saucer_pri_pic_msb     ; Read flying saucer ...
        jsr     read_desc               ; ... structure
        jmp     conv_to_scr             ; Convert pixel number to screen and shift and out
        
; $074B
loc_074B:
        ldb     #0x10                   ; Saucer hit sound bit
        ldx     #sound_port_5           ; Current state of sounds
        lda     ,x                      ; OR ...
        ora     *z80_b                  ; ... in ...
        sta     ,x                      ; ... saucer-hit sound
        jsr     sub_1770                ; Turn off fleet sound and start saucer-hit
        ldx     #sprite_saucer_exp      ; Sprite for saucer blowing up
        stx     saucer_pri_pic_msb      ; Store it in structure
        bra     sub_073C                ; Draw the flying saucer
; $075F
sub_075F:
        ldy     #byte_0_1B83            ; Data for saucer (702 sets count to 0A)
        jmp     block_copy              ; Reset saucer object data
        
; $0765
; Wait for player 1 start button press
wait_for_start:
        lda     #1                      ; Tell ISR that we ...
        sta     wait_start_loop         ; ... have started to wait
        lds     #stack                  ; Reset stack
				lda			#>dp_base
				tfr			a,dp
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI
        jsr     loc_1979                ; Suspend game tasks
        jsr     clear_playfield         ; Clear center window
        LDX_VRAM  0xC13
        ldy     #message_push           ; "PRESS"
        ldb     #4                      ; Message length
        jsr     print_message           ; Print it
loc_077F:        
        LDX_VRAM  0x0410                ; Screen coordinates
        ldb     #20                     ; Message length
        lda     num_coins               ; Number of credits
        deca                            ; Set flags
        lbne    loc_0857                ; Take 1 or 2 player start
        ldy     #message_1_only         ; "ONLY 1PLAYER BUTTON "
        jsr     print_message           ; Print message
;       in      a,(inp1)
;       and     $04
;       jp      z,$077f
        ldx     #KEYROW                 ; assuming HL/X is 'free'
        lda     #~(1<<1)
        sta     2,x
        lda     ,x                      ; Read coin switch
        bita    #(1<<4)                 ; 1Player start button? (keybd '1')
        bne     loc_077F                ; No ... wait for button or credit

; $0798
; START NEW GAME
new_game:
; 1 Player start
        ldb     #0x99                   ; Essentially a -1 for DAA
        clra                            ; Clear two player flag
; $079B
; 2 player start sequence enters here with a=1 and B=98 (-2)
loc_079B:
        sta     two_players             ; Set flag for 1 or 2 players
        lda     num_coins               ; Number of credits
        stb     *z80_b
        adda    *z80_b                  ; Take away credits
        daa                             ; Convert back to DAA
        sta     num_coins               ; New credit count
        jsr     draw_num_credits        ; Display number of credits
        ldx     #0                      ; Score of 0000
        stx     p1_scor_m               ; Clear player-1 score
        stx     p2_scor_m               ; Clear player-2 score
        jsr     sub_1925                ; Print player-1 score
        jsr     sub_192B                ; Print player-2 score
        jsr     disable_game_tasks      ; Disable game tasks
        ldd     #0x0101                 ; Two bytes 1, 1
        sta     game_mode               ; 20EF=1 ... game mode
        std     player1_alive           ; 20E7 and 20E8 both one ... players 1 and 2 are alive
        std     player1_ex              ; Extra-ship is available for player-1 and player-2
        jsr     draw_status             ; Print scores and credits
        jsr     draw_shield_pl1         ; Draw shields for player-1
        jsr     draw_shield_pl2         ; Draw shields for player-2
        jsr     get_ships_per_cred      ; Get number of ships from DIP settings
        sta     p1_ships_rem            ; Player-1 ships
        sta     p2_ships_rem            ; Player-2 ships
        jsr     sub_00D7                ; Set player-1 and player-2 alien racks going right
        clra
        sta     p1_rack_cnt             ; Player 1 is on first rack of aliens
        sta     p2_rack_cnt             ; Player 2 is on first rack of aliens
        jsr     init_aliens             ; Initialize 55 aliens for player 1
        jsr     init_aliens_p2          ; Initialize 55 aliens for player 2
        ldx     #0x3878                 ; Screen coordinates for lower-left alien
        stx     p1_ref_alien_x          ; Initialize reference alien for player 1
        stx     p2_ref_alien_xr         ; Initialize reference alien for player 2
        jsr     copy_ram_mirror         ; Copy ROM mirror to RAM (2000 - 20C0)
        jsr     remove_ship             ; Initialize ship hold indicator
; $07F9
loc_07F9:
        jsr     prompt_player           ; Prompt with "PLAY PLAYER "
        jsr     clear_playfield         ; Clear the playfield
        clra
        sta     isr_splash_task         ; Disable isr splash-task animation
; $0804
loc_0804:        
        jsr     draw_bottom_line        ; Draw line across screen under player
        lda     player_data_msb         ; Current player
        rora                            ; Right bit tells all
        bcs     loc_0872                ; Go do player 1
; $080E
        jsr     restore_shields_2       ; Restore shields for player 2
        jsr     draw_bottom_line        ; Draw line across screen under player
loc_0814:        
        jsr     init_rack               ; Initialize alien rack for current player
loc_0817:        
        jsr     enable_game_tasks       ; Enable game tasks in ISR
        ldb     #0x20                   ; Enable ...
        jsr     sound_bits_3_on         ; ... sound amplifier

; $081F
; GAME LOOP
1$:     jsr     plr_fire_or_demo        ; Initiate player shot if button pressed
        jsr     plyr_shot_and_bump      ; Collision detect player's shot and rack-bump
        jsr     count_aliens            ; Count aliens (count to 2082)
        jsr     adjust_score_fn         ; Adjust score (and print) if there is an adjustment
        tst     num_aliens              ; Number of live aliens. All aliens gone?
        lbeq    loc_09EF                ; Yes ... end of turn
        jsr     a_shot_reload_rate_fn   ; Update alien-shot-rate based on player's score
        jsr     sub_0935                ; Check (and handle) extra ship award
        jsr     speed_shots             ; Adjust alien shot speed
        jsr     shot_sound              ; Shot sound on or off with 2025
        jsr     sub_0A59                ; Check if player is hit
        beq     2$                      ; No hit ... jump handler
        ldb     #0x04                   ; Player hit sound
        jsr     sound_bits_3_on         ; Make explosion sound
2$:     jsr     fleet_delay_ex_ship     ; Extra-ship sound timer, set fleet-delay, play fleet movement sound
;       out     (watchdog),a
        jsr     ctrl_saucer_sound       ; Control saucer sound
        bra     1$                      ; Continue game loop

; $0857
; Test for 1 or 2 player start button press
loc_0857:
        ldy     #message_b_1_or_2       ; "1 OR 2PLAYERS BUTTON"
        jsr     print_message           ; Print message
        ldb     #0x98                   ; -2 (take away 2 credits)
;       in      a,(inp1)
;       rrca
;       rrca
;       jp      c,$086D                 ; 2 player button pressed ... do it
;       rrca
;       jp      c,new_game              ; One player start ... do it
        ldx     #KEYROW                 ; assuming HL/X is 'free'
        lda     #~(1<<2)                ; Column 2 ('2')
        sta     2,x
        lda     ,x                      ; Read player controls
        bita    #(1<<4)                 ; 2 player button pressed? (keybd '2')
        beq     loc_086D                ; Yes ... do it
        lda     #~(1<<1)                ; Column 1 ('1')
        sta     2,x
        lda     ,x                      ; Read player controls
        bita    #(1<<4)                 ; One player start? (keybd '1')
        lbeq    new_game                ; Yes ... do it
        jmp     loc_077F                ; Keep waiting on credit or button

; $086D
; 2 PLAYER START
loc_086D:
        lda     #1                      ; Flag 2 player game
        jmp     loc_079B                ; Continue normal startup

; $0872
loc_0872:
        jsr     restore_shields_1       ; Restore shields for player 1
        bra     loc_0814                ; Continue in game loop

; $0878
sub_0878:
        ldb     ref_alien_dxr           ; Alien deltaY
        ldy     ref_alien_xr            ; Alien coordinates
        bra     get_al_ref_ptr          ; HL/X is 21FC or 22FC and out

; $0886     
get_al_ref_ptr:
        pshs    b
        lda     player_data_msb         ; Player data MSB (21 or 22)
        ldb     #0xfc                   ; 21FC or 22FC ... alien coordinates
        tfr     d,x
        puls    b
        rts

; $088D
; Print "PLAY PLAYER " and blink score for 2 seconds.
prompt_player:
        LDX_VRAM  0x0711                ; Screen coordinates
        ldy     #message_p1             ; Message "PLAY PLAYER<1>"
        ldb     #14                     ; 14 bytes in message
        bsr     print_message           ; Print the message
        lda     player_data_msb         ; Get the player number
        rora                            ; C will be set for player 1
        lda     #0x1c                   ; The "2" character
        LDX_VRAM  0x1311                ; Replace the "<1>" with "<2">
        bcs     1$
        bsr     draw_char               ; If player 2 ... change the message
1$:     lda     #176                    ; Delay of 176 (roughly 2 seconds)
        sta     isr_delay               ; Set the ISR delay value
2$:     lda     isr_delay               ; Get the ISR delay value
        bne     3$
        rts                             ; Has the 2 second delay expired? Yes ... done
3$:     anda    #4                      ; Every 4 ISRs ...
        bne     4$                      ; ... flash the player's score
        jsr     sub_09CA                ; Get the score descriptor for the active player
        jsr     draw_score              ; Draw the score
        bra     2$                      ; Back to the top of the wait loop
4$:     ldb     #32                     ; 32 rows (4 characters * 8 bytes each)
        LDX_VRAM  0x031c                ; Player-1 score on the screen
        lda     player_data_msb         ; Get the player number
        rora                            ; C will be set for player 1
        bcs     5$                      ; We have the right score coordinates
        LDX_VRAM  0x151c                ; Use coordinates for player-2's score
5$:     jsr     clear_small_sprite      ; Clear a one byte sprite at HL/X
        bra     2$                      ; Back to the top of the wait loop
                
; $08D1
get_ships_per_cred:
; Get number of ships from DIP settings
        lda     dips                    ; DIP settings
        anda    #DIP_LIVES_MASK         ; Get number of ships
        adda    #3                      ; From 3-6
        rts

; $08D8
; With less than 9 aliens on the screen the alien shots get a tad bit faster. Probably
; because the advancing rack can catch them.
speed_shots:
        lda     num_aliens              ; Number of aliens on screen
        cmpa    #9                      ; More than 8?
        bcc     9$                      ; Yes ... leave shot speed alone
        lda     #-4                     ; Normally FF (-1) ... now FB (-4)
        sta     alien_shot_delta        ; Speed up alien shots
9$:     rts        

; $08E4
loc_08E4:
        tst     two_players             ; Number of players
        beq     1$
        rts                             ; Skip if two player
1$:     LDX_VRAM  0x151c                ; Player 2's score
        LDB_SPRW  32                    ; 32 rows is 4 digits * 8 rows each
        jmp     clear_small_sprite      ; Clear a one byte sprite (32 rows long) at HL/X

; $08F1
loc_08F1:
        ldb     #3                      ; Length of saucer-score message ... fall into print
       
; $08F3
; Print a message on the screen
; HL/X = coordinates
; DE/Y = message buffer
; C/B = length
print_message:
        lda     ,y+                     ; get character
        pshs    b,y                     ; Preserve
        bsr     draw_char               ; Print character
        puls    b,y                     ; Restore
        decb                            ; All done?
        bne     print_message           ; Print all of message
        rts

; $08FF
; Get pointer to 8 byte sprite number in A and
; draw sprite on screen at HL/X
draw_char:
        ldy     #loc_1E00               ; Character set
        ldb     #8
        mul                             ; D=offset
        leay    d,y                     ; Get pointer to sprite
        LDB_SPRW  8                     ; 8 bytes each
; hit watchdog
        jmp     draw_simp_sprite        ; To screen

; $0913
time_to_saucer:
        lda     ref_alien_yr            ; Reference alien's X coordinate
        cmpa    #0x78                   ; Don't process saucer timer ... ($78 is 1st rack Yr)
        bcc     9$                      ; ... unless aliens are closer to bottom
        ldx     till_saucer_msb         ; Time to saucer
        bne     1$                      ; Is it time for a saucer? No ... skip flagging
        ldx     #0x600                  ; Reset timer to 600 game loops
        lda     #1                      ; Flag a ...
        sta     saucer_start            ; ... saucer sequence
1$:     leax    -1,x                    ; Decrement the ...
        stx     till_saucer_msb         ; ... time-to-saucer
9$:     rts
        
; $092E
; Get number of ships for active player
sub_092E:
        jsr     get_player_data_ptr     ; HL/X points to player data
        tfr     x,d
        ldb     #0xff                   ; last byte
        tfr     d,x
        lda     ,x                      ; Get number of ships
        rts

; $0935
; Award extra ship if score has reached ceiling
sub_0935:
        jsr     cur_ply_alive           ; Get descriptor of sorts
        leax    -2,x                    ; Back up two bytes
        tst     ,x                      ; Has extra ship already been awarded?
        bne     1$                      
0$:     rts                             ; Yes ... ignore
1$:     ldb     #0x15                   ; Default 1500
;       in      a,(inp2)
        lda     dips
        anda    #DIP_BONUS_LIFE         ; Extra ship at 1000 or 1500
        beq     2$                      ; 0=1500
        ldb     #0x10                   ; Awarded at 1000
2$:     stb     *z80_b
        jsr     sub_09CA                ; Get score descriptor for active player
        lda     ,x                      ; MSB of score to accumulator
        cmpa    *z80_b                  ; Time for an extra ship?
        bcs     0$                      ; No ... out
        bsr     sub_092E                ; Get pointer to number of ships
        inc     ,x                      ; Bump number of ships
        lda     ,x                      ; Get the new total
        pshs    a                       ; Hang onto it for a bit
        LDX_VRAM  0x0101                ; Screen coords for ship hold
3$:     leax    512,x                   ; Bump to next
        deca                            ; ... spot
        bne     3$                      ; Find spot for new ship
        LDB_SPRW  16                    ; 16 byte sprite
        ldy     #player_sprite          ; Player sprite
        jsr     draw_simp_sprite        ; Draw the sprite
        puls    a                       ; Restore the count
        inca                            ; +1
        jsr     loc_1A8B                ; Print the number of ships
        jsr     cur_ply_alive           ; Get descriptor for active player of some sort
        leax    -2,x                    ; Back up two bytes
        clr     ,x                      ; Flag extra ship has been awarded
        lda     #0xff                   ; Set timer ...
        sta     extra_hold              ; ... for extra-ship sound
        ldb     #0x10                   ; Make sound ...
        jmp     sound_bits_3_on         ; ... for extra man

; $097C
alien_score_value:
        ldx     #alien_scores           ; Table for scores for hitting alien
        cmpa    #2                      ; 0 or 1 (lower two rows) ...
        bcs     9$                      ; ... return HL points to value 10
        leax    1,x                     ; next value
        cmpa    #4                      ; 2 or 3 (middle two rows) ...
        bcs     9$                      ; ... return HL points to value 20
        leax    1,x                     ; Top row return HL points to value 30
9$:     rts        

; $0988
; Adjust the score for the active player. 20F1 is 1 if there is a new value to add.
; The adjustment is in 20F2,20F3. Then print the score.
adjust_score_fn:
        bsr     sub_09CA                ; Get score structure for active player
        tst     adjust_score            ; Does the score need increasing?
        bne     1$
        rts                             ; No ... done
1$:     clr     adjust_score            ; Mark score as adjusted
        ldy     score_delta_msb         ; Get requested adjustment
        sty     *z80_d
        lda     1,x                     ; Add adjustment ...
        adda    *z80_e                  ; ... first byte
        daa                             ; Adjust it for BCD
        sta     1,x                     ; Store new LSB
        sta     *z80_e                  ; Add adjustment ...
        lda     ,x                      ; ... to second ...
        adca    *z80_d                  ; ... byte
        daa                             ; Adjust for BCD (cary gets dropped)
        sta     ,x                      ; Store second byte
        sta     *z80_d                  ; Second byte to D (first byte still in E)
        ldx     2,x                     ; Load the screen coordinates
        ldy     *z80_d
        bra     print_4_digits          ; ** Usually a good idea, but wasted here

; $09AD
; Print 4 digits in Y @X
print_4_digits:
        tfr     y,d                     ; Get first 2 digits of BCD or hex
        pshs    b
        bsr     draw_hex_byte           ; Print them
        puls    a

; $09B2        
; Display 2 digits in A to screen at HL/X
draw_hex_byte:
        pshs    a
        lsra
        lsra
        lsra
        lsra                            ; MSN
        bsr     sub_09C5                ; to screen @X
        puls    a
        anda    #0x0f                   ; LSN
        bsr     sub_09C5                ; to screen @X
        rts

; $09C5
sub_09C5:
        adda    #0x1A                   ; convert to digit char
        jmp     draw_char

; $09CA
; Get score descriptor for active player
sub_09CA:
        lda     player_data_msb         ; Get active player
        asra                            ; Test for player
        ldx     #p1_scor_m              ; Player 1 score descriptor
        bcs     9$                      ; Keep it if player 1 is active
        ldx     #p2_scor_m              ; Else get player 2 descriptor
9$:     rts        

; $09D6
; Clear center window of screen
clear_playfield:
.ifndef BUILD_OPT_ROTATED        
        ldx     #vram+2                 ; Third from left, top of screen
1$:     clr     ,x+                     ; Clear screen byte. Next in row
        tfr     x,d                     ; Get X ...
        andb    #0x1f                   ; ... coordinate
        cmpb    #0x1c                   ; Edge minus a buffer?
        bcs     2$                      ; No ... keep going
        leax    6,x                     ; Else ... bump to next edge + buffer
2$:     cmpa    #0x1C                   ; Get Y coordinate. Reached bottom?
        bcs     1$                      ; No ... keep going
.else
        ldx     #vram+32*VIDEO_BPL      ; start 32 pixels from the top
1$:     clr     ,x+
        cmpx    #vram+(32+208)*VIDEO_BPL  ; clear 256-32-16=208 lines
        bne     1$
.endif        
        rts

; $09EF
loc_09EF:
        bsr     sub_0A3C
        clr     suspend_play            ; Suspend ISR game tasks
        bsr     clear_playfield         ; Clear playfield
        lda     player_data_msb         ; Hold current player number ...
        pshs    a                       ; ... on stack
        jsr     copy_ram_mirror         ; Block copy RAM mirror from ROM
        puls    a                       ; Restore ...
        sta     player_data_msb         ; ... current player number
        lda     player_data_msb
        pshs    a                       ; Hold player-data pointer
        ldb     #0xfe                   ; 2xFE ... rack count
        tfr     d,x
        lda     ,x                      ; Get the number of racks the player has beaten
        anda    #7                      ; 0-7
        inca                            ; Now 1-8
        sta     ,x                      ; Update count since player just beat a rack
        ldu     #alien_start_table-1    ; Starting coordinate of alien table
1$:     leau    1,u                     ; Find the ...
        deca                            ; ... right entry ...
        bne     1$                      ; ... in the table
        puls    a                       ; Restore player's pointer  
        ldb     #0xfd                   ; 2xFD ... 
        tfr     d,x
        lda     ,u                      ; Get the starting Y coordinate
        sta     ,x                      ; Set rack's starting Y coordinate
        leax    -1,x                    ; Point to X
        lda     #0x38
        sta     ,x                      ; Set rack's starting X coordinate to 38
        tfr     x,d                     ; Player ...
        rora                            ; ... number to carry
        bcs     2$                      ; 2nd player stuff
        lda     #0x21                   ; Start fleet with first sound
;       ld      (soundPort5),a
        jsr     draw_shield_pl2         ; Draw shields for player 2
        jsr     init_aliens_p2          ; Initalize aliens for player 2
        jmp     loc_0804                ; Continue at top of game loop
2$:     jsr     draw_shield_pl1         ; Draw shields for player 1
        jsr     init_aliens             ; Initialize aliens for player 1
        jmp     loc_0804                ; Continue at top of game loop

; $0A3C
sub_0A3C:
        bsr     sub_0A59                ; Check player collision
        bne     2$                      ; Player is not alive ... skip delay
        lda     #0x30                   ; Half second delay
        sta     isr_delay               ; Set ISR timer
1$:     lda     isr_delay               ; Has timer expired?
        beq     9$                      ; Out if done
        bsr     sub_0A59                ; Check player collision
        bne     1$                      ; No collision ... wait on timer
2$:     bsr     sub_0A59                ; Wait for ...
        bne     2$                      ; ... collision to end
9$:     rts                
             
; $0A59
; Check to see if player is hit
sub_0A59:
        lda     player_alive            ; Active player hit flag
        cmpa    #0xff                   ; All FFs means player is OK
        rts

; $0A5F
; Start the hit-alien sound and flag the adjustment for the score.
; B contains the row, which determines the score value.
score_for_alien:
        tst     game_mode               ; Are we in game mode?
        beq     1$                      ; No ... skip scoring in demo
        stb     *z80_c                  ; Hold row number
        ldb     #8                      ; Alien hit sound
        jsr     sound_bits_3_on         ; Enable sound
        ldb     *z80_c                  ; Restore row number
        tfr     b,a                     ; Into A
        jsr     alien_score_value       ; Look up the score for the alien
        lda     ,x                      ; Get the score value
        ldx     #score_delta_msb        ; Pointer to score delta
        clr     ,x                      ; Upper byte of score delta is "00"
        sta     1,x                     ; Point to score delta LSB. Set score for hitting alien
        lda     #1
        sta     -1,x                    ; The score will get changed elsewhere
1$:     ldx     #exp_alien_msb          ; Return exploding-alien descriptor
        rts

; $0A80
; Start the ISR moving the sprite. Return when done.
animate:
        lda     #(1<<1)                 ; Start simple linear ...
        sta     isr_splash_task         ; ... sprite animation (splash)
1$:        
;       out     (watchdog),a
        tst     splash_reached          ; Has the sprite reached target?
        beq     1$                      ; No ... wait
        clr     isr_splash_task         ; Stop ISR animation
        rts
                
; $0A93
; Print message from DE/Y to screen at HL/X (length in B) with a
; delay between letters.
print_message_del:
        lda     ,y+                     ; Get character. Next in message
        pshs    b,y
        jsr     draw_char               ; Draw character on screen
        puls    b,y
        lda     #7                      ; Delay between letters
        sta     isr_delay               ; Set counter
1$:     lda     isr_delay               ; Get counter
        deca                            ; Is it 1?
        bne     1$                      ; No ... wait on it
        decb                            ; All done?
        bne     print_message_del       ; No ... do all
        rts

; $0AAB
splash_squiggly:
        ldx     #obj4_timer_msb         ; Pointer to game-object 4 timer
        jmp     loc_024B                ; Process squiggly-shot in demo mode
        
; $0AB1
one_sec_delay:
        lda     #0x40                   ; Delay of 64 (tad over 1 sec)
        bra     wait_on_delay           ; Do delay

; $0AB6
two_sec_delay:
        lda     #0x80                   ; Delay of 128 (tad over 2 sec)
        bra     wait_on_delay           ; Do delay

; $0ABB
splash_demo:
        puls    x                       ; Drop the call to ABF and ...
        jmp     loc_0072                ; ... do a demo game loop without sound

; $0ABF
; Different types of splash tasks managed by ISR in splash screens. The ISR
; calls this if in splash-mode. These may have been bit flags to allow all 3 
; at the same time. Maybe it is just easier to do a switch with a rotate-to-carry.
isr_spl_tasks:
        lda     isr_splash_task         ; Get the ISR task number
        rora                            ; In demo play mode?
        bcs     splash_demo             ; 1: Yes ... go do game play (without sound)
        rora                            ; Moving little alien from point A to B?
        lbcs    splash_sprite           ; 2: Yes ... go move little alien from point A to B
        rora                            ; Shooting extra "C" with squiggly shot?
        bcs     splash_squiggly         ; 4: Yes ... go shoot extra "C" in splash
        rts

; $0ACF
; Message to center of screen.
; Only used in one place for "SPACE  INVADERS"
sub_0ACF:
        LDX_VRAM  0x714                 ; Near center of screen
        ldb     #15                     ; 15 bytes in message
        bra     print_message_del       ; Print and out

; $0AD7
; Wait on ISR counter to reach 0
wait_on_delay:
        sta     isr_delay               ; Delay counter
1$:     tst     isr_delay               ; Get current delay. Zero yet?
        bne     1$                      ; No ... wait on it
        rts

; $0AE2
; Init the splash-animation block
ini_splash_ani:
        ldx     #splash_an_form         ; The splash-animation descriptor
        ldb     #12                     ; 12 bytes
        jmp     block_copy              ; Block copy DE to descriptor
        
; $0AEA
; After initialization ... splash screens
loc_0AEA:
        clra
;       out     (sound1),a
;       out     (sound2),a
        jsr     sub_1982                ; Turn off ISR splash-task
				lda			#>dp_base
				tfr			a,dp
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI
        bsr     one_sec_delay        
        LDX_VRAM  0x0C17                ; Screen coordinates (middle near top)
        ldb     #4                      ; 4 characters in "PLAY"
        tst     splash_animate          ; Splash screen type
        lbne    loc_0BE8                ; Not 0 ... do "normal" PLAY
        ldy     #message_play_UY        ; "PLAy" with an upside down 'Y' for splash screen
        bsr     print_message_del
        ldy     #message_invaders       ; "SPACE  INVADERS"
loc_0B0B:
        bsr     sub_0ACF                ; Print to middle-ish of screen
        bsr     one_sec_delay
        jsr     draw_adv_table          ; Draw "SCORE ADVANCE TABLE" with print delay
        bsr     two_sec_delay
        tst     splash_animate
        bne     loc_0B4A                ; Not 0 ... no animations
; $0B1E        
; Animate small alien replacing upside-down Y with correct Y
        ldy     #byte_0_1A95            ; Animate sprite from Y=FE to Y=9E step -1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (small alien)
        ldy     #byte_0_1BB0            ; Animate sprite from Y=98 to Y=FF step 1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (alien pulling upside down Y)
        bsr     one_sec_delay           ; One second delay
        ldy     #byte_0_1FC9            ; Animate sprite from Y=FF to Y=97 step 1
        bsr     ini_splash_ani          ; Copy to splash-animate structure
        jsr     animate                 ; Wait for ISR to move sprite (alien pushing Y)
        jsr     one_sec_delay           ; One second delay
        LDX_VRAM  0x0fb7                ; Where the splash alien ends up
        LDB_SPRW  10                    ; 10 rows
        jsr     clear_small_sprite      ; Clear a one byte sprite at HL
        jsr     two_sec_delay           ; Two second delay

; Play demo
loc_0B4A:  
        jsr     clear_playfield
        tst     p1_ships_rem            ; Number of ships for player-1. If non zero ...
        bne     1$                      ; ... keep it (counts down between demos)
        jsr     get_ships_per_cred      ; Get number of ships from DIP settings
        sta     p1_ships_rem            ; Reset number of ships for player-1
        jsr     remove_ship             ; Remove a ship from stash and update indicators
        
1$:     jsr     copy_ram_mirror         ; Block copy ROM mirror to initialize RAM
        jsr     init_aliens             ; Initialize all player 1 aliens
        jsr     draw_shield_pl1         ; Draw shields for player 1 (to buffer)
        jsr     restore_shields_1       ; Restore shields for player 1 (to screen)
        lda     #(1<<0)                 ; ISR splash-task ...
        sta     isr_splash_task         ; ... playing demo
        jsr     draw_bottom_line

.ifndef BUILD_OPT_DISABLE_DEMO
2$:     jsr     plr_fire_or_demo        ; In demo ... process demo movement and always fire
        jsr     loc_0BF1                ; Check player shot and aliens bumping edges of screen and hidden message
; watchdog
        jsr     sub_0A59                ; Has demo player been hit?
        beq     2$                      ; No ... continue game
        clr     plyr_shot_status        ; Remove player shot from activity
3$:     jsr     sub_0A59                ; Wait for demo player ...
        bne     3$                      ; ... to stop exploding
.endif

; Credit information
loc_0B89:
        clr     isr_splash_task         ; Turn off splash animation
        jsr     one_sec_delay
        jsr     sub_1988                ; Jump straight to clear-play-field
        ldb     #12                     ; Message size
        LDX_VRAM  0x0811                ; Screen coordinates
        ldy     #message_coin           ; "INSERT  COIN"
        jsr     print_message           ; Print message
        lda     splash_animate          ; Do splash animations?
        bne     4$                      ; Not 0 ... not on this screen
        LDX_VRAM  0x0f11                ; Screen coordinates
        lda     #2                      ; Character "C"
        jsr     draw_char               ; Put an extra "C" for "CCOIN" on the screen
4$:     ldu     #credit_table           ; "<1 OR 2 PLAYERS>  "
        jsr     read_pri_struct         ; Load the screen,pointer
        jsr     sub_184C                ; Print the message
; display coin info on demo screen is a dipswitch option
;       in      a,(inp2)
;       rlca
;       jp      c,$0BC3
        lda     dips
        bita    #DIP_DISPLAY_COINAGEn
        bne     5$
        leau    0,u                     ; "*1 PLAYER  1 COIN "
        jsr     loc_183A                ; Load the descriptor
; $0BC3        
5$:     jsr     two_sec_delay           ; Print TWO descriptors worth ???
        tst     splash_animate          ; Doing splash animation?
        bne     6$                      ; Not 0 ... not on this screen
        ldy     #byte_0_1FD5            ; Animation for small alien to line up with extra "C"
        jsr     ini_splash_ani          ; Copy the animation block
        jsr     animate                 ; Wait for the animation to complete
        jsr     sub_189E                ; Animate alien shot to extra "C"
6$:     lda     splash_animate
        eora    #1                      ; Toggle the splash screen animation for next time
        sta     splash_animate
        jsr     clear_playfield         ; Clear play field
        jmp     loc_18DF                ; Keep splashing
        
; $0BE8
loc_0BE8:
        ldy     #message_play_Y         ; "PLAY" with normal 'Y'
        jsr     print_message_del       ; Print it
        jmp     loc_0B0B                ; Continue with splash (HL/X will be pointing to next message)

loc_0BF1:
        jsr     plyr_shot_and_bump      ; Check if player is shot and aliens bumping the edge of screen
        jmp     check_hidden_mes        ; Check for hidden-message display sequence

message_corp:
;       "TAITO COP"
        .db 0x13, 0, 8, 0x13, 0xE, 0x26, 2, 0xE, 0xF    

; $1400
; The only differences between this and EraseShiftedSprite is two CPL instructions in the latter and
; the use of AND instead of OR. NOP takes the same amount of time/space as CPL. So the two NOPs
; here make these two parallel routines the same size and speed.
draw_shifted_sprite:
        nop
        jsr     cnvt_pix_number         ; Convert pixel number in HL to coorinates with shift
        nop
.ifndef BUILD_OPT_ROTATED
1$:     pshs    x   
        lda     ,y+                     ; Get picture value. Next in image
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        ora     ,x                      ; OR them onto the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
;       xor     a                       ; Shift register over ...
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        ora     ,x                      ; OR them onto the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        puls    x
        leax    32,x                    ; Add 32 to next row
        decb                            ; All rows done?
        bne     1$                      ; No ... erase all
.else
1$:     pshs    b,x
2$:     pshs    x
        ldb     #8
        lda     ,y+                     ; Get picture value. Next in image
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        ora     ,x                      ; OR them onto the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
;       xor     a                       ; Shift register over ...
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        ora     ,x                      ; OR them onto the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        puls    x
        leax    32,x                    ; Add 32 to next row
        decb                            ; All rows done?
        bne     2$                      ; No ... erase all
        puls    b,x
        leax    1,x
        decb
        bne     1$
.endif        
        rts                

; $1424
; Clear a sprite from the screen (standard pixel number descriptor).
; ** We clear 2 bytes even though the draw-simple only draws one.
erase_simple_sprite:
        bsr     cnvt_pix_number         ; Convert pixel number in HL
.ifndef BUILD_OPT_ROTATED        
1$:     pshs    x
        clr     ,x+                     ; Clear screen byte. Next byte
        clr     ,x+                     ; Clear byte
        puls    x                       ; Restore screen coordinate
        leax    32,x                    ; Add 1 row to screen coordinate
        decb                            ; All rows done?
        bne     1$                      ; Do all rows
.else
1$:     pshs    x,b
        ldb     #8
2$:     clr     ,x                      ; Clear screen byte.
        clr     8*32,x                  ; Clear next byte
        leax    32,x                    ; Add 1 row to screen coordinate
        decb                            ; All rows done?
        bne     1$                      ; Do all rows
        puls    x,b
        leax    1,x
        decb
        bne     2$
.endif        
        rts

; $1439
; Display character to screen
; HL/X = screen coordinates
; DE/Y = character data
; B = number of rows
draw_simp_sprite:
.ifndef BUILD_OPT_ROTATED
        lda     ,y+                     ; From character set ...
        sta     ,x                      ; ... to screen
        leax    32,x                    ; Next row on screen
        decb                            ; Decrement counter
        bne     draw_simp_sprite        ; Do all
.else
1$:     pshs    b,x
        ldb     #8
2$:     lda     ,y+
        sta     ,x
        leax    VIDEO_BPL,x
        decb
        bne     2$
        puls    b,x
        leax    1,x
        decb
        bne     1$
.endif
        rts

; $1452
; Erases a shifted sprite from screen (like for player's explosion)
erase_shifted:
        bsr     cnvt_pix_number         ; Convert pixel number in HL to coorinates with shift
.ifndef BUILD_OPT_ROTATED        
1$:     pshs    x   
        lda     ,y+                     ; Get picture value. Next in image
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
;       xor     a                       ; Shift register over ...
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        puls    x
        leax    32,x                    ; Add 32 to next row
        decb                            ; All rows done?
        bne     1$                      ; No ... erase all
.else
1$:     pshs    b,x
        ldb     #8
2$:     pshs    x   
        lda     ,y+                     ; Get picture value. Next in image
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
;       xor     a                       ; Shift register over ...
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        coma                            ; Reverse it (erasing bits)
        anda    ,x                      ; Erase the bits from the screen
        sta     ,x+                     ; Store the erased pattern back. Next column on screen
        puls    x
        leax    32,x                    ; Add 32 to next row
        decb                            ; All rows done?
        bne     2$                      ; No ... erase all
        puls    b,x
        leax    1,x
        decb
        bne     1$
.endif        
        rts                

; $1474
; Convert pixel number in HL/X to screen coordinate and shift amount.
; HL/X gets screen coordinate.
; Hardware shift-register gets amount.
cnvt_pix_number:
        pshs    b
        tfr     x,d
;       out     (shft_amt),a
        exg     a,b                     ; shft_amnt to MSB
        anda    #7                      ; bit offset only
        lsla                            ; x2 for table offset
        ora     #>shift_tbl             ; add table base address
        ldb     #0x80
        std     shft_base               ; store for later use
        puls    b
        jmp     conv_to_scr        

; $147C
; In a multi-player game the player's shields are block-copied to and from RAM between turns.
; HL/X = screen pointer
; DE/Y = memory buffer
; B = number of rows
; C = number of columns
remember_shields:
1$:     pshs    x
        ldb     *z80_c
2$:     lda     ,x+                     ; From screen
        sta     ,y+                     ; To buffer
        decb
        bne     2$
        puls    x                       ; Original start
        leax    32,x                    ; Bump X by one screen row
        dec     *z80_b                  ; Row counter
        bne     1$
        rts

; $1491
draw_spr_collision:
        bsr     cnvt_pix_number         ; Convert pixel number to coord and shift
        clr     collision               ; Clear the collision-detection flag
1$:     pshs    b,x   
        lda     ,y+                     ; Get byte. Next in pixel pattern
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        tfr     a,b                     ; B is destructive copy
        andb    ,x                      ; Any bits from pixel collide with bits on screen?
        beq     2$                      ; No ... leave flag alone
        ldb     #1                      ; Yes ... set ...
        stb     collision               ; ... collision flag
2$:     ora     ,x                      ; OR it onto the screen
        sta     ,x+                     ; Store new screen value. Next byte on screen
;       xor     a                       ; Write zero ...
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        tfr     a,b                     ; B is destructive copy
        andb    ,x                      ; Any bits from pixel collide with bits on screen?
        beq     3$                      ; No ... leave flag alone
        ldb     #1                      ; Yes ... set ...
        stb     collision               ; Yes ... set collision flag
3$:     ora     ,x                      ; OR it onto the screen
        sta     ,x                      ; Store new screen pattern
        puls    b,x
        leax    32,x                    ; Add 32 to get to next row
        decb                            ; All done?
        bne     1$                      ; No ... do all rows
        rts                

; $14CB
clear_small_sprite:
; Clear a one byte sprite at HL/X. B=number of rows.
        clra
sub_14CC:
.ifndef BUILD_OPT_ROTATED
1$:     sta     ,x                      ; Clear screen byte
        leax    32,x                    ; Bump HL/X one screen row
        decb                            ; All done?
        bne     1$                      ; No ... clear all
.else
1$:     pshs    b,x
        ldb     #8
2$:     clr     ,x
        leax    VIDEO_BPL,x
        decb
        bne     2$
        puls    b,x
        leax    1,x
        decb
        bne     1$        
.endif        
        rts

; $14D8
; The player's shot hit something (or is being removed from play) 
player_shot_hit:
        lda     plyr_shot_status        ; Player shot flag
        cmpa    #5                      ; Alien explosion in progress?
        beq     9$                      ; Yes ... ignore this function
        cmpa    #2                      ; Normal movement?
        bne     9$                      ; No ... out
        ldb     obj1_coor_yr            ; Get Yr coordinate of player shot
        cmpb    #0xd8                   ; Compare to 216 (40 from Top-rotated)
        bcc     loc_1530                ; Yr is within 40 from top initiate miss-explosion (shot flag 3)
        tst     alien_is_exploding      ; Is an alien blowing up?
        bne     1$
9$:     rts                             ; No ... out
1$:     cmpb    #0xce                   ; Compare to 206 (50 from rotated top)
        lbcc    loc_1579                ; Yr is within 50 from top? Yes ... saucer must be hit
        addb    #6                      ; Offset to coordinate for wider "explosion" picture
        stb     *z80_b
        lda     ref_alien_yr            ; Ref alien Y coordinate
; If the lower 4 rows are all empty then the reference alien's Y coordinate will wrap around from 0 to F8.
; At this point the top row of aliens is in the shields and we will assume that everything is within
; the rack.
        cmpa    #0x90                   ; This is true if ...
        bcc     code_bug_1              ; ... aliens are down in the shields
        cmpa    *z80_b                  ; Compare to shot's coordinate
        bcc     loc_1530                ; Outside the rack-square ... do miss explosion

; $1504
; We get here if the player's shot hit something within the rack area (a shot or an alien).
; Find the alien that is (or would be) where the shot hit. If there is no alien alive at the row/column
; then the player hit an alien missile. If there is an alien then explode the alien.
;
; There is a code bug here, but it is extremely subtle. The algorithm for finding the row/column in the
; rack works by adding 16 to the reference coordinates (X for column, Y for row) until it passes or equals
; the target coordinates. This works great as long as the target point is within the alien's rack area.
; If the reference point is far to the right, the column number will be greater than 11, which messes
; up the column/row-to-pointer math.
;
; The entire rack of aliens is based on the lower left alien. Imagine all aliens are dead except the
; upper left. It wiggles down the screen and enters the players shields on the lower left where it begins
; to eat them. Imagine the player is under his own shields on the right side of the screen and fires a
; shot into his own shield.
;
; The alien is in the rack on row 4 (rows are numbered from bottom up starting with 0). The shot hits
; the shields below the alien's Y coordinate and gets correctly assigned to row 3. The alien is in the rack
; at column 0 (columns are numbered from left to right starting with 0). The shot hits the shields far to
; the right of the alien's X coordinate. The algorithm says it is in column 11. But 0-10 are the only
; correct values.
;
; The column/row-to-pointer math works by multiplying the row by 11 and adding the column. For the alien 
; that is 11*4 + 0 = 44. For the shot that is 11*3 +11 = 44. The game thinks the shot hit the alien.
code_bug_1:        
        stb     *z80_l                  ; L now holds the shot coordinate (adjusted)
        bsr     find_row                ; Look up row number to B
        lda     obj1_coor_xr            ; Player's shot's Xr coordinate ...
        sta     *z80_h                  ; ... to H
        bsr     find_column             ; Get alien's coordinate
        ldx     *z80_h
        stx     exp_alien_xr            ; Put it in the exploding-alien descriptor
        lda     #5                      ; Flag alien explosion ...
        sta     plyr_shot_status        ; ... in progress
        bsr     get_alien_stat_ptr      ; Get descriptor for alien
        tst     ,x                      ; Is alien alive
        beq     loc_1530                ; No ... must have been an alien shot
        clr     ,x                      ; Make alien invader dead
        jsr     score_for_alien         ; Makes alien explosion sound and adjust score
        jsr     read_desc               ; Load 5 byte sprite descriptor
        jsr     draw_sprite             ; Draw explosion sprite on screen
        lda     #0x10                   ; Initiate alien-explosion
        sta     exp_alien_timer         ; ... timer to 16
        rts

; $1530
; Player shot leaving playfield, hitting shield, or hitting an alien shot
loc_1530:
        lda     #3                      ; Mark ...
        sta     plyr_shot_status        ; ... player shot hit something other than alien
        bra     loc_154A                ; Finish up

; $1538
; Time down the alien explosion. Remove when done.
a_explode_time:
        dec     exp_alien_timer         ; Decrement alien explosion timer
        beq     1$
        rts                             ; Not done  ... out
1$:     ldx     exp_alien_xr            ; Pixel pointer for exploding alien
        LDB_SPRW  16                    ; 16 row pixel
        jsr     erase_simple_sprite     ; Clear the explosion sprite from the screen

loc_1545:        
        lda     #4                      ; 4 means that ...
        sta     plyr_shot_status        ; ... alien has exploded (remove from active duty)

loc_154A:
        clr     alien_is_exploding      ; Turn off alien-is-blowing-up flag
        ldb     #0xf7                   ; Turn off ...
        jmp     sound_bits_3_off        ; ... alien exploding sound

; $1554
; Count number of 16s needed to bring reference (in A) up to target (in H).
; If the reference starts out beyond the target then we add 16s as long as
; the reference has a signed bit. But these aren't signed quantities. This
; doesn't make any sense. This counting algorithm produces questionable 
; results if the reference is beyond the target.
cnt_16s:
        clr     *z80_c                  ; Count of 16s
        cmpa    *z80_h                  ; Compare reference coordinate to target
        bcs     1$                      
        bsr     wrap_ref                ; If reference is greater or equal then do something questionable ... see below
1$:     cmpa    *z80_h                  ; Compare reference coordinate to target
        bcs     2$
        rts                             ; If reference is greater or equal then done
2$:     adda    #16                     ; Add 16 to reference
        inc     *z80_c                  ; Bump 16s count
        bra     1$                      ; Keep testing  

; $1562
find_row:
; L contains a Yr coordinate. Find the row number within the rack that corresponds
; to the Yr coordinate. Return the row coordinate in L and the row number in C.
        lda     ref_alien_yr            ; Reference alien Yr coordinate  
        ldb     *z80_l
        stb     *z80_h                  ; Target Yr coordinate to H
        bsr     cnt_16s                 ; Count 16s needed to bring ref alien to target
        ldb     *z80_c                  ; Count to B
        decb                            ; Base 0
        sbca    #16                     ; The counting also adds 16 no matter what
        sta     *z80_l                  ; To coordinate
        rts

; $1562
; H contains a Xr coordinate. Find the column number within the rack that corresponds
; to the Xr coordinate. Return the column coordinate in H and the column number in C.
find_column:
        lda     ref_alien_xr            ; Reference alien Yn coordinate
        bsr     cnt_16s                 ; Count 16s to bring Y to target Y
        sbca    #16                     ; Subtract off extra 16
        sta     *z80_h                  ; To H
        rts

loc_1579:
        lda     #1                      ; Mark flying ...
        sta     saucer_hit              ; ... saucer has been hit
        bra     loc_1545                ; Remove player shot

; $1581
; B is row number. C is column number (starts at 1). 
; Return pointer to alien-status flag for current player.
get_alien_stat_ptr:
        pshs    b
        lda     #11                     ; 
        mul                             ; row*11
        addb    *z80_c                  ; Add row offset to column offset
        decb                            ; -1
        lda     player_data_msb         ; Set MSB of HL/D with active player indicator
        tfr     d,x                     ; ->X
        puls    b
        rts

; $1590
; This is called if the reference point is greater than the target point. I believe the goal is to
; wrap the reference back around until it is lower than the target point. But the algorithm simply adds
; until the sign bit of the the reference is 0. If the target is 2 and the reference is 238 then this
; algorithm moves the reference 238+16=244 then 244+16=4. Then the algorithm stops. But the reference is
; STILL greater than the target.
;
; Also imagine that the target is 20 and the reference is 40. The algorithm adds 40+16=56, which is not
; negative, so it stops there.
;
; I think the intended code is "JP NC" instead of "JP M", but even that doesn't make sense.
wrap_ref:
        inc     *z80_c                  ; Increase 16s count 
        adda    #16                     ; Add 16 to ref
        bmi     wrap_ref                ; Keep going till result is positive
        rts

; $1597
; When rack bumps the edge of the screen then the direction flips and the rack
; drops 8 pixels. The deltaX and deltaY values are changed here. Interestingly
; if there is only one alien left then the right value is 3 instead of the 
; usual 2. The left direction is always -2.
rack_bump:
        tst     rack_direction          ; Get rack direction, Moving right?
        bne     3$                      ; No ... handle moving left
        ldx     #vram+0x1AA4            ; Line down the right edge of playfield
        bsr     sub_15C5                ; Check line down the edge
        bcc     2$                      ; Nothing is there ... return
        ldb     #-2                     ; Delta X of -2
        lda     #1                      ; Rack now moving right
1$:     sta     rack_direction          ; Set new rack direction
        stb     ref_alien_dxr           ; Set new delta X
        lda     rack_down_delta         ; Set delta Y ...
        sta     ref_alien_dyr           ; ... to drop rack by 8
2$:     rts
; $15B7
3$:     ldx     #vram+0x0124            ; Line down the left edge of playfield
        bsr     sub_15C5                ; Check line down the edge
        bcc     2$                      ; Nothing is there ... return
        jsr     sub_18F1                ; Get moving-right delta X value of 2 (3 if just one alien left)
        clra                            ; Rack now moving left
        bra     1$                      ; Set rack direction

; $15C5
sub_15C5:
        ldb     #23                     ; Checking 23 bytes in a line up the screen from near the bottom
        clra                            ; 6809 - clear the carry flag!
1$:     tst     ,x                      ; Is screen memory empty?
        lbne    loc_166B                ; No ... set carry flag and out
        leax    1,x                     ; Next byte on screen
        decb                            ; All column done?
        bne     1$                      ; No ... keep looking
        rts
                
; $15D3
; Draw sprite at [DE/Y] to screen at pixel position in HL/X
; The hardware shift register is used in converting pixel positions
; to screen coordinates.
draw_sprite:
        jsr     cnvt_pix_number         ; Convert pixel number to screen/shift
        pshs    x                       ; Preserve screen coordinate
.ifndef BUILD_OPT_ROTATED        
1$:     pshs    x
        lda     ,y+                     ; From sprite data
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        sta     ,x+                     ; Shifted sprite to screen
;       xor     a
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        sta     ,x                      ; Write remainder to adjacent
        puls    x                       ; Old screen coordinate
        leax    32,x                    ; Offset screen to next row
        decb                            ; All done?
        bne     1$                      ; No ... do all
.else
1$:     pshs    x,b
        ldb     #8
2$:     pshs    x
        lda     ,y+                     ; From sprite data
;       out     (shft_data),a
;       in      a,(shft_in)
        ldu     shft_base
        leau    a,u                     ; pointer to shift table entry (1st byte)
        lda     ,u                      ; get shifted value
        sta     ,x+                     ; Shifted sprite to screen
;       xor     a
;       out     (shft_data),a
;       in      a,(shft_in)
        lda     256,u                   ; get 2nd byte
        sta     ,x                      ; Write remainder to adjacent
        puls    x                       ; Old screen coordinate
        leax    32,x                    ; Offset screen to next row
        decb                            ; All done?
        bne     2$                      ; No ... do all
        puls    x,b
        leax    1,x
        decb
        bne     1$
.endif        
        puls    x                       ; Restore HL/X
        rts

; $15F3
; Count number of aliens remaining in active game and return count 2082 holds the current count.
; If only 1, 206B gets a flag of 1 ** but ever nobody checks this
count_aliens:
        bsr     get_player_data_ptr     ; Get active player descriptor
        ldb     #NUM_ALIENS             ; B=55 aliens to check?
        clr     *z80_c                  ; zero count
1$:     tst     ,x+                     ; Get byte. Is it a zero?
        beq     2$                      ; Yes ... don't count it
        inc     *z80_c                  ; Count the live aliens
2$:     decb                            ; Count ...
        bne     1$                      ; ... all alien indicators
        lda     *z80_c                  ; Get the count
        sta     num_aliens              ; Hold it
        cmpa    #1                      ; Just one?
        bne     9$                      ; No keep going
        ldx     #one_alien              ; Set flag if ...
        sta     ,x                      ; ... only one alien left
9$:     rts        

; $1611
get_player_data_ptr:
; Set HL/X with 2100 if player 1 is active or 2200 if player 2 is active
        clrb                            ; Byte boundary
        lda     player_data_msb         ; Active player number
        tfr     d,x                     ; Set HL to data
        rts

; $1618
plr_fire_or_demo:
; Initiate player fire if button is pressed.
; Demo commands are parsed here if in demo mode
        lda     player_alive            ; Is there an active player?
        cmpa    #0xff                   ; FF = alive
        bne     9$                      ; Player has been shot - no firing
1$:     ldd     obj0_timer_msb          ; Player task timer active?
        bne     9$                      ; No ... no firing till player object starts <<---???
        tst     plyr_shot_status        ; Does the player have a shot on the screen?
        bne     9$                      ; Yes ... ignore
        tst     game_mode               ; Are we in game mode?
        beq     loc_1652                ; No ... in demo mode ... constant firing in demo
        tst     fire_bounce             ; Is fire button being held down?
        bne     loc_1648                ; Yes ... wait for bounce
        jsr     read_inputs             ; Read active player controls
        anda    #INP_FIRE               ; Fire-button pressed?
        beq     9$                      ; No ... out
        lda     #1                      ; Flag
        sta     plyr_shot_status        ; Flag shot active
        sta     fire_bounce             ; Flag that fire button is down
9$:     rts        

loc_1648:
        jsr     read_inputs             ; Read active player controls
        anda    #INP_FIRE               ; Fire-button pressed?
        bne     9$                      ; Yes ... ignore
        sta     fire_bounce             ; Else ... clear flag
9$:     rts

; Handle demo (constant fire, parse demo commands)        
loc_1652:
        lda     #1                      ; Demo fires ...
        sta     plyr_shot_status        ; ... constantly
        ldx     demo_cmd_ptr_msb        ; Demo command buffer
        leax    1,x                     ; Next position
        cmpx    #demo_commands+10       ; Buffer from 1F74 to 1F7E (was CP $7E)
        bne     1$
        ldx     #demo_commands          ; ... overflow
1$:     stx     demo_cmd_ptr_msb        ; Next demo command
        lda     ,x                      ; Get next command
        sta     next_demo_cmd           ; Set command for movement
        rts        

; $166B
loc_166B:
        SCF
        rts

; $166D
loc_166D:
        clra
        jsr     loc_1A8B                ; Print ZERO ships remain
loc_1671:        
        jsr     cur_ply_alive           ; Get active-flag ptr for current player
        clr     ,x                      ; Flag player is dead
        jsr     sub_09CA                ; Get score descriptor for current player
        ldy     #hi_scor_m              ; Current high score upper two digits
        lda     ,y                      ; Is player score greater ...
        cmpa    ,x                      ; ... than high score?
        pshs    cc
        lda     1,y                     ; Go ahead and fetch high score lower two digits
        puls    cc
        beq     1$                      ; Upper two are the same ... have to check lower two
        bcc     3$                      ; Player score is lower than high ... nothing to do
        bra     2$                      ; Player socre is higher ... go copy the new high score
; $168B
1$:     cmpa    1,x                     ; Is lower digit higher? (upper was the same)
        bcc     3$                      ; No ... high score is still greater than player's score
2$:     lda     ,x+                     ; Copy the new ...
        sta     ,y+                     ; ... high score upper two digits
        lda     ,x                      ; Copy the new ...
        sta     ,y                      ; ... high score lower two digits
        jsr     print_hi_score          ; Draw the new high score
; $1698        
3$:     tst     two_players             ; Number of players. Is this a single player game?
        beq     loc_16C9                ; Yes ... short message
        LDX_VRAM  0x0403                ; Screen coordinates
        ldy     #message_g_over         ; "GAME OVER PLAYER< >"
        ldb     #20                     ; 20 characters
        jsr     print_message_del       ; Print message
        leax    -512,x                  ; Back up to player indicator
        ldb     #0x1b                   ; "1"
        lda     player_data_msb         ; Player number
        asra                            ; Is this player 1?
        bcs     4$                      ; Yes ... keep the digit
        ldb     #0x1c                   ; Else ... set digit 2
4$:     tfr     b,a                     ; To A
        jsr     draw_char               ; Print player number
        jsr     one_sec_delay           ; Short delay
        jsr     sub_18E7                ; Get current player "alive" flag
        tst     ,x                      ; Is player alive?
        beq     loc_16C9                ; No ... skip to "GAME OVER" sequence
        jmp     loc_02ED                ; Switch players and game loop
; $16C9
loc_16C9: 
        LDX_VRAM  0x0918                ; Screen coordinates
        ldy     #message_g_over         ; "GAME OVER PLAYER< >"
        ldb     #10                     ; Just the "GAME OVER" part
        jsr     print_message_del       ; Print message
        jsr     two_sec_delay           ; Long delay
        jsr     clear_playfield         ; Clear center window
        clr     game_mode               ; Now in demo mode
;       out     (sound2),a              ; All sound off
        jsr     enable_game_tasks       ; Enable ISR game tasks
        jmp     loc_0B89                ; Print credit information and do splash

; $16E6
loc_16E6:
        lds     #stack                  ; Reset stack
				lda			#>dp_base
				tfr			a,dp
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI                              ; Enable interrupts
        clr     player_alive            ; Flag player is shot
1$:     jsr     player_shot_hit         ; Player's shot collision detection
        ldb     #4                      ; Player has been hit ...
        jsr     sound_bits_3_on         ; ... sound
        jsr     sub_0A59                ; Has flag been set?
        bne     1$                      ; No ... wait for the flag
        jsr     disable_game_tasks      ; Disable ISR game tasks
        LDX_VRAM  0x0301                ; Player's stash of ships
        jsr     loc_19FA                ; Erase the stash of ships
        clra                            ; Print ...
        jsr     loc_1A8B                ; ... a zero (number of ships)
        ldb     #0xfb                   ; Turn off ...
        jmp     loc_196B                ; ... player shot sound

; $170E
; Use the player's MSB to determine how fast the aliens reload their
; shots for another fire.
a_shot_reload_rate_fn:
        jsr     sub_09CA                ; Get score descriptor for active player
        lda     ,x                      ; Get the MSB value
        ldy     #a_reload_score_tab     ; Score MSB table
        ldx     #shot_reload_rate       ; Corresponding fire reload rate table
        ldb     #4                      ; Only 4 entries (a 5th value of 7 is used after that)
        sta     *z80_b                  ; Hold the score value
1$:     lda     ,y                      ; Get lookup from table
        cmpa    *z80_b                  ; Compare them
        bcc     2$                      ; Equal or below ... use this table entry
        leax    1,x                     ; Next ...
        leay    1,y                     ; ... entry in table
        decb                            ; Do all ...
        bne     1$                      ; ... 4 entries in the tables
2$:     lda     ,x                      ; Load the shot reload value
        sta     a_shot_reload_rate      ; Save the value for use in shot routine
        rts        

; $172C
; Shot sound on or off depending on 2025
shot_sound:
        lda     plyr_shot_status        ; Player shot flag
        cmpa    #0                      ; Active shot?
        bne     1$                      ; Yes ... go
        ldb     #0xfd                   ; Sound mask
        jmp     sound_bits_3_off        ; Mask off sound
1$:     ldb     #2                      ; Sound bit
        jmp     sound_bits_3_on         ; OR on sound

; $1740
; This called from the ISR times down the fleet and sets the flag at 2095 if 
; the fleet needs a change in sound handling (new delay, new sound)
time_fleet_sound:
        ldx     #fleet_snd_hold         ; Pointer to hold time for fleet
        dec     ,x                      ; Decrement hold time
        bne     1$
        bsr     sub_176D                ; If 0 turn fleet movement sound off
1$:     tst     player_ok               ; Is player OK? 1  means OK
        beq     sub_176D                ; Player not OK ... fleet movement sound off and out
        ldx     #fleet_snd_cnt          ; Current time on fleet sound
        dec     ,x                      ; Count down
        bne     9$                      ; Not time to change sound ... out
        ldx     #sound_port_5           ; Current sound port 3?? value
        lda     ,x                      ; Get value
;       out     (sound2),a              ; Set sounds
        tst     num_aliens              ; Number of aliens on active screen
        beq     sub_176D                ; Is it zero? Yes ... turn off fleet movement sound and out
        lda     -1,x                    ; Get fleet delay value
        sta     -2,x                    ; Reload the timer
        lda     #1
        sta     -3,x                    ; (2095) time to change sound
        lda     #4                      ; Set hold ...
        sta     fleet_snd_hold          ; ... time for fleet sound
9$:     rts
        
; $176D
sub_176D:
        lda     sound_port_5            ; Current sound port 3?? value
sub_1770:        
        anda    #0x30                   ; Mask off fleet movement sounds
;       out     (sound2),a              ; Set sounds
        rts

; $1775
fleet_delay_ex_ship:
        tst     change_fleet_snd        ; Time for new fleet movement sound?
        beq     4$                      ; No ... skip to extra-man timing
        ldx     #byte_0_1A11            ; Number of aliens list coupled ...
        ldy     #byte_0_1A21            ; ... with delay list
        lda     num_aliens              ; Get the number of aliens on the screen
1$:     cmpa    ,x                      ; Compare it to the first list value
        bcc     2$                      ; Number of live aliens is higher than value ... use the delay
        leax    1,x                     ; Move to ...
        leay    1,y                     ; ... next list value
        bra     1$                      ; Find the right delay
2$:     lda     ,y                      ; Get the delay from the second list
        sta     fleet_snd_reload        ; Store the new alien sound delay
        ldx     #sound_port_5           ; Get current state ...
        lda     ,x                      ; ... of sound port
        anda    #0x30                   ; Mask off all fleet movement sounds
        sta     *z80_b                  ; Hold the value
        lda     ,x                      ; Get current state
        anda    #0x0f                   ; This time ONLY the fleet movement sounds
        rola                            ; Shift next to next sound
        cmpa    #0x10                   ; Overflow?
        bne     3$                      ; No ... keep it
        lda     #1                      ; Reset back to first sound
3$:     ora     *z80_b                  ; Add fleet sounds to current sound value
        sta     ,x                      ; Store new sound value
        clr     change_fleet_snd        ; Restart waiting on fleet time
;
4$:     ldx     #extra_hold             ; Sound timer for award extra ship
        dec     ,x                      ; Time expired?
        beq     5$
        rts                             ; No ... leave sound playing
5$:     ldb     #~(1<<4)                ; Turn off bit set with #$10 (award extra ship)
        jmp     sound_bits_3_off        ; Stop sound and out

; $17B4
snd_off_ext_ply:
        ldb     #~(1<<4)                ; Mask off sound bit 4 (Extended play)
        ldx     #sound_port_5           ; Current sound content
        lda     ,x                      ; Get current sound bits
        anda    *z80_b                  ; Turn off extended play
        sta     ,x                      ; Remember settings
;       out     (sound2),a
        rts

; $17C0
; Read control inputs for active player
read_inputs:
        clrb
        lda     player_data_msb         ; Get active player
; this is only going to work if the offsets within memory
; are preserved on this port
; original $2100,$220 -> 6809 $6100,$6200        
        rora                            ; Test player
        bcc     5$
; read player 1 inputs
0$:     ldu     #KEYROW
        lda     #~(1<<5)                ; Column 5 (LEFT)
        sta     2,u
        lda     ,u                      ; Read keyboard row
        bita    #(1<<3)                 ; LEFT?
        bne     1$                      ; no, skip
        orb     #INP_LEFT
1$:     lda     #~(1<<6)                ; Column 6 (RIGHT)
        sta     2,u
        lda     ,u                      ; Read keyboard row
        bita    #(1<<3)                 ; RIGHT?
        bne     2$                      ; no, skip
        orb     #INP_RIGHT
2$:     lda     #~(1<<7)                ; Column 7 (SPACE)
        sta     2,u
        lda     ,u                      ; Read keyboard row
        bita    #(1<<3)                 ; SPACE?
        bne     3$                      ; no, skip
        orb     #INP_FIRE
3$:     tfr     b,a
        rts
5$:
; read player 2 inputs                
        bra     0$                      ; same keys for now
        rts

; $17CD
check_handle_tilt:
;       in      a,(inp2)
;       and     $04
        ldu     #KEYROW
        lda     #~(1<<4)                ; Column 4 (CTRL)
        sta     2,u
        lda     ,u                      ; read keyboard row
        bita    #(1<<6)                 ; CTRL?
        bne     0$                      ; no, exit
        lda     #~(1<<2)                ; Column 2 (BRK)
        sta     2,u
        lda     ,u                      ; read keyboard row
        bita    #(1<<6)                 ; BREAK?
        beq     1$                      ; yes, skip
0$:     rts
1$:     tst     tilt                    ; Already in TILT handle?
        bne     0$                      ; Yes ... ignore it now
        lds     #stack                  ; Reset stack
        ldb     #4                      ; Do this 4 times
2$:     pshs    b
        jsr     clear_playfield         ; Clear center window
        puls    b
        decb                            ; All done?
        bne     2$                      ; No ... do again
        lda     #1                      ; Flag ...
        sta     tilt                    ; ... handling TILT
        jsr     disable_game_tasks      ; Disable game tasks
				lda			#>dp_base
				tfr			a,dp
.ifdef BUILD_OPT_ENABLE_PROFILING
        lda     #CMP_WHITE
        sta     PALETTE+1
.endif
        EI                              ; Re-enable interrupts
        ldy     #message_tilt           ; Message "TILT"
        LDX_VRAM  0x0C16                ; Center of screen
        ldb     #4                      ; Four letters
        jsr     print_message_del       ; Print "TILT"
        jsr     one_sec_delay           ; Short delay
        clra                            ; Zero
        sta     tilt                    ; TILT handle over
        sta     wait_start_loop         ; Back into splash screens
        jmp     loc_16C9                ; Handle game over for player
                
; $1804
ctrl_saucer_sound:
        ldx     #saucer_active          ; Saucer on screen flag
        tst     ,x                      ; Is the saucer on the screen?
        lbeq    loc_0707                ; No ... UFO sound off
        leax    1,x                     ; Saucer hit flag
        tst     ,x                      ; (2085) Get saucer hit flag. Is saucer in "hit" sequence?
        beq     1$
        rts                             ; Yes ... out
1$:     ldb     #1                      ; Retrigger saucer ...
        jmp     sound_bits_3_on         ; ... sound (retrigger makes it warble?)

; $1815
; Draw "SCORE ADVANCE TABLE"
draw_adv_table:
        LDX_VRAM  0x0410                ; 0x410 is 1040 rotCol=32, rotRow=16
        ldy     #message_adv            ; "*SCORE ADVANCE TABLE*"
        ldb     #21                     ; 21 bytes in message
        jsr     print_message
        lda     #10                     ; 10 bytes in every "=xx POINTS" string
        sta     temp_206C
        ldu     #word_0_1DBE
1$:     bsr     read_pri_struct         ; Get X=coordinate, Y=message
        bcs     2$                      ; Move on if done
        bsr     sub_1844                ; draw 16-byte sprite
        bra     1$                      ; Do all in table
        rts
; $1834
        jsr     one_sec_delay
2$:     ldu     #word_0_1DCF
loc_183A:
1$:     bsr     read_pri_struct         ; Get X=coordinate, Y=message
        bcc     2$                      ; continue of not done
        rts
2$:     bsr     sub_184C                ; Print Message
        bra     1$                      ; Do all in table
; $1844
sub_1844:
        LDB_SPRW  16                    ; 16 bytes
        jsr     draw_simp_sprite        ; Draw simple
        rts

; $184C
sub_184C:
        ldb     temp_206C               ; Count of 10 to C/B
        jsr     print_message_del       ; Print the message with delay between letters
        rts
        
; $1856
read_pri_struct:
; Read a 4-byte print-structure pointed to by BC/U
; HL/X=Screen coordiante, DE/Y=pointer to message
; If the first byte is FF then return with C=1.
        lda     ,u                      ; Get the screen LSB
        cmpa    #0xff                   ; Valid?
        SCF                             ; If not C will be 1
        beq     9$                      ; Return if 255
        ldx     ,u++                    ; screen coordinate
        ldy     ,u++                    ; message address
        CCF
9$:     rts        

; $1868
; Moves a sprite up or down in splash mode. Interrupt moves the sprite. When it reaches
; Y value in 20CA the flag at 20CB is raised. The image flips between two pictures every
; 4 movements.      
splash_sprite:
        ldx     #splash_an_form         ; Descriptor
        inc     ,x+                     ; Change image, Point to delta-x
        lda     ,x                      ; Get delta-x
        sta     *z80_c
        jsr     add_delta               ; Add delta-X and delta-Y to X and Y
        stb     *z80_b                  ; Current y coordinate
        lda     splash_target_y         ; Has sprite reached ...
        cmpa    *z80_b                  ; ... target coordinate?
        beq     2$                      ; Yes ... flag and out
        lda     splash_an_form          ; Image number
        ldx     splash_im_rest_msb      ; Image
        anda    #4                      ; Watching bit 3 for flip delay
        bne     1$                      ; Did bit 3 go to 0? No ... keep current image
        leax    48,x                    ; 16*3 ... use other image form
1$:     stx     splash_image_msb        ; Image to descriptor structure
        ldx     #splash_xr              ; X,Y,Image descriptor (x,y swapped for 6809)
        jsr     read_desc               ; Read sprite descriptor
        exg     x,y                     ; Image to DE/Y, position to HL/X
        jmp     draw_sprite             ; Draw the sprite

; $1898
2$:     lda     #1                      ; Flag that sprite ...
        sta     splash_reached          ; ... reached location
        rts

; $189E
;Animate alien shot to extra "C" in splash
sub_189E:
        ldx     #obj4_timer_msb         ; Task descriptor for game object 4 (squiggly shot)
        ldy     #byte_0_1BC0            ; Task info for animate-shot-to-extra-C
        ldb     #16                     ; Block copy ...
        jsr     block_copy              ; ... 16 bytes
        lda     #2                      ; Set shot sync ...
        sta     shot_sync               ; ... to run the squiggly shot
        lda     #0xff                   ; Shot direction (-1)
        sta     alien_shot_delta        ; Alien shot delta
        lda     #(1<<2)                 ; Animate ...
        sta     isr_splash_task         ; ... shot
1$:     lda     squ_shot_status         ; Has shot ...
        anda    #1                      ; ... collided?
        beq     1$                      ; No ... keep waiting
2$:     lda     squ_shot_status         ; Wait ...
        anda    #1                      ; ... for explosion ...
        bne     2$                      ; ... to finish
        LDX_VRAM  0x0f11                ; Here is where the extra C is
        lda     #0x26                   ; Space character
        jsr     draw_char               ; Draw character
        jmp     two_sec_delay           ; Two second delay and out
        
; $18D4                
; Initializiation comes here
start:
        lds     #stack
        ldb     #0                      ; Count 256 bytes
        jsr     sub_01E6                ; copy ROM to RAM
        jsr     draw_status             ; Print scores and credits

; $18DF
loc_18DF:
        lda     #8                      ; Set alien ...
        sta     a_shot_reload_rate      ; ... shot reload rate
        jmp     loc_0AEA                ; Top of splash screen loop

; $18E7
; Get player-alive flag for OTHER player
sub_18E7:
        lda     player_data_msb         ; Player data MSB
        ldx     #player1_alive          ; Alive flags (player 1 and 2)
; this only works if msb is odd for p1, even for p2
        lsra                            ; Bit 1=1 for player 1
        bcc     9$                      ; Player 2 ... we have it ... out
        leax    1,x                     ; Player 1's flag
9$:     rts        

; $18F1
; If there is one alien left then the right motion is 3 instead of 2. That's
; why the timing is hard to hit after the change.
sub_18F1:
        ldb     #2                      ; Rack moving right delta X 
        lda     num_aliens              ; Number of aliens on screen
        deca                            ; Just one left?
        bne     9$                      ; No ... use right delta X of 2
        incb                            ; Just one alien ... move right at 3 instead of 2
9$:     rts
        
; $18FA
sound_bits_3_on:
;       ld      a,(soundport3)
;       or      b
;       ld      (soundport3),a
;       out     (sound),a
        rts

; $1904
init_aliens_p2:
        ldx     #byte_0_2200            ; Player 2 data area
        jmp     loc_01C3                ; Initialize player 2 aliens

; $190A
plyr_shot_and_bump:
        jsr     player_shot_hit         ; Player's shot collision detection
        jmp     rack_bump               ; Change alien deltaX and deltaY when rack bumps edges

; $1910
; Get the current player's alive status
cur_ply_alive:
        ldx     #player1_alive          ; Alive flags
        lda     player_data_msb         ; Player 1 or 2
        asra                            ; Will be 1 if player 1
        bcs     9$                      ; Return if player 1
        leax    1,x                     ; Bump to player 2
9$:     rts        
                                
; $191A
; Print score header " SCORE<1> HI-SCORE SCORE<2> "
draw_score_head:
        ldb     #0x1c                   ; 28 bytes in message
        LDX_VRAM  0x1e                  ; Screen coordinates
        ldy     #message_score          ; Score header message
        jmp     print_message           ; Print score header

; $1925
sub_1925:
        ldx     #p1_scor_m              ; Player 1 score descriptor
        bra     draw_score              ; Print score
    
sub_192B:        
; $192B        
        ldx     #p2_scor_m              ; Player 2 score descriptor
        bra     draw_score              ; Print score

; $1931
; Print score.
; HL/X = descriptor
draw_score:
        ldy     ,x++                    ; score
        ldx     ,x++                    ; coordinates
        jmp     print_4_digits          ; Print 4 digits in DE/Y

; $193C
; Print message "CREDIT "
sub_193C:
        ldb     #7                      ; 7 bytes in message
        LDX_VRAM  0x1101                ; Screen coordinates
        ldy     #message_credit         ; Message = "CREDIT "
        jmp     print_message           ; Print message

; $1947
draw_num_credits:
; Display number of credits on screen
        lda     num_coins               ; Number of credits
        LDX_VRAM  0x1801                ; Screen coordinates
        jmp     draw_hex_byte           ; Character to screen
                
; $1950
print_hi_score:
        ldx     #hi_scor_m              ; Hi Score descriptor
        bra     draw_score              ; Print Hi-Score
                
; $1956
; Print scores (with header) and credits (with label)
draw_status:
        jsr     clear_screen            ; Clear the screen
        bsr     draw_score_head         ; Print score header
        bsr     sub_1925                ; Print player 1 score
        bsr     sub_192B                ; Print player 2 score
        bsr     print_hi_score          ; Print hi score
        bsr     sub_193C                ; Print credit table
        bra     draw_num_credits        ; Number of credits

; $196B
loc_196B:
        bsr     sound_bits_3_off        ; From 170B with B=FB. Turn off player shot sound
        jmp     loc_1671                ; Update high-score if player's score is greater
        
; $1971
loc_1971:
        lda     #1                      ; Set flag that ...
        sta     invaded                 ; ... aliens reached bottom of screen
        jmp     loc_16E6                ; End of round
        
; $1979
loc_1979:
        bsr     disable_game_tasks      ; Disable ISR game tasks
        bsr     draw_num_credits        ; Display number of credits on screen
        bra     sub_193C                ; Print message "CREDIT"

; $1982
sub_1982:
        sta     isr_splash_task         ; Set ISR splash task
        rts
        
; $199A
; There is a hidden message "TAITO COP" (with no "R") in the game. It can only be 
; displayed in the demonstration game during the splash screens. You must enter
; 2 seqences of buttons. Timing is not critical. As long as you eventually get all
; the buttons up/down in the correct pattern then the game will register the
; sequence.
;
; 1st: 2start(down) 1start(up)   1fire(down) 1left(down) 1right(down)
; 2nd: 2start(up)   1start(down) 1fire(down) 1left(down) 1right(up)
;
; Unfortunately MAME does not deliver the simultaneous button presses correctly. You can see the message in
; MAME by changing 19A6 to 02 and 19B1 to 02. Then the 2start(down) is the only sequence. 
check_hidden_mes:
        tst     hid_mess_seq            ; Has the 1st "hidden-message" sequence been registered?
        bne     2$                      ; Yes ... go look for the 2nd sequence
;       in      a,(inp1)                ; Get player inputs
;        lda     #0x72                   ; *** fudge
        anda    #0x76                   ; 0111_0110 Keep 2Pstart, 1Pstart, 1Pshot, 1Pleft, 1Pright
        suba    #0x72                   ; 0111_0010 1st sequence: 2Pstart, 1Pshot, 1Pleft, 1Pright
        beq     1$                      
        rts                             ; Not first sequence ... out
1$:     inca                            ; Flag that 1st sequence ...
        sta     hid_mess_seq            ; ... has been entered
2$:
;       in      a,(inp1)                ; Check inputs for 2nd sequence
;        lda     #0x34                   ; *** fudge
        anda    #0x76                   ; 0111_0110 Keep 2Pstart, 1Pstart, 1Pshot, 1Pleft, 1Pright
        cmpa    #0x34                   ; 0011_0100 2nd sequence: 1Pstart, 1Pshot, 1Pleft 
        beq     3$
        rts                             ; If not second sequence ignore
3$:     LDX_VRAM  0x0A1B                ; Screen coordinates
        ldy     #message_corp           ; Message = "TAITO COP" (no R)
        ldb     #9                      ; Message length
        jmp     print_message           ; Print message and out
                
; $1988
sub_1988:
        jmp     clear_playfield         ; Clear playfield and out

; $19D1
; Enable ISR game tasks 
enable_game_tasks:
        lda     #1                      ; Set ISR ...
loc_19D3:        
        sta     suspend_play            ; ... game tasks enabled
        rts
        
; $19D7
; Disable ISR game tasks
; Clear 20E9 flag
disable_game_tasks:
        clra                            ; Clear ISR game tasks flag
        bra     loc_19D3                ; Save a byte (the RET)

; $19DC
sound_bits_3_off:
; Turn off bit in sound port
;       ld      a,(soundport3)
;       and     b
;       ld      (soundport3),a
;       out     (sound1),a
        rts

; $19E6
draw_num_ships:
; Show ships remaining in hold for the player
        LDX_VRAM  0x0301                ; Screen coordinates
        tsta                            ; None in reserve ... 
        beq     loc_19FA                ; ... skip display
; Draw line of ships
1$:     ldy     #player_sprite          ; Player sprite
        LDB_SPRW  16                    ; 16 rows
        sta     *z80_c                  ; Hold count
        jsr     draw_simp_sprite        ; Display 1-byte sprite to screen
        lda     *z80_c                  ; Restore remaining
        deca                            ; All done?
        bne     1$
; Clear remainder of line        
loc_19FA:
        LDB_SPRW  16                    ; 16 rows
        jsr     clear_small_sprite      ; Clear 1-byte sprite at HL/X
        tfr     x,d                     ; Get Y coordinate
.ifndef BUILD_OPT_ROTATED        
        cmpa    #>vram+0x11             ; At edge?
.else
        andb    #0x1f
        cmpb    #0x1f
.endif        
        bne     loc_19FA                ; No ... do all
        rts

; $1A06
; The ISRs set the upper bit of 2072 based on where the beam is. This is compared to the
; upper bit of an object's Y coordinate to decide whic ISR should handle it. When the
; beam passes the halfway point (or near it ... at scanline 96), the upper bit is cleared.
; When the beam reaches the end of the screen the upper bit is set.
;
; The task then runs in the ISR if the Y coordiante bit matches the 2072 flag. Objects that
; are at the top of the screen (upper bit of Y clear) run in the mid-screen ISR when
; the beam has moved to the bottom of the screen. Objects that are at the bottom of the screen
; (upper bit of Y set) run in the end-screen ISR when the beam is moving back to the top.
;
; The pointer to the object's Y coordinate is passed in DE. CF is set if the upper bits are
; the same (the calling ISR should execute the task).
comp_y_to_beam:
        ldx     #vblank_status          ; Get the beam position status
        clra                            ; 6809 - clear carry flag
        lda     ,y                      ; Get the task structure flag
        anda    #0x80                   ; Only upper bits count
        eora    ,x                      ; XOR them together
        bne     9$                      ; Not the same (CF cleared)
        SCF                             ; Set the CF if the same
9$:     rts

; $1A11
; Alien delay lists. First list is the number of aliens. The second list is the corresponding delay.
; This delay is only for the rate of change in the fleet's sound.
; The check takes the first num-aliens-value that is lower or the same as the actual num-aliens on screen.
;
; The game starts with 55 aliens. The aliens are move/drawn one per interrupt which means it
; takes 55 interrupts. The first delay value is 52 ... which is almost in sync with the number
; of aliens. It is a tad faster and you can observe the sound and steps getting out of sync.
byte_0_1A11:
        .db 50, 43, 36, 28, 22, 17, 13, 10, 8, 7, 6, 5, 4, 3, 2
        .db 1
byte_0_1A21:
        .db 52, 46, 39, 34, 28, 24, 21, 19, 16, 14, 13, 12, 11
        .db 9, 7, 5
        .db 0xFF
        
; $1A32
block_copy:
        lda     ,y+
        sta     ,x+
        decb
        bne     block_copy
        rts

; $1A3B
; Load 5 bytes sprite descriptor from [HL]
read_desc:
        ldy     ,x++                    ; Sprite picture
        ldu     ,x++                    ; Screen location
        ldb     ,x                      ; Number of bytes in sprite
        tfr     u,x
        rts

; $1A47
; The screen is organized as one-bit-per-pixel.
; In: HL/X contains pixel number (bbbbbbbbbbbbbppp)
; Convert from pixel number to screen coordinates (without shift)
; Shift HL right 3 bits (clearing the top 2 bits)
; and set the third bit from the left.
conv_to_scr:
        pshs    b
        tfr     x,d
        lsra
        rorb
        lsra
        rorb
        lsra
; the original code OR'd H with $20, effectively setting the base @$2000
; but the screen starts at $2400, so we need to subtract the difference
        rorb                            ; D/=8
        suba    #0x04
.ifdef BUILD_OPT_ROTATED
        exg     a,b
        nega
        adda    #31
.endif        
        tfr     d,x                     ; Back to HL/X
        puls    b
        rts
        
; $1A5C
clear_screen:
        ldx     #vram
1$:     clr     ,x+
.ifndef BUILD_OPT_ROTATED
        cmpx    #(vram+0x1C00+32)
.else
        cmpx    #(vram+(32+225)*VIDEO_BPL)
.endif        
        bne     1$
        rts

; $1A69
; Logically OR the player's shields back onto the playfield
; DE/Y = sprite
; HL/X = screen
; C = bytes per row
; B = number of rows
restore_shields:
1$:     pshs    x
        ldb     *z80_c
2$:     lda     ,y+                     ; From sprite
        ora     ,x                      ; OR with screen
        sta     ,x+                     ; Back to screen
        decb
        bne     2$
        puls    x                       ; Original start
        leax    32,x                    ; Bump X by one screen row
        dec     *z80_b                  ; Row counter
        bne     1$
        rts

; $1A7F
remove_ship:
; Remove a ship from the players stash and update the
; hold indicators on the screen.
        jsr     sub_092E                ; Get last byte from player data
        bne     1$
        rts
1$:     pshs    a                       ; Preserve number remaining
        deca                            ; Remove a ship from the stash
        sta     ,x                      ; New number of ships
        jsr     draw_num_ships
        puls    a                       ; Restore number
loc_1A8B:        
        LDX_VRAM  0x0101
        anda    #0x0f                   ; Make sure it is a digit
        jmp     sub_09C5                ; Print number remaining

; this will align the data with the original
; used in debugging to check we ave every byte of data
        .org    code_base+0x1A95

.ifndef BUILD_OPT_ROTATED
  .include "si_org_dat.asm"
.else
  .include "si_rot_dat.asm"
.endif

				.end		start_coco
