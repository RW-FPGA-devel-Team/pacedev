library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.video_controller_pkg.PACEVideoController_t;
use work.video_controller_pkg.PACE_VIDEO_NONE;
use work.target_pkg.all;

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

  -- Reference clock is 50MHz
	-- DKONG ideally wants 24.576MHz
  constant PACE_CLK0_DIVIDE_BY              : natural := 5;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 2;  		-- 50*2/5 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 2;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  		-- 25MHz

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

	-- Donkey Kong-specific constants
	constant DKONG_ROM_IN_FLASH					      : boolean := true;
	constant DKONG_ROM_IN_SRAM					      : boolean := false;

  -- (derived)
  constant PACE_HAS_FLASH                   : boolean := DKONG_ROM_IN_FLASH;
  constant PACE_HAS_SRAM                    : boolean := DKONG_ROM_IN_SRAM;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
