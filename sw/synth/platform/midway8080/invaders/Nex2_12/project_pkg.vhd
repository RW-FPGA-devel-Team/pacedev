library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_HAS_PLL			: boolean := true;
	constant PACE_HAS_SRAM                  : boolean := false;
	constant PACE_HAS_SDRAM                 : boolean := false;
	constant PACE_HAS_SERIAL                : boolean := false;
  	constant PACE_JAMMA			: PACEJamma_t := PACE_JAMMA_NONE;

	
  -- Reference clock is 50MHz
  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_VGA_800x600_60Hz;
  constant PACE_CLK0_DIVIDE_BY              : natural := 2;		--5;  50/2.5 = 20MHz
  constant PACE_CLK0_MULTIPLY_BY            : natural := 1;   
  constant PACE_CLK1_DIVIDE_BY              : natural := 5;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 4;   -- 50*4/5 = 40MHz
  constant PACE_VIDEO_H_SCALE       	      : integer := 2;
  constant PACE_VIDEO_V_SCALE       	      : integer := 2;

  --constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLUE;
  constant PACE_VIDEO_BORDER_RGB            : RGB_t := RGB_BLACK;
  
  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 0;
  constant PACE_OSD_YPOS                    : natural := 0;

  --
	-- Space Invaders-specific constants
	--
	
  constant INVADERS_ROM_IN_FLASH            : boolean := PACE_HAS_FLASH;
	constant INVADERS_USE_INTERNAL_WRAM				: boolean := true;

	constant USE_VIDEO_VBLANK_INTERRUPT 			: boolean := false;
	
end;
