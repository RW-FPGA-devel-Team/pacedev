library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  constant PACE_HAS_PLL						: boolean := true;	
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  ---- * defined in platform_pkg
	----constant PACE_VIDEO_H_SIZE				        : integer := 224;
	----constant PACE_VIDEO_V_SIZE				        : integer := 256; -- why not 240?

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 9;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 10;   -- 27*10/9 = 30MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 27;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 40;  	-- 27*40/27 = 40MHz
	constant PACE_VIDEO_H_SCALE               : integer := 2;
	constant PACE_VIDEO_V_SCALE               : integer := 2;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';


  -- constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

	-- Galaxy Wars-specific constants
	
  -- rotate native video (for VGA monitor)
  -- - need to change H,V size in platform_pkg.vhd
  constant INVADERS_ROTATE_VIDEO            : boolean := true;

  constant INVADERS_ROM_IN_FLASH            : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := INVADERS_ROM_IN_FLASH;
  
	constant INVADERS_USE_INTERNAL_WRAM       : boolean := true;		
	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := false;
  
    -- MiST-specific constants
  constant MIST_DATA_IO_ENABLED             : boolean := false;
  constant MIST_OSD_ENABLED                 : boolean := false;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
