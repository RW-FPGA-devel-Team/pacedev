library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 25MHz
	constant PACE_HAS_PLL								      : boolean := true;
	constant PACE_HAS_FLASH							      : boolean := false;
	constant PACE_HAS_SRAM						        : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 8;     -- 25*8/5 = 40MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 25;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 108;  	-- 25*108/25 = 108MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
  	
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- S5A-specific constants
  
  constant S5A_DE_GEN                       : std_logic := '0';
  constant S5A_VS_POL                       : std_logic := '0';
  constant S5A_HS_POL                       : std_logic := '0';
  constant S5A_DE_DLY                       : std_logic_vector(11 downto 0) := X"000";
  constant S5A_DE_TOP                       : std_logic_vector(7 downto 0) := X"00";
  constant S5A_DE_CNT                       : std_logic_vector(11 downto 0) := X"000";
  constant S5A_DE_LIN                       : std_logic_vector(11 downto 0) := X"000";

  constant S5A_EMULATE_SRAM                 : boolean := false;
  constant S5A_EMULATED_SRAM_WIDTH_AD       : natural := 16;
  constant S5A_EMULATED_SRAM_WIDTH          : natural := 8;

	-- Asteroids-specific constants
					
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
