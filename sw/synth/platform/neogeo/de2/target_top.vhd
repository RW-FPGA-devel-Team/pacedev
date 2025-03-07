library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.project_pkg.all;
use work.target_pkg.all;

entity target_top is
  port
  (
		--////////////////////	Clock Input	 	////////////////////	 
		clock_27      : in std_logic;                         --	27 MHz
		clock_50      : in std_logic;                         --	50 MHz
		ext_clock     : in std_logic;                         --	External Clock
		--////////////////////	Push Button		////////////////////
		key           : in std_logic_vector(3 downto 0);      --	Pushbutton[3:0]
		--////////////////////	DPDT Switch		////////////////////
		sw            : in std_logic_vector(17 downto 0);     --	Toggle Switch[17:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		hex4          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 4
		hex5          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 5
		hex6          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 6
		hex7          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 7
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(8 downto 0);     --	LED Green[8:0]
		ledr          : out std_logic_vector(17 downto 0);    --	LED Red[17:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		irda_txd      : out std_logic;                        --	IRDA Transmitter
		irda_rxd      : in std_logic;                         --	IRDA Receiver
		--/////////////////////	SDRAM Interface		////////////////
		dram_dq       : inout std_logic_vector(15 downto 0);  --	SDRAM Data bus 16 Bits
		dram_addr     : out std_logic_vector(11 downto 0);    --	SDRAM Address bus 12 Bits
		dram_ldqm     : out std_logic;                        --	SDRAM Low-byte Data Mask 
		dram_udqm     : out std_logic;                        --	SDRAM High-byte Data Mask
		dram_we_n     : out std_logic;                        --	SDRAM Write Enable
		dram_cas_n    : out std_logic;                        --	SDRAM Column Address Strobe
		dram_ras_n    : out std_logic;                        --	SDRAM Row Address Strobe
		dram_cs_n     : out std_logic;                        --	SDRAM Chip Select
		dram_ba_0     : out std_logic;                        --	SDRAM Bank Address 0
		dram_ba_1     : out std_logic;                        --	SDRAM Bank Address 0
		dram_clk      : out std_logic;                        --	SDRAM Clock
		dram_cke      : out std_logic;                        --	SDRAM Clock Enable
		--////////////////////	Flash Interface		////////////////
		fl_dq         : inout std_logic_vector(7 downto 0);   --	FLASH Data bus 8 Bits
		fl_addr       : out std_logic_vector(21 downto 0);    --	FLASH Address bus 22 Bits
		fl_we_n       : out std_logic;                        -- 	FLASH Write Enable
		fl_rst_n      : out std_logic;                        --	FLASH Reset
		fl_oe_n       : out std_logic;                        --	FLASH Output Enable
		fl_ce_n       : out std_logic;                        --	FLASH Chip Enable
		--////////////////////	SRAM Interface		////////////////
		sram_dq       : inout std_logic_vector(15 downto 0);  --	SRAM Data bus 16 Bits
		sram_addr     : out std_logic_vector(17 downto 0);    --	SRAM Address bus 18 Bits
		sram_ub_n     : out std_logic;                        --	SRAM High-byte Data Mask 
		sram_lb_n     : out std_logic;                        --	SRAM Low-byte Data Mask 
		sram_we_n     : out std_logic;                        --	SRAM Write Enable
		sram_ce_n     : out std_logic;                        --	SRAM Chip Enable
		sram_oe_n     : out std_logic;                        --	SRAM Output Enable
		--////////////////////	ISP1362 Interface	////////////////
		otg_data      : inout std_logic_vector(15 downto 0);  --	ISP1362 Data bus 16 Bits
		otg_addr      : out std_logic_vector(1 downto 0);     --	ISP1362 Address 2 Bits
		otg_cs_n      : out std_logic;                        --	ISP1362 Chip Select
		otg_rd_n      : out std_logic;                        --	ISP1362 Write
		otg_wr_n      : out std_logic;                        --	ISP1362 Read
		otg_rst_n     : out std_logic;                        --	ISP1362 Reset
		otg_fspeed    : out std_logic;                        --	USB Full Speed,	0 = Enable, Z = Disable
		otg_lspeed    : out std_logic;                        --	USB Low Speed, 	0 = Enable, Z = Disable
		otg_int0 			: in std_logic;                         --	ISP1362 Interrupt 0
		otg_int1 			: in std_logic;                         --	ISP1362 Interrupt 1
		otg_dreq0 		: in std_logic;                         --	ISP1362 DMA Request 0
		otg_dreq1 		: in std_logic;                         --	ISP1362 DMA Request 1
		otg_dack0_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 0
		otg_dack1_n   : out std_logic;                        --	ISP1362 DMA Acknowledge 1
		--////////////////////	LCD Module 16X2		////////////////
		lcd_data      : inout std_logic_vector(7 downto 0);   --	LCD Data bus 8 bits
		lcd_on        : out std_logic;                        --	LCD Power ON/OFF
		lcd_blon      : out std_logic;                        --	LCD Back Light ON/OFF
		lcd_rw        : out std_logic;                        --	LCD Read/Write Select, 0 = Write, 1 = Read
		lcd_en        : out std_logic;                        --	LCD Enable
		lcd_rs        : out std_logic;                        --	LCD Command/Data Select, 0 = Command, 1 = Data
		--////////////////////	SD_Card Interface	////////////////
		sd_dat        : inout std_logic;                      --	SD Card Data
		sd_dat3       : inout std_logic;                      --	SD Card Data 3
		sd_cmd        : inout std_logic;                      --	SD Card Command Signal
		sd_clk        : out std_logic;                        --	SD Card Clock
		--////////////////////	USB JTAG link	////////////////////
		tdi           : in std_logic;                         -- CPLD -> FPGA (data in)
		tck           : in std_logic;                         -- CPLD -> FPGA (clk)
		tcs           : in std_logic;                         -- CPLD -> FPGA (CS)
	  tdo           : out std_logic;                        -- FPGA -> CPLD (data out)
		--////////////////////	I2C		////////////////////////////
		i2c_sdat      : inout std_logic;                      --	I2C Data
		i2c_sclk      : out std_logic;                        --	I2C Clock
		--////////////////////	PS2		////////////////////////////
		ps2_dat       : in std_logic;                         --	PS2 Data
		ps2_clk       : in std_logic;                         --	PS2 Clock
		--////////////////////	VGA		////////////////////////////
		vga_clk       : out std_logic;                        --	VGA Clock
		vga_hs        : out std_logic;                        --	VGA H_SYNC
		vga_vs        : out std_logic;                        --	VGA V_SYNC
		vga_blank     : out std_logic;                        --	VGA BLANK
		vga_sync      : out std_logic;                        --	VGA SYNC
		vga_r         : out std_logic_vector(9 downto 0);     --	VGA Red[9:0]
		vga_g         : out std_logic_vector(9 downto 0);     --	VGA Green[9:0]
		vga_b         : out std_logic_vector(9 downto 0);     --	VGA Blue[9:0]
		--////////////	Ethernet Interface	////////////////////////
		enet_data     : inout std_logic_vector(15 downto 0);  --	DM9000A DATA bus 16Bits
		enet_cmd      : out std_logic;                        --	DM9000A Command/Data Select, 0 = Command, 1 = Data
		enet_cs_n     : out std_logic;                        --	DM9000A Chip Select
		enet_wr_n     : out std_logic;                        --	DM9000A Write
		enet_rd_n     : out std_logic;                        --	DM9000A Read
		enet_rst_n    : out std_logic;                        --	DM9000A Reset
		enet_int      : in std_logic;                         --	DM9000A Interrupt
		enet_clk      : out std_logic;                        --	DM9000A Clock 25 MHz
		--////////////////	Audio CODEC		////////////////////////
		aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
		aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
		aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
		aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
		aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
		aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
		--////////////////	TV Decoder		////////////////////////
		td_data       : in std_logic_vector(7 downto 0);      --	TV Decoder Data bus 8 bits
		td_hs         : in std_logic;                         --	TV Decoder H_SYNC
		td_vs         : in std_logic;                         --	TV Decoder V_SYNC
		td_reset      : out std_logic;                        --	TV Decoder Reset
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );

end target_top;

architecture SYN of target_top is

	component I2C_AV_Config
		port
		(
			-- 	Host Side
			iCLK					: in std_logic;
			iRST_N				: in std_logic;
			--	I2C Side
			I2C_SCLK			: out std_logic;
			I2C_SDAT			: inout std_logic
		);
	end component I2C_AV_Config;

  component I2S_LCM_Config 
    port
    (   --  Host Side
            iCLK      : in std_logic;
      iRST_N    : in std_logic;
      --    I2C Side
      I2S_SCLK  : out std_logic;
      I2S_SDAT  : out std_logic;
      I2S_SCEN  : out std_logic
    );
  end component I2S_LCM_Config;

  component SEG7_LUT is
    port (
      iDIG : in std_logic_vector(3 downto 0); 
      oSEG : out std_logic_vector(6 downto 0)
    );
  end component;

  component LCD_TEST 
    port
    (	--	Host Side
			iCLK          : in std_logic;
      iRST_N        : in std_logic;
			iLINE1				: in std_logic_vector(127 downto 0);
			iLINE2				: in std_logic_vector(127 downto 0);
			--	LCD Side
			LCD_DATA      : out std_logic_vector(7 downto 0);
      LCD_RW        : out std_logic;
      LCD_EN        : out std_logic;
      LCD_RS        : out std_logic
   	);
  end component LCD_TEST;

	alias gpio_maple 		: std_logic_vector(35 downto 0) is gpio_0;
	alias gpio_lcd 			: std_logic_vector(35 downto 0) is gpio_1;
	
	signal clk_i			  : std_logic_vector(0 to 3);
  signal init       	: std_logic := '1';
  signal reset_i     	: std_logic := '1';
	signal reset_n			: std_logic := '0';

  signal buttons_i    : from_BUTTONS_t;
  signal switches_i   : from_SWITCHES_t;
  signal leds_o       : to_LEDS_t;
  signal inputs_i     : from_INPUTS_t;
  signal flash_i      : from_FLASH_t;
  signal flash_o      : to_FLASH_t;
	signal sram_i			  : from_SRAM_t;
	signal sram_o			  : to_SRAM_t;	
	signal sdram_i      : from_SDRAM_t;
	signal sdram_o      : to_SDRAM_t;
	signal video_i      : from_VIDEO_t;
  signal video_o      : to_VIDEO_t;
  signal audio_i      : from_AUDIO_t;
  signal audio_o      : to_AUDIO_t;
  signal ser_i        : from_SERIAL_t;
  signal ser_o        : to_SERIAL_t;
  
	-- maple/dreamcast controller interface
	signal maple_sense	: std_logic;
	signal maple_oe			: std_logic;
	signal mpj					: work.maple_pkg.joystate_type;

	-- gamecube controller interface
	signal gcj						: work.gamecube_pkg.joystate_type;
			
  signal lcm_sclk   	: std_logic;
  signal lcm_sdat   	: std_logic;
  signal lcm_scen   	: std_logic;
  signal lcm_data   	: std_logic_vector(7 downto 0);
  signal lcm_grst  		: std_logic;
  signal lcm_hsync  	: std_logic;
  signal lcm_vsync  	: std_logic;
	signal lcm_dclk  		: std_logic;
	signal lcm_shdb  		: std_logic;
	signal lcm_clk			: std_logic;

  signal yoffs      	: std_logic_vector(7 downto 0);

  signal pwmen      	: std_logic;
  signal chaseen    	: std_logic;
	
begin

  BLK_CLOCKING : block
  begin
  
    pll_50_inst : entity work.neogeo_pll
      port map
      (
        inclk0		=> clock_50,
        c0		    => clk_i(1),    -- 12.5MHz
        c1		    => clk_i(0),    -- 100MHz
        c2		    => dram_clk
      );
    
    GEN_NO_PLL : if not PACE_HAS_PLL generate

      -- feed input clocks into PACE core
      clk_i(0) <= clock_50;
      clk_i(1) <= clock_27;
        
    end generate GEN_NO_PLL;
      
    pll_27_inst : entity work.pll
      generic map
      (
        -- INCLK0
        INCLK0_INPUT_FREQUENCY  => 37037,

        -- CLK0 - 18M432Hz for audio
        CLK0_DIVIDE_BY          => 22,
        CLK0_MULTIPLY_BY        => 15,
    
        -- CLK1 - not used
        CLK1_DIVIDE_BY          => 1,
        CLK1_MULTIPLY_BY        => 1
      )
      port map
      (
        inclk0  => clock_27,
        c0      => clk_i(2),
        c1      => clk_i(3)
      );

  end block BLK_CLOCKING;
  
	-- FPGA STARTUP
	-- should extend power-on reset if registers init to '0'
	process (clock_50)
		variable count : std_logic_vector (11 downto 0) := (others => '0');
	begin
		if rising_edge(clock_50) then
			if count = X"FFF" then
				init <= '0';
			else
				count := count + 1;
				init <= '1';
			end if;
		end if;
	end process;

  reset_i <= init or not key(0);
	reset_n <= not reset_i;
	
  -- buttons - active low
  buttons_i <= std_logic_vector(resize(unsigned(not key), buttons_i'length));
  -- switches - up = high
  switches_i <= std_logic_vector(resize(unsigned(sw), switches_i'length));
  -- leds
  ledr <= leds_o(ledr'range);
  
	-- inputs
	inputs_i.ps2_kclk <= ps2_clk;
	inputs_i.ps2_kdat <= ps2_dat;
  inputs_i.ps2_mclk <= '0';
  inputs_i.ps2_mdat <= '0';

	GEN_MAPLE : if PACE_JAMMA = PACE_JAMMA_MAPLE generate
	
		-- Dreamcast MapleBus joystick interface
		MAPLE_JOY_inst : maple_joy
			port map
			(
				clk				=> clock_50,
				reset			=> reset_i,
				sense			=> maple_sense,
				oe				=> maple_oe,
				a					=> gpio_maple(14),
				b					=> gpio_maple(13),
				joystate	=> mpj
			);
		gpio_maple(12) <= maple_oe;
		gpio_maple(11) <= not maple_oe;
		maple_sense <= gpio_maple(17); -- and sw(0);

		-- map maple bus to jamma inputs
		-- - same mappings as default mappings for MAMED (DCMAME)
		inputs_i.jamma_n.coin(1) 				  <= mpj.lv(7);		-- MSB of right analogue trigger (0-255)
		inputs_i.jamma_n.p(1).start 			<= mpj.start;
		inputs_i.jamma_n.p(1).up 				  <= mpj.d_up;
		inputs_i.jamma_n.p(1).down 			  <= mpj.d_down;
		inputs_i.jamma_n.p(1).left	 			<= mpj.d_left;
		inputs_i.jamma_n.p(1).right 			<= mpj.d_right;
		inputs_i.jamma_n.p(1).button(1) 	<= mpj.a;
		inputs_i.jamma_n.p(1).button(2) 	<= mpj.x;
		inputs_i.jamma_n.p(1).button(3) 	<= mpj.b;
		inputs_i.jamma_n.p(1).button(4) 	<= mpj.y;
		inputs_i.jamma_n.p(1).button(5)	  <= '1';

	end generate GEN_MAPLE;

	GEN_GAMECUBE : if PACE_JAMMA = PACE_JAMMA_NGC generate
	
		GC_JOY: gamecube_joy
			generic map( MHZ => 50 )
  		port map
		  (
  			clk 				=> clock_50,
				reset 			=> reset_i,
				--oe 					=> gc_oe,
				d 					=> gpio_0(25),
				joystate 		=> gcj
			);

		-- map gamecube controller to jamma inputs
		inputs_i.jamma_n.coin(1) <= not gcj.l;
		inputs_i.jamma_n.p(1).start <= not gcj.start;
		inputs_i.jamma_n.p(1).up <= not gcj.d_up;
		inputs_i.jamma_n.p(1).down <= not gcj.d_down;
		inputs_i.jamma_n.p(1).left <= not gcj.d_left;
		inputs_i.jamma_n.p(1).right <= not gcj.d_right;
		inputs_i.jamma_n.p(1).button(1) <= not gcj.a;
		inputs_i.jamma_n.p(1).button(2) <= not gcj.b;
		inputs_i.jamma_n.p(1).button(3) <= not gcj.x;
		inputs_i.jamma_n.p(1).button(4) <= not gcj.y;
		inputs_i.jamma_n.p(1).button(5)	<= not gcj.z;

	end generate GEN_GAMECUBE;
	
	GEN_NO_JAMMA : if PACE_JAMMA = PACE_JAMMA_NONE generate
		inputs_i.jamma_n.coin(1) <= '1';
		inputs_i.jamma_n.p(1).start <= '1';
		inputs_i.jamma_n.p(1).up <= '1';
		inputs_i.jamma_n.p(1).down <= '1';
		inputs_i.jamma_n.p(1).left <= '1';
		inputs_i.jamma_n.p(1).right <= '1';
		inputs_i.jamma_n.p(1).button <= (others => '1');
  end generate GEN_NO_JAMMA;

	-- not currently wired to any inputs
	inputs_i.jamma_n.coin_cnt <= (others => '1');
	inputs_i.jamma_n.coin(2) <= '1';
	inputs_i.jamma_n.p(2).start <= '1';
  inputs_i.jamma_n.p(2).up <= '1';
  inputs_i.jamma_n.p(2).down <= '1';
	inputs_i.jamma_n.p(2).left <= '1';
	inputs_i.jamma_n.p(2).right <= '1';
	inputs_i.jamma_n.p(2).button <= (others => '1');
	inputs_i.jamma_n.service <= '1';
	inputs_i.jamma_n.tilt <= '1';
	inputs_i.jamma_n.test <= '1';
		
	-- show JAMMA inputs on LED bank
	GEN_JAMMA_LEDS : if false generate
    ledr(17) <= not inputs_i.jamma_n.coin(1);
    ledr(16) <= not inputs_i.jamma_n.coin(2);
    ledr(15) <= not inputs_i.jamma_n.p(1).start;
    ledr(14) <= not inputs_i.jamma_n.p(1).up;
    ledr(13) <= not inputs_i.jamma_n.p(1).down;
    ledr(12) <= not inputs_i.jamma_n.p(1).left;
    ledr(11) <= not inputs_i.jamma_n.p(1).right;
    ledr(10) <= not inputs_i.jamma_n.p(1).button(1);
    ledr(9) <= not inputs_i.jamma_n.p(1).button(2);
    ledr(8) <= not inputs_i.jamma_n.p(1).button(3);
    ledr(7) <= not inputs_i.jamma_n.p(1).button(4);
    ledr(6) <= not inputs_i.jamma_n.p(1).button(5);
    ledr(5 downto 0) <= (others => '0');
  end generate GEN_JAMMA_LEDS;
  
  -- flash memory
  BLK_FLASH : block
  begin
    fl_rst_n <= '1';

    GEN_FLASH : if PACE_HAS_FLASH generate
      flash_i.d <= fl_dq;
      fl_dq <=  flash_o.d when (flash_o.cs = '1' and flash_o.we = '1' and flash_o.oe = '0') else 
                (others => 'Z');
      fl_addr <= flash_o.a;
      fl_we_n <= not flash_o.we;
      fl_oe_n <= not flash_o.oe;
      fl_ce_n <= not flash_o.cs;
    end generate GEN_FLASH;
    
    GEN_NO_FLASH : if not PACE_HAS_FLASH generate
      flash_i.d <= (others => '1');
      fl_dq <= (others => 'Z');
      fl_addr <= (others => 'Z');
      fl_ce_n <= '1';
      fl_oe_n <= '1';
      fl_we_n <= '1';
    end generate GEN_NO_FLASH;

  end block BLK_FLASH;
  
  -- static memory
  BLK_SRAM : block
  begin
  
    GEN_SRAM : if PACE_HAS_SRAM generate
      sram_addr <= sram_o.a(sram_addr'range);
      sram_i.d <= std_logic_vector(resize(unsigned(sram_dq), sram_i.d'length));
      sram_dq <= sram_o.d(sram_dq'range) when (sram_o.cs = '1' and sram_o.we = '1') else (others => 'Z');
      sram_ub_n <= not sram_o.be(1);
      sram_lb_n <= not sram_o.be(0);
      sram_ce_n <= not sram_o.cs;
      sram_oe_n <= not sram_o.oe;
      sram_we_n <= not sram_o.we;
    end generate GEN_SRAM;
    
    GEN_NO_SRAM : if not PACE_HAS_SRAM generate
      sram_addr <= (others => 'Z');
      sram_i.d <= (others => '1');
      sram_dq <= (others => 'Z');
      sram_ub_n <= '1';
      sram_lb_n <= '1';
      sram_ce_n <= '1';
      sram_oe_n <= '1';
      sram_we_n <= '1';  
    end generate GEN_NO_SRAM;
    
  end block BLK_SRAM;

  BLK_SDRAM : block
  begin

    GEN_NO_SDRAM : if not PACE_HAS_SDRAM generate
      dram_addr <= (others => 'Z');
      dram_we_n <= '1';
      dram_cs_n <= '1';
      dram_clk <= '0';
      dram_cke <= '0';
    end generate GEN_NO_SDRAM;
  
    GEN_SDRAM : if PACE_HAS_SDRAM generate
      sdram_i.d <= std_logic_vector(resize(unsigned(dram_dq), sdram_i.d'length));
      dram_dq <= sdram_o.d(dram_dq'range) when sdram_o.we_n = '0' else (others => 'Z');
      dram_addr <= sdram_o.a(dram_addr'range);
      dram_ldqm <= sdram_o.ldqm;
      dram_udqm <= sdram_o.udqm;
      dram_we_n <= sdram_o.we_n;
      dram_cas_n <= sdram_o.cas_n;
      dram_ras_n <= sdram_o.ras_n;
      dram_cs_n <= sdram_o.cs_n;
      dram_ba_0 <= sdram_o.ba(0);
      dram_ba_1 <= sdram_o.ba(1);
      dram_clk <= sdram_o.clk;
      dram_cke <= sdram_o.cke;
    end generate GEN_SDRAM;
    
  end block BLK_SDRAM;

  BLK_VIDEO : block
  begin

		video_i.clk <= clk_i(1);	-- by convention
		process (clk_i(1))
    begin
      if reset_i = '1' then
        video_i.clk_ena <= '0';
      elsif rising_edge(clk_i(1)) then
        video_i.clk_ena <= not video_i.clk_ena;
      end if;
    end process;
    video_i.reset <= reset_i;
    
    vga_clk <= video_o.clk;
    vga_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-9);
    vga_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-9);
    vga_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-9);
    vga_hs <= video_o.hsync;
    vga_vs <= video_o.vsync;
    vga_sync <= video_o.hsync and video_o.vsync;
    vga_blank <= '1';

  end block BLK_VIDEO;

  BLK_AUDIO : block
    alias aud_clk    		: std_logic is clk_i(2);
    signal aud_data_l  	: std_logic_vector(audio_o.ldata'range);
    signal aud_data_r  	: std_logic_vector(audio_o.rdata'range);
  begin

    -- enable each channel independantly for debugging
    aud_data_l <= audio_o.ldata when switches_i(9) = '0' else (others => '0');
    aud_data_r <= audio_o.rdata when switches_i(8) = '0' else (others => '0');

    -- Audio
    audif_inst : entity work.audio_if
      generic map 
      (
        REF_CLK       => 18432000,  -- Set REF clk frequency here
        SAMPLE_RATE   => 48000,     -- 48000 samples/sec
        DATA_WIDTH    => 16,			  --	16		Bits
        CHANNEL_NUM   => 2  			  --	Dual Channel
      )
      port map
      (
        -- Inputs
        clk           => aud_clk,
        reset         => reset_i,
        datal         => aud_data_l,
        datar         => aud_data_r,
    
        -- Outputs
        aud_xck       => aud_xck,
        aud_adclrck   => aud_adclrck,
        aud_daclrck   => aud_daclrck,
        aud_bclk      => aud_bclk,
        aud_dacdat    => aud_dacdat,
        next_sample   => open
      );

  end block BLK_AUDIO;
  
  BLK_SERIAL : block
  begin
    GEN_NO_SERIAL : if not PACE_HAS_SERIAL generate
      uart_txd <='0';
      ser_i.rxd <= '0';
    end generate GEN_NO_SERIAL;
  end block BLK_SERIAL;
  
  -- turn off LEDs
  hex0 <= (others => '1');
  hex1 <= (others => '1');
  hex2 <= (others => '1');
  hex3 <= (others => '1');
  hex4 <= (others => '1');
  hex5 <= (others => '1');
  --hex6 <= (others => '1');
  --hex7 <= (others => '1');
  ledg(8) <= '0';
  --ledr(17 downto 8) <= (others => '0');

  -- disable SD card
  sd_clk <= '0';
  sd_dat <= 'Z';
  sd_dat3 <= 'Z';
  sd_cmd <= 'Z';

  -- disable JTAG
  tdo <= 'Z';
  
	-- no IrDA
	irda_txd <= 'Z';
	
  -- disable USB
  otg_data <= (others => 'Z');
  otg_addr <= (others => 'Z');
  otg_cs_n <= '1';
  otg_rd_n <= '1';
  otg_wr_n <= '1';
  otg_rst_n <= '1';

	BLK_LCD_TEST : block
		signal iline1 : std_logic_vector(127 downto 0);
		signal iline2 : std_logic_vector(127 downto 0);
	begin

		GEN_LINES : for i in 0 to 15 generate
			iline1(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE1(i+1)),8));
			iline2(i*8+7 downto i*8) <= std_logic_vector(to_unsigned(character'pos(DE2_LCD_LINE2(i+1)),8));
		end generate GEN_LINES;

	  -- LCD
	  lcd_on <= '1';
	  lcd_blon <= '1';
	  lcdt: LCD_TEST 
	    port map
	    (	--	Host Side
				iCLK      => clock_50,
	      iRST_N    => reset_n,
				iLINE1		=> iline1,
				iLINE2		=> iline2,
				--	LCD Side
				LCD_DATA  => lcd_data,
	      LCD_RW    => lcd_rw,
	      LCD_EN    => lcd_en,
	      LCD_RS    => lcd_rs
	   	);

	end block BLK_LCD_TEST;

  -- disable ethernet
  enet_data <= (others => 'Z');
  enet_cs_n <= '1';
  enet_wr_n <= '1';
  enet_rd_n <= '1';
  enet_rst_n <= '0';
  enet_clk <= '0';

  -- Display funkalicious pacman sprite y offset on 7seg display
  -- Why?  Because we can
  seg7_0: SEG7_LUT port map (iDIG => yoffs(7 downto 4), oSEG => hex7);
  seg7_1: SEG7_LUT port map (iDIG => yoffs(3 downto 0), oSEG => hex6);

  -- *MUST* be high to use 27MHz clock as input
  td_reset <= '1';

  -- GPIO
  gpio_0 <= (others => 'Z');
  gpio_1 <= (others => 'Z');
    
  -- LCM signals
  gpio_lcd(19) <= lcm_data(7);
  gpio_lcd(18) <= lcm_data(6);
  gpio_lcd(21) <= lcm_data(5);
  gpio_lcd(20) <= lcm_data(4);
  gpio_lcd(23) <= lcm_data(3);
  gpio_lcd(22) <= lcm_data(2);
  gpio_lcd(25) <= lcm_data(1);
  gpio_lcd(24) <= lcm_data(0);
  gpio_lcd(30) <=	lcm_grst;
  gpio_lcd(26) <= lcm_vsync;
  gpio_lcd(35) <= lcm_hsync;
	gpio_lcd(29) <= lcm_dclk;
	gpio_lcd(31) <= lcm_shdb;
  gpio_lcd(28) <=	lcm_sclk;
  gpio_lcd(33) <=	lcm_scen;
  gpio_lcd(34) <= lcm_sdat;

  lcmc: I2S_LCM_Config
    port map
    (   --  Host Side
      iCLK => clock_50,
      iRST_N => reset_n, --lcm_grst_n,
      --    I2C Side
      I2S_SCLK => lcm_sclk,
      I2S_SDAT => lcm_sdat,
      I2S_SCEN => lcm_scen
    );

	lcm_clk <= video_o.clk;
	lcm_grst <= reset_n;
  lcm_dclk	<=	not lcm_clk;
  lcm_shdb	<=	'1';
	lcm_hsync <= video_o.hsync;
	lcm_vsync <= video_o.vsync;
	
  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clk_i							=> clk_i,
      reset_i          	=> reset_i,

      -- misc inputs and outputs
      buttons_i         => buttons_i,
      switches_i        => switches_i,
      leds_o            => leds_o,
      
      -- controller inputs
      inputs_i          => inputs_i,

     	-- external ROM/RAM
     	flash_i           => flash_i,
      flash_o           => flash_o,
      sram_i        		=> sram_i,
      sram_o        		=> sram_o,
     	sdram_i           => sdram_i,
     	sdram_o           => sdram_o,
  
      -- VGA video
      video_i           => video_i,
      video_o           => video_o,
      
      -- sound
      audio_i           => audio_i,
      audio_o           => audio_o,

      -- SPI (flash)
      spi_i.din         => '0',
      spi_o             => open,
  
      -- serial
      ser_i             => ser_i,
      ser_o             => ser_o,
      
      -- general purpose
      gp_i              => (others => '0'),
      gp_o              => open
    );

	av_init : I2C_AV_Config
		port map
		(
			--	Host Side
			iCLK							=> clock_50,
			iRST_N						=> reset_n,
			
			--	I2C Side
			I2C_SCLK					=> I2C_SCLK,
			I2C_SDAT					=> I2C_SDAT
		);

  pchaser: work.pwm_chaser 
	  generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
    port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => reset_i, fade => X"0F", ledout => ledg(7 downto 0));

  -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
  process(clock_50, reset_i)
    variable pcount     : std_logic_vector(9 downto 0);
    variable pwmen_r    : std_logic;
    variable ccount     : std_logic_vector(18 downto 0);
    variable chaseen_r  : std_logic;
  begin
    pwmen <= pwmen_r;
    chaseen <= chaseen_r;
    if reset_i = '1' then
      pcount := (others => '0');
      ccount := (others => '0');
    elsif rising_edge(clock_50) then
      pwmen_r := '0';
      if pcount = std_logic_vector(to_unsigned(0, pcount'length)) then
        pwmen_r := '1';
      end if;
      chaseen_r := '0';
      if ccount = std_logic_vector(to_unsigned(0, ccount'length)) then
        chaseen_r := '1';
      end if;
      pcount := pcount + 1;
      ccount := ccount + 1;
    end if;
  end process;

  -- LED chaser
--  process (clock_50, reset)
--    variable count : integer range 0 to 4999999;
--    variable led : std_logic_vector(ledr'left downto ledr'right);
--    variable led_dir : std_logic;
--  begin
--    if reset = '1' then
--      count := 0;
--      led_dir := '0';
--      led := "000000000000000001";
--    elsif rising_edge(clock_50) then
--      if count = 0 then
--        count := 4999999; -- 100ms
--        if (led_dir = '0' and led(led'left) = '1') or (led_dir = '1' and led(led'right) = '1') then
--          led_dir := not led_dir;
--        end if;
--        if led_dir = '0' then
--          led := led(led'left-1 downto led'right) & "0";
--        else
--          led := "0" & led(led'left downto led'right+1);
--        end if;
--      else
--        count := count - 1;
--      end if;
--    end if;
--    -- assign outputs
--    ledr <= led;
--  end process;
		    
end SYN;

