library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_syn_attributes.all;

library work;
use work.project_pkg.all;

entity target_top_ep4c is
	port
	(
    -- I2C on the DVI input connector
		dvi_eep_scl			: inout std_logic;
		dvi_eep_sda			: inout std_logic;
    dvi_dis_eep_ddc : out std_logic := '1';   -- disabled
    dvi_eep_wp      : out std_logic := 'Z';   -- default h/w

		dvi_fpg_scl			: inout std_logic;
		dvi_fpg_sda			: inout std_logic;
    dvi_dis_fpg_ddc : out std_logic := '0';   -- enabled

    dvi_en_i2c      : out std_logic := 'Z';
    dvi_connect     : out std_logic := '1';   -- connected
    dvi_oen         : out std_logic := '0';   -- enabled
    
    -- I2C on the DVI output connector
		dvo_scl			    : inout std_logic;
		dvo_sda			    : inout std_logic;

    -- I2C to the TFP410 (DVI out transmitter)
    vdo_scl         : inout std_logic;
    vdo_sda         : inout std_logic;
    
    -- I2C on the video ADC
		vai_scl			    : inout std_logic;
		vai_sda			    : inout std_logic;

    -- I2C on the SDVO to LVDS transceiver
		vsi_scl			    : inout std_logic;
		vsi_sda			    : inout std_logic;

		veb_ck_a		    : in std_logic;	-- Buffered copy of carrier 24MHz clock
		veb_ck_sp		    : in std_logic;	-- Spare clock output from carrier FPGA
		
		-- Carrier LPC bus interface
		veb_reset		    : in std_logic;
		veb_framen		  : in std_logic;
		veb_a			      : inout std_logic_vector(3 downto 0);
		veb_irqn		    : in std_logic;
		-- Spare I/O to carrier FPGA
		veb_sp			    : inout std_logic_vector(4 downto 0);

		veb_i2c_clk		  : inout std_logic;
		veb_i2c_dat		  : inout std_logic;
		veb_smb_clk		  : inout std_logic;
		veb_smb_dat		  : inout std_logic;

		-- Touchscreen serial ports
		ser_ts_tx		    : out std_logic;
		ser_ts_rx		    : in std_logic;
		ser_ts_rts	    : out std_logic;
		ser_ts_cts	    : in std_logic;
		ser_pc_tx		    : out std_logic;
		ser_pc_rx		    : in std_logic;
		ser_pc_rts	    : out std_logic;
		ser_pc_cts	    : in std_logic;

		-- LCD O RS485
		lcdo_rx			    : in std_logic;
		lcdo_tx			    : out std_logic;
		lcdo_rtsn		    : out std_logic;

		-- SRAM
		sram_a			    : out std_logic_vector(17 downto 0);
		sram_d			    : inout std_logic_vector(15 downto 0);
		sram_cs_n		    : out std_logic;
		sram_oe_n		    : out std_logic;
		sram_we_n		    : out std_logic;
		sram_ub_n		    : out std_logic;
		sram_lb_n		    : out std_logic;

		-- Internal USB controller, external PHY
		ul_spd			    : out std_logic;
		ul_rcv			    : in std_logic;
		ul_v			      : inout std_logic;
		ul_con			    : out std_logic;
		ul_sus			    : out std_logic;
		ul_vbusdet		  : in std_logic;
		ul_rsel			    : out std_logic;
		ul_oen			    : out std_logic;

		-- External USB controller
		uh_resetn	      : out std_logic;
		uh_a				    : out std_logic_vector(16 downto 1);
		uh_d				    : inout std_logic_vector(31 downto 0);
		uh_csn			    : out std_logic;
		uh_rdn			    : out std_logic;
		uh_wrn			    : out std_logic;
		uh_be           : out std_logic_vector(3 downto 0);
		uh_intn		      : in std_logic;
		uh_dreq		      : in std_logic_vector(1 downto 0);
		uh_dack			    : out std_logic_vector(1 downto 0);
		
		uh_clkin		    : out std_logic;
		
		-- Connection to video FPGA
		vid_reset       : inout std_logic;		-- Bridge reset
		vid_reset_core  : inout std_logic;		-- IP core reset
		vid_address		  : out std_logic_vector(10 downto 0);
		vid_data		    : inout std_logic_vector(15 downto 0);
		vid_write_n		  : out std_logic;
		vid_read_n		  : out std_logic;
		vid_waitrequest	: in std_logic;
		vid_irq_n			  : in std_logic;
		vid_clk			    : out std_logic;
		-- not used
    vid_spare       : in std_logic_vector(29 downto 28);
    
    -- LVDS
		vli_red         : out std_logic_vector(7 downto 0);
		vli_green       : out std_logic_vector(7 downto 0);
		vli_blue        : out std_logic_vector(7 downto 0);
		vli_hsync       : out std_logic;
		vli_vsync       : out std_logic;
		vli_de          : out std_logic;
		vli_locked      : out std_logic;
		vli_clk	        : out std_logic;
		
    -- I2C to the vid FPGA
		vid_scl			    : inout std_logic;
		vid_sda			    : inout std_logic;

		lvds_a			    : in std_logic_vector(3 downto 0);
		lvds_a_clk	    : in std_logic;
    --lvds_b			    : in std_logic_vector(3 downto 0);
    --lvds_b_clk	    : in std_logic;

    -- LVDS I2C
		lvds_i2c_dat    : inout std_logic;
		lvds_i2c_ck	    : inout std_logic;

    -- Power management signals
		v15_pgood		    : in std_logic;
		v15_s3			    : out std_logic;
		v15_s5			    : out std_logic;
		pok_12v			    : in std_logic;
		pok_5v			    : in std_logic;
		pok_3v3			    : in std_logic;
		pok_1v9			    : in std_logic;
		veb_pwrgoodn    : out std_logic;
		veb_i2c_alertn  : in std_logic;
	
    -- Video control signals
		lvds_sel		    : inout std_logic;
		vdi_pdn			    : out std_logic;
		vai_pdn			    : out std_logic;
		vdo_po1			    : in std_logic;
		vdo_rstn		    : out std_logic;
		dvi_hotplug_n   : out std_logic := '1';	-- HOTPLUG on the DVI input connector
		vsi_resetn	    : inout std_logic;
		vsi_extclk      : out std_logic;

    -- leds
		vao_led         : out std_logic;
		vdo_led         : out std_logic;
		vai_led         : out std_logic;
		vdi_led         : out std_logic;
    vli_led         : out std_logic;
    vsi_led         : out std_logic;
    
		clk24_a			    : in std_logic;		-- Buffered copy of on-board 24MHz clock
    clk24_en        : out std_logic;
    
    -- debug header
    -- elements 1,3,5 are virtual pins because fitter barfs
    dbgio           : in std_logic_vector(7 downto 0);
    
    -- test points (default to in)
		tp82            : in std_logic;
		tp83            : in std_logic;
		tp84            : in std_logic;
		tp109           : in std_logic;
		tp121           : in std_logic
	);

end entity target_top_ep4c;

architecture SYN of target_top_ep4c is

  constant ONBOARD_CLOCK_SPEED  : integer := 24000000;

  -- reset signals
  signal init               : std_logic := '1';
	signal reset					    : std_logic := '1';
	signal reset_n            : STD_LOGIC := '0';
	signal soft_reset_n		    : STD_LOGIC := '0';

  -- aliased clock pins
  alias clk_24M             : std_logic is clk24_a;
  --alias clk_24M576_b        : std_logic is clk24_a;
  -- clocks
  
  signal ddc_reset          : std_logic := '0';
  signal dvi_hotplug_s      : std_logic := '0';
  signal dvo_hotplug        : std_logic := '0';
  signal dvo_rdy            : std_logic := '0';
  
  signal led_clk            : std_logic := '0';
	signal test_blink_n	      : std_logic := '1';
  signal clk_120M           : std_logic := '0';
  signal clk_108M           : std_logic := '0';
  
begin

	reset_gen : process(clk_24M)
		variable reset_cnt : integer := 999999;
	begin
		if rising_edge(clk_24M) then
			if reset_cnt > 0 then
				init <= '1';
				reset_cnt := reset_cnt - 1;
			else
				init <= '0';
			end if;
		end if;
	end process reset_gen;

  -- can reset the whole chip from the mixer bus
  reset <= init; -- or not tp_84; --veb_reset;
	reset_n <= not reset;

  ep4c_pll_inst : entity work.ep4c_pll
    port map
    (
      inclk0		=> clk_24M,
      c0		    => open, --uh_clkin,      -- 12MHz
      c1		    => open, --clk_NIOS,      -- 72MHz
      c2		    => vid_clk,       -- 24MHz
      c3        => vsi_extclk,    -- 14.4MHz
      locked		=> open --pll_locked
    );
  
  lvdsplla : entity work.lpll
		port map	
		(
			areset			=> reset,
			inclk0			=> lvds_a_clk,
			c0					=> open, --vid_a_fastclk,
			c1					=> open, --vid_a_syncclk,
			c2					=> vli_clk,
			locked			=> open --lvds_locked
		);
	
    -- hook up the debug input (* not available)
    --     5V  - 1  2 - GND
    -- DBGIO0  - 3  4 - DBGIO7
    -- DBGIO1* - 5  6 - DBGIO6
    -- DBGIO2  - 7  8 - DBGIO5*
    -- DBGIO3* - 9 10 - DBGIO4
    --

  BLK_DVO_INIT : block

    signal vdo_scl_i      : std_logic := '0';
    signal vdo_scl_o      : std_logic := '0';
    signal vdo_scl_oe_n   : std_logic := '0';
    signal vdo_sda_i      : std_logic := '0';
    signal vdo_sda_o      : std_logic := '0';
    signal vdo_sda_oe_n   : std_logic := '0';

    signal ctl            : std_logic_vector(3 downto 1) := (others => '0');
    
  begin

    -- VO I2C (init) drivers
    vdo_scl_i <= vdo_scl;
    vdo_scl <= vdo_scl_o when vdo_scl_oe_n = '0' else 'Z';
    vdo_sda_i <= vdo_sda;
    vdo_sda <= vdo_sda_o when vdo_sda_oe_n = '0' else 'Z';
  
    ctl <= not (dbgio(4) & dbgio(6) & dbgio(7));

    dvo_sm : entity work.dvo_init_i2c_sm_controller
      generic map
      (
        clock_speed	=> ONBOARD_CLOCK_SPEED,
        dsel        => '0',

        -- DE generation
        DE_GEN      => S5AR2_DE_GEN,
        VS_POL      => S5AR2_VS_POL,
        HS_POL      => S5AR2_HS_POL,
        DE_DLY      => S5AR2_DE_DLY,
        DE_TOP      => S5AR2_DE_TOP,
        DE_CNT      => S5AR2_DE_CNT,
        DE_LIN      => S5AR2_DE_LIN
      )
      port map
      (
        clk					=> clk_24M,
        clk_ena     => '1',
        reset				=> reset,

        -- CTL outputs
        ctl         => ctl,
        
        -- I2C physical interface
        scl_i  	    => vdo_scl_i,
        scl_o  	    => vdo_scl_o,
        scl_oe_n    => vdo_scl_oe_n,
        sda_i  	    => vdo_sda_i,
        sda_o  	    => vdo_sda_o,
        sda_oe_n    => vdo_sda_oe_n
      );

  end block BLK_DVO_INIT;

  BLK_FLASHER : block
  begin
    -- flash the led so we know it's alive
    process (clk_24M, reset)
      variable count : std_logic_vector(21 downto 0);
    begin
      if reset = '1' then
        count := (others => '0');
      elsif rising_edge(clk_24M) then
        count := std_logic_vector(unsigned(count) + 1);
      end if;
      -- invert this only so it is out-of-phase with the EP3SL LED
      -- if they're both configured from the EPCS64...
      vao_led <= not count(count'left);
    end process;
  end block BLK_FLASHER;

  -- leds from the EP3SL
  --dbgled(8 downto 5) <= vid_spare(8 downto 5);
  
	BLK_CHASER : block

		signal chaseen        : std_logic;
		signal pwmen	        : std_logic;
		signal ledout					: std_logic_vector(4 downto 0);

	begin
	  pchaser: entity work.pwm_chaser
			generic map(nleds  => 5, nbits => 8, period => 4, hold_time => 12)
			port map (clk => clk_24M, clk_en => chaseen, pwm_en => pwmen, reset => reset, fade => X"0F", ledout => ledout);
			
		-- Generate pwmen pulse every 256 clocks, chase pulse every 256k clocks
		process(clk_24M, reset)
			variable pcount     : std_logic_vector(7 downto 0);
			variable pwmen_r    : std_logic;
			variable ccount     : std_logic_vector(17 downto 0);
			variable chaseen_r  : std_logic;
		begin
			pwmen <= pwmen_r;
			chaseen <= chaseen_r;
			if reset = '1' then
				pcount := (others => '0');
				ccount := (others => '0');
			elsif rising_edge(clk_24M) then
				pwmen_r := '0';
				if pcount = std_logic_vector(to_unsigned(0, pcount'length)) then
					pwmen_r := '1';
				end if;
				chaseen_r := '0';
				if ccount = std_logic_vector(to_unsigned(0, ccount'length)) then
					chaseen_r := '1';
				end if;
				pcount := std_logic_vector(unsigned(pcount) + 1);
				ccount := std_logic_vector(unsigned(ccount) + 1);
			end if;
		end process;

    --dbgled(4 downto 0) <= not ledout;

	end block BLK_CHASER;

  -- constant drivers
  v15_s3 <= 'Z';
  v15_s5 <= 'Z';
	veb_pwrgoodn  <= not (pok_12v and pok_5v and pok_3v3 and pok_1v9 and v15_pgood);
	lvds_sel		  <= 'Z';
	vai_pdn			  <= '0'; --reset_pio(2);
	vsi_resetn	  <= '1';
  vdo_rstn      <= reset_n;

  clk24_en      <= '1';
  dvi_connect   <= '1';
  dvi_oen       <= '0';

  sram_cs_n <= '1';
  sram_oe_n <= '1';
  sram_we_n <= '1';
  sram_ub_n <= '1';
  sram_lb_n <= '1';
  
end architecture SYN;
