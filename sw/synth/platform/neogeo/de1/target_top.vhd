library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.maple_pkg.all;
use work.gamecube_pkg.all;
use work.sdram_pkg.all;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

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
		sw            : in std_logic_vector(9 downto 0);     --	Toggle Switch[9:0]
		--////////////////////	7-SEG Dispaly	////////////////////
		hex0          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 0
		hex1          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 1
		hex2          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 2
		hex3          : out std_logic_vector(6 downto 0);     --	Seven Segment Digit 3
		--////////////////////////	LED		////////////////////////
		ledg          : out std_logic_vector(7 downto 0);     --	LED Green[8:0]
		ledr          : out std_logic_vector(9 downto 0);    --	LED Red[17:0]
		--////////////////////////	UART	////////////////////////
		uart_txd      : out std_logic;                        --	UART Transmitter
		uart_rxd      : in std_logic;                         --	UART Receiver
		--////////////////////////	IRDA	////////////////////////
		-- irda_txd      : out std_logic;                        --	IRDA Transmitter
		-- irda_rxd      : in std_logic;                         --	IRDA Receiver
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
		vga_r         : out std_logic_vector(3 downto 0);     --	VGA Red[3:0]
		vga_g         : out std_logic_vector(3 downto 0);     --	VGA Green[3:0]
		vga_b         : out std_logic_vector(3 downto 0);     --	VGA Blue[3:0]
		--////////////////	Audio CODEC		////////////////////////
		aud_adclrck   : out std_logic;                        --	Audio CODEC ADC LR Clock
		aud_adcdat    : in std_logic;                         --	Audio CODEC ADC LR Clock	Audio CODEC ADC Data
		aud_daclrck   : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC DAC LR Clock
		aud_dacdat    : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC DAC Data
		aud_bclk      : inout std_logic;                      --	Audio CODEC ADC LR Clock	Audio CODEC Bit-Stream Clock
		aud_xck       : out std_logic;                        --	Audio CODEC ADC LR Clock	Audio CODEC Chip Clock
		--////////////////////	GPIO	////////////////////////////
		gpio_0        : inout std_logic_vector(35 downto 0);  --	GPIO Connection 0
		gpio_1        : inout std_logic_vector(35 downto 0)   --	GPIO Connection 1
  );

end target_top;

architecture SYN of target_top is

  constant DE1_TEST_BURCHED_LEDS    : boolean := false;
  constant DE1_TEST_BURCHED_DIPS    : boolean := false;
  constant DE1_TEST_BURCHED_7SEG    : boolean := false;
  constant DE1_BURCHED_SRAM         : boolean := true;

	alias gpio_maple 		  : std_logic_vector(35 downto 0) is gpio_0;
	alias gpio_lcd 			  : std_logic_vector(35 downto 0) is gpio_1;
	
  signal init       	  : std_logic := '1';
	signal async_reset	  : std_logic := '0';
	signal async_reset_n	: std_logic := '1';

	signal clkrst_i			  : from_CLKRST_t;
  signal buttons_i      : from_BUTTONS_t;
  signal switches_i     : from_SWITCHES_t;
  signal leds_o         : to_LEDS_t;
  signal inputs_i       : from_INPUTS_t;
  signal flash_i        : from_FLASH_t;
  signal flash_o        : to_FLASH_t;
	signal sram_i			    : from_SRAM_t;
	signal sram_o			    : to_SRAM_t;	
	signal sdram_i        : from_SDRAM_t;
	signal sdram_o        : to_SDRAM_t;
	signal video_i        : from_VIDEO_t;
  signal video_o        : to_VIDEO_t;
  signal audio_i        : from_AUDIO_t;
  signal audio_o        : to_AUDIO_t;
  signal ser_i          : from_SERIAL_t;
  signal ser_o          : to_SERIAL_t;
  signal project_i      : from_PROJECT_IO_t;
  signal project_o      : to_PROJECT_IO_t;
  signal platform_i     : from_PLATFORM_IO_t;
  signal platform_o     : to_PLATFORM_IO_t;
  signal target_i       : from_TARGET_IO_t;
  signal target_o       : to_TARGET_IO_t;

  signal dram_clk_s   : std_logic;
  
	-- maple/dreamcast controller interface
	signal maple_sense	: std_logic;
	signal maple_oe			: std_logic;
	signal mpj				  : work.maple_pkg.joystate_type;

	-- gamecube controller interface
	signal gcj					: work.gamecube_pkg.joystate_type;
			
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

begin

  BLK_CLOCKING : block
  begin
  
    pll_50_inst : entity work.neogeo_pll
      port map
      (
        inclk0		=> clock_50,
        c0		    => clkrst_i.clk(1),    -- 25MHz
        c1		    => clkrst_i.clk(0),    -- 100MHz
        c2		    => dram_clk_s
      );
      
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
        c0      => clkrst_i.clk(2),
        c1      => clkrst_i.clk(3)
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

  async_reset <= init or not key(0);
	async_reset_n <= not async_reset;
	
  GEN_RESETS : for i in 0 to 3 generate

    process (clkrst_i.clk(i), async_reset)
      variable rst_r : std_logic_vector(2 downto 0) := (others => '0');
    begin
      if async_reset = '1' then
        rst_r := (others => '1');
      elsif rising_edge(clkrst_i.clk(i)) then
        rst_r := rst_r(rst_r'left-1 downto 0) & '0';
      end if;
      clkrst_i.rst(i) <= rst_r(rst_r'left);
    end process;

  end generate GEN_RESETS;
	
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
		MAPLE_JOY : entity work.maple_joy
			port map
			(
				clk				=> clock_50,
				reset			=> async_reset,
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
				reset 			=> async_reset,
				--oe 					=> gc_oe,
				d_i 				=> gpio_maple(25),
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
--	ledr(17) <= not jamma_n.coin(1);
--	ledr(16) <= not jamma_n.coin(2);
--	ledr(15) <= not jamma_n.p(1).start;
--	ledr(14) <= not jamma_n.p(1).up;
--	ledr(13) <= not jamma_n.p(1).down;
--	ledr(12) <= not jamma_n.p(1).left;
--	ledr(11) <= not jamma_n.p(1).right;
--	ledr(10) <= not jamma_n.p(1).button(1);
--	ledr(9) <= not jamma_n.p(1).button(2);
--	ledr(8) <= not jamma_n.p(1).button(3);
--	ledr(7) <= not jamma_n.p(1).button(4);
--	ledr(6) <= not jamma_n.p(1).button(5);

  -- flash memory
  BLK_FLASH : block
  begin
    fl_rst_n <= '1';

    GEN_FLASH : if PACE_HAS_FLASH generate
      flash_i.d <= std_logic_vector(RESIZE(unsigned(fl_dq),flash_i.d'length));
      fl_dq <=  flash_o.d(fl_dq'range) when (flash_o.cs = '1' and flash_o.we = '1' and flash_o.oe = '0') else 
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

      dram_clk <= dram_clk_s;

      sdram_inst : yadmc
        generic map
        (
          sdram_depth         => 23,
          sdram_columndepth   => 8,
          sdram_adrwires      => 12,
          sdram_bytes_depth   => 1,
          cache_depth         => 4,
          --sdram_bits          : natural := (8 << sdram_bytes_depth);
          sdram_bits          => 16,
          --cache_linedepth     : natural := sdram_bytes_depth + 1;
          cache_linedepth     => 2,
          --cache_linelength    : natural := (4 << cache_linedepth);
          cache_linelength    => 16,
          --cache_tagdepth      : natural := sdram_depth - cache_depth - cache_linedepth - 2
          cache_tagdepth      => 15
        )
        port map
        (
          -- Wishbone slave interface
          sys_clk       => sdram_o.clk,
          sys_rst       => sdram_o.rst,
          wb_adr_i      => sdram_o.a,
          wb_dat_i      => sdram_o.d,
          wb_dat_o      => sdram_i.d,
          wb_sel_i      => sdram_o.sel,
          wb_cyc_i      => sdram_o.cyc,
          wb_stb_i      => sdram_o.stb,
          wb_we_i       => sdram_o.we,
          wb_ack_o      => sdram_i.ack,

          -- SDRAM interface
          sdram_clk     => dram_clk_s,
          sdram_cke     => dram_cke,
          sdram_cs_n    => dram_cs_n,
          sdram_we_n    => dram_we_n,
          sdram_cas_n   => dram_cas_n,
          sdram_ras_n   => dram_ras_n,
          sdram_dqm(1)  => dram_udqm,
          sdram_dqm(0)  => dram_ldqm,
          sdram_adr     => dram_addr,
          sdram_ba(1)   => dram_ba_1,
          sdram_ba(0)   => dram_ba_0,
          sdram_dq      => dram_dq
        );

    end generate GEN_SDRAM;

  end block BLK_SDRAM;

  BLK_VIDEO : block
  begin

		video_i.clk <= clkrst_i.clk(1);	-- by convention
		process (clkrst_i.clk(1), clkrst_i.rst(1))
    begin
      if clkrst_i.rst(1) = '1' then
        video_i.clk_ena <= '0';
      elsif rising_edge(clkrst_i.clk(1)) then
        video_i.clk_ena <= not video_i.clk_ena;
      end if;
    end process;
    video_i.reset <= clkrst_i.rst(1);
    
    vga_clk <= video_o.clk;
    vga_r <= video_o.rgb.r(video_o.rgb.r'left downto video_o.rgb.r'left-3);
    vga_g <= video_o.rgb.g(video_o.rgb.g'left downto video_o.rgb.g'left-3);
    vga_b <= video_o.rgb.b(video_o.rgb.b'left downto video_o.rgb.b'left-3);
    vga_hs <= video_o.hsync;
    vga_vs <= video_o.vsync;
    vga_sync <= video_o.hsync and video_o.vsync;
    vga_blank <= '1';

  end block BLK_VIDEO;

  BLK_AUDIO : block
    alias aud_clk    		: std_logic is clkrst_i.clk(2);
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
        reset         => async_reset,
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
  
  -- disable SD card
  sd_clk <= '0';
  sd_dat <= 'Z';
  sd_dat3 <= 'Z';
  sd_cmd <= 'Z';

  -- disable JTAG
  tdo <= 'Z';
  
  -- *MUST* be high to use 27MHz clock as input
  -- td_reset <= '1';

  -- GPIO

  --gp_i(71 downto 36) <= gpio_0;
  --gp_i(35 downto 0) <= gpio_0;
  
  GEN_TEST_BURCHED_LEDS : if DE1_TEST_BURCHED_LEDS generate
  
    assert (PACE_JAMMA = PACE_JAMMA_NONE and
            PACE_VIDEO_CONTROLLER_TYPE /= PACE_VIDEO_LCM_320x240_60Hz and
            not DE1_TEST_BURCHED_DIPS and
            not DE1_TEST_BURCHED_7SEG and
            not DE1_BURCHED_SRAM)
      report "DE1_TEST_BURCHED_LEDS not compatible with other DE1 options"
        severity failure;

    process (clock_27, async_reset)
      variable r : std_logic_vector(15 downto 0);
      variable count : std_logic_vector(21 downto 0);
    begin
      if async_reset = '1' then
        r := (0=>'1', others => '0');
        count := (others => '0');
      elsif rising_edge(clock_27) then
        count := count + 1;
        if count = 0 then
          r := r(0) & r(r'left downto 1);
        end if;
      end if;
      gpio_0(17 downto 2) <= r;
      gpio_0(35 downto 20) <= not r;
    end process;
    
  end generate GEN_TEST_BURCHED_LEDS;
  
  GEN_BURCHED_SRAM : if DE1_BURCHED_SRAM generate
  
    assert (PACE_JAMMA = PACE_JAMMA_NONE and
            PACE_VIDEO_CONTROLLER_TYPE /= PACE_VIDEO_LCM_320x240_60Hz and
            not DE1_TEST_BURCHED_LEDS and
            not DE1_TEST_BURCHED_DIPS and
            not DE1_TEST_BURCHED_7SEG)
      report "GEN_BURCHED_SRAM not compatible with other DE1 options"
        severity failure;
      
    -- D0-7
    --gp_i(35 downto 28) <= gpio_0(35 downto 28);
    --gpio_0(35 downto 28) <= gp_o.d(35 downto 28) when gp_o.d(19) = '0' else (others => 'Z');
    -- D8-15
    --gp_i(27 downto 20) <= gpio_0(27 downto 20);
    --gpio_0(27 downto 20) <= gp_o.d(27 downto 20) when gp_o.d(18) = '0' else (others => 'Z');
    -- A & CEn & WEn
    --gpio_0(19 downto 0) <= gp_o.d(19 downto 0);

  end generate GEN_BURCHED_SRAM;
  
  --gpio_1 <= (others => 'Z');
    
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

  pace_inst : entity work.pace                                            
    port map
    (
    	-- clocks and resets
	  	clkrst_i					=> clkrst_i,

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
      
      -- custom i/o
      project_i         => project_i,
      project_o         => project_o,
      platform_i        => platform_i,
      platform_o        => platform_o,
      target_i          => target_i,
      target_o          => target_o
    );

  BLK_AV : block
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
  begin
    av_init : I2C_AV_Config
      port map
      (
        --	Host Side
        iCLK							=> clock_50,
        iRST_N						=> async_reset_n,
        
        --	I2C Side
        I2C_SCLK					=> I2C_SCLK,
        I2C_SDAT					=> I2C_SDAT
      );
  end block BLK_AV;

  BLK_LCM : block
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
  begin
    lcmc: I2S_LCM_Config
      port map
      (   --  Host Side
        iCLK => clock_50,
        iRST_N => async_reset_n, --lcm_grst_n,
        --    I2C Side
        I2S_SCLK => lcm_sclk,
        I2S_SDAT => lcm_sdat,
        I2S_SCEN => lcm_scen
      );

    lcm_clk <= video_o.clk;
    lcm_grst <= not clkrst_i.rst(1);
    lcm_dclk	<=	not lcm_clk;
    lcm_shdb	<=	'1';
    lcm_hsync <= video_o.hsync;
    lcm_vsync <= video_o.vsync;
  end block BLK_LCM;
  
  BLK_CHASER : block
    signal pwmen      	: std_logic;
    signal chaseen    	: std_logic;
  begin
  
    pchaser: entity work.pwm_chaser 
      generic map(nleds  => 8, nbits => 8, period => 4, hold_time => 12)
      port map (clk => clock_50, clk_en => chaseen, pwm_en => pwmen, reset => async_reset, fade => X"0F", ledout => ledg(7 downto 0));

    -- Generate pwmen pulse every 1024 clocks, chase pulse every 512k clocks
    process(clock_50, async_reset)
      variable pcount     : std_logic_vector(9 downto 0);
      variable pwmen_r    : std_logic;
      variable ccount     : std_logic_vector(18 downto 0);
      variable chaseen_r  : std_logic;
    begin
      pwmen <= pwmen_r;
      chaseen <= chaseen_r;
      if async_reset = '1' then
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
    
  end block BLK_CHASER;

  BLK_7_SEG : block
  
    component SEG7_LUT is
      port 
      (
        iDIG : in std_logic_vector(3 downto 0); 
        oSEG : out std_logic_vector(6 downto 0)
      );
    end component SEG7_LUT;

  begin
    -- from left to right on the PCB
    --seg7_3: SEG7_LUT port map (iDIG => gp_o.d(51 downto 48), oSEG => hex3);
    --seg7_2: SEG7_LUT port map (iDIG => gp_o.d(47 downto 44), oSEG => hex2);
    --seg7_1: SEG7_LUT port map (iDIG => gp_o.d(43 downto 40), oSEG => hex1);
    --seg7_0: SEG7_LUT port map (iDIG => gp_o.d(39 downto 36), oSEG => hex0);
  end block BLK_7_SEG;
  
end SYN;
