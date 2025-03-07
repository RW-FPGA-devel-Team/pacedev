library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
-- the OCIDE controller uses UNSIGNED from here
use ieee.std_logic_arith.unsigned;

library work;
use work.target_pkg.all;
use work.platform_pkg.all;
use work.project_pkg.all;

entity custom_io is
  port
  (
    -- compact flash
    iordy0_cf         : in std_logic;
    rdy_irq_cf        : in std_logic;
    cd_cf             : in std_logic;
    a_cf              : out std_logic_vector(2 downto 0);
    nce_cf            : out std_logic_vector(2 downto 1);
    d_cf              : inout std_logic_vector(15 downto 0);
    nior0_cf          : out std_logic;
    niow0_cf          : out std_logic;
    non_cf            : out std_logic;
    nreset_cf         : out std_logic;
    ndmack_cf         : out std_logic;
    dmarq_cf          : in std_logic;
    
    project_i         : out from_PROJECT_IO_t;
    project_o         : in to_PROJECT_IO_t;
    platform_i        : out from_PLATFORM_IO_t;
    platform_o        : in to_PLATFORM_IO_t;
    target_i          : out from_TARGET_IO_t;
    target_o          : in to_TARGET_IO_t
  );
end entity custom_io;

architecture SYN of custom_io is

  signal wb_sel   : std_logic_vector(3 downto 0) := (others => '0');
  
  signal dd_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal dd_o     : std_logic_vector(15 downto 0) := (others => '0');
  signal dd_oe    : std_logic := '0';
  signal a_cf_us  : unsigned(2 downto 0) := (others => '0');
  
begin

  -- 16-bit access to PIO registers, otherwise 32
  wb_sel <= "0011" when platform_o.wb_adr(6) = '1' else "1111";
  
  atahost_inst : entity work.atahost_top
    generic map
    (
      --TWIDTH          => 5,
      -- PIO mode 0 settings
      -- - (100MHz = 6, 28, 2, 23)
      -- - (57M272 = 4, 16, 1, 13)
      PIO_mode0_T1    => 4,     -- 70ns
      PIO_mode0_T2    => 16,    -- 290ns
      PIO_mode0_T4    => 1,     -- 30ns
      PIO_mode0_Teoc  => 13     -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
    )
    port map
    (
      -- WISHBONE SYSCON signals
      wb_clk_i      => platform_o.wb_clk,
      arst_i        => platform_o.wb_arst_n,
      wb_rst_i      => platform_o.wb_rst,

      -- WISHBONE SLAVE signals
      wb_cyc_i      => platform_o.wb_cyc_stb,
      wb_stb_i      => platform_o.wb_cyc_stb,
      wb_ack_o      => platform_i.wb_ack,
      wb_err_o      => open,
      wb_adr_i      => unsigned(platform_o.wb_adr),
      wb_dat_i      => platform_o.wb_dat,
      wb_dat_o      => platform_i.wb_dat,
      wb_sel_i      => wb_sel,
      wb_we_i       => platform_o.wb_we,
      wb_inta_o     => platform_i.wb_inta,

      -- ATA signals
      resetn_pad_o  => nreset_cf,
      dd_pad_i      => dd_i,
      dd_pad_o      => dd_o,
      dd_padoe_o    => dd_oe,
      da_pad_o      => a_cf_us,
      cs0n_pad_o    => nce_cf(1),
      cs1n_pad_o    => nce_cf(2),

      diorn_pad_o	  => nior0_cf,
      diown_pad_o	  => niow0_cf,
      iordy_pad_i	  => iordy0_cf,
      intrq_pad_i	  => rdy_irq_cf
    );

  a_cf <= std_logic_vector(a_cf_us);
  
  -- data bus drivers
  dd_i <= d_cf;
  d_cf <= dd_o when dd_oe = '1' else (others => 'Z');

  -- DMA mode not supported
  ndmack_cf <= 'Z';

  -- detect
  --<= cd_cf;
  
  -- power
  non_cf <= '0';
  
end architecture SYN;
