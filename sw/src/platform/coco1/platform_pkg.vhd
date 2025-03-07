library ieee;
use ieee.std_logic_1164.all;

library work;
use work.target_pkg.all;
use work.project_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_INPUTS_NUM_BYTES        : integer := 9;
	
  -- depends on build or simulation
  constant COCO1_SOURCE_ROOT_DIR  : string := "../../../../../src/platform/coco1/";
  constant COCO1_ROM_DIR          : string := COCO1_SOURCE_ROOT_DIR & "roms/";

	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
    -- to connect to real 6809
    cpu_6809_r_wn     : std_logic;
    cpu_6809_busy     : std_logic;
    cpu_6809_lic      : std_logic;
    cpu_6809_vma      : std_logic;
    cpu_6809_a        : std_logic_vector(15 downto 0);
    cpu_6809_d_o      : std_logic_vector(7 downto 0);
    -- from the OCIDE core
    wb_ack      : std_logic;
    wb_dat      : std_logic_vector(31 downto 0);
    wb_inta     : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    arst              : std_logic;
    clk_cpld          : std_logic;
    -- to connect to real 6809
    cpu_6809_q        : std_logic;
    cpu_6809_e        : std_logic;
    cpu_6809_rst_n    : std_logic;
    cpu_6809_d_i      : std_logic_vector(7 downto 0);
    cpu_6809_halt_n   : std_logic;
    cpu_6809_irq_n    : std_logic;
    cpu_6809_firq_n   : std_logic;
    cpu_6809_nmi_n    : std_logic;
    cpu_6809_tsc      : std_logic;
    -- to display on 7-segment display
    seg7              : std_logic_vector(15 downto 0);
    -- to the OCIDE core
    wb_clk      : std_logic;
    wb_arst_n   : std_logic;
    wb_rst      : std_logic;
    wb_cyc_stb  : std_logic;
    wb_adr      : std_logic_vector(6 downto 2);
    wb_dat      : std_logic_vector(31 downto 0);
    wb_we       : std_logic;
    -- to the SD core
    clk_50M     : std_logic;
  end record;

end;
