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
	
  -- Reference clock is 50MHz
	constant PACE_HAS_PLL								      : boolean := true;
  --constant PACE_HAS_FLASH                   : boolean := false;
  --constant PACE_HAS_SRAM                    : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  ---- * defined in platform_pkg
	--constant PACE_VIDEO_H_SIZE				        : integer := 224;
	--constant PACE_VIDEO_V_SIZE				        : integer := 256; -- why not 240?

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_640x480_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;   -- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1; 	-- 50*1/2 = 25MHz
	constant PACE_VIDEO_H_SCALE       	      : integer := 1;
	constant PACE_VIDEO_V_SCALE       	      : integer := 1;
  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   -- 24*1/1 = 24MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 3;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 5;  	-- 24*5/3 = 40MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 2;

--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_ARCADE_STD_336x240_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 1;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   	-- 24*1/1 = 24MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 57;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 17;  	-- 24*17/57 = 7.157895MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 1;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 1;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '0';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '0';
  
--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_CVBS_720x288p_50Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 32;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 27;   	-- 24*27/32 = 20M25Hz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 16;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 9;  		-- 24*9/16 = 13.5MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
  
--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1024x768_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 3;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 5;       -- 24*5/3 = 40MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 24;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 65;  	  -- 24*65/24 = 65MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 1;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 1;
--  constant PACE_VIDEO_H_SYNC_POLARITY       : std_logic := '1';
--  constant PACE_VIDEO_V_SYNC_POLARITY       : std_logic := '1';
--
--  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_1280x1024_60Hz;
--  constant PACE_CLK0_DIVIDE_BY              : natural := 96;
--  constant PACE_CLK0_MULTIPLY_BY            : natural := 157;     -- 24.675*157/96 = 40.192MHz
--  constant PACE_CLK1_DIVIDE_BY              : natural := 11;
--  constant PACE_CLK1_MULTIPLY_BY            : natural := 48;  	  -- 24.576*48/11 = 107.24MHz
--  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
--  constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                         : boolean := false;
  constant PACE_OSD_XPOS                        : natural := 0;
  constant PACE_OSD_YPOS                        : natural := 0;

  -- S5A-specific constants
  
  constant CYC5GXDEV_DOUBLE_VDO_IDCK            : boolean := false;
  
  constant CYC5GXDEV_EMULATE_SRAM               : boolean := false;
  constant CYC5GXDEV_EMULATED_SRAM_WIDTH_AD     : natural := 16;
  constant CYC5GXDEV_EMULATED_SRAM_WIDTH        : natural := 8;

  constant CYC5GXDEV_EMULATED_FLASH_INIT_FILE   : string := "";
  constant CYC5GXDEV_EMULATE_FLASH              : boolean := false;
  constant CYC5GXDEV_EMULATED_FLASH_WIDTH_AD    : natural := 10;
  constant CYC5GXDEV_EMULATED_FLASH_WIDTH       : natural := 8;

  constant CYC5GXDEV_HAS_FLOPPY_IF              : boolean := false;
    
  --
	-- Space Invaders-specific constants
	--
	
  -- rotate native video (for VGA monitor)
  -- - need to change H,V size in platform_pkg.vhd
  constant INVADERS_ROTATE_VIDEO                : boolean := false;
  
  constant INVADERS_ROM_IN_FLASH                : boolean := false;
	constant INVADERS_USE_INTERNAL_WRAM				    : boolean := true;

  -- derived (do not edit)

  constant PACE_HAS_FLASH                       : boolean := INVADERS_ROM_IN_FLASH;
  constant PACE_HAS_SRAM                        : boolean := not INVADERS_USE_INTERNAL_WRAM;
  
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
