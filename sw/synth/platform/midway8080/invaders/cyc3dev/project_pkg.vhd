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
	
	constant PACE_HAS_PLL								      : boolean := true;	
  constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
  
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  ---- * defined in platform_pkg
	----constant PACE_VIDEO_H_SIZE				        : integer := 224;
	----constant PACE_VIDEO_V_SIZE				        : integer := 256; -- why not 240?

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 2;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  	-- 50*1/2 = 25MHz
	--constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	--constant PACE_VIDEO_V_SCALE       	      : integer := 1;

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 5;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 4;   -- 50*4/5 = 40MHz
	--constant PACE_VIDEO_H_SCALE               : integer := 2;
	--constant PACE_VIDEO_V_SCALE               : integer := 2;

  --constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1024x768_60Hz;
  --constant PACE_CLK0_DIVIDE_BY              : natural := 32;
  --constant PACE_CLK0_MULTIPLY_BY            : natural := 13;    -- 50*13/32 = 20.3125MHz
  --constant PACE_CLK1_DIVIDE_BY              : natural := 10;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 13;    -- 50*13/10 = 65MHz
	--constant PACE_VIDEO_H_SCALE       	      : integer := 2;
	--constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1680x1050_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;     -- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 25;
  --constant PACE_CLK1_MULTIPLY_BY            : natural := 74;    -- 50*74/25 = 148MHz
  constant PACE_CLK1_MULTIPLY_BY            : natural := 59;    -- 50*59/25 = 148MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 2;
	constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  -- CYC3DEV-specific constants
  
  constant CYC3DEV_EMULATE_SRAM             : boolean := false;
  constant CYC3DEV_EMULATED_SRAM_WIDTH_AD   : natural := 0;
  constant CYC3DEV_EMULATED_SRAM_WIDTH      : natural := 0;
  
  constant CYC3DEV_EMULATE_FLASH            : boolean := false;
  constant CYC3DEV_EMULATED_FLASH_WIDTH_AD  : natural := 0;
  constant CYC3DEV_EMULATED_FLASH_WIDTH     : natural := 0;
  constant CYC3DEV_EMULATED_FLASH_INIT_FILE : string := "disk0.hex";

	-- Invaders-specific constants
	
  constant INVADERS_ROM_IN_FLASH            : boolean := false;
  constant PACE_HAS_FLASH                   : boolean := INVADERS_ROM_IN_FLASH;
  
	constant INVADERS_USE_INTERNAL_WRAM       : boolean := true;		
	constant USE_VIDEO_VBLANK_INTERRUPT       : boolean := false;
	
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
