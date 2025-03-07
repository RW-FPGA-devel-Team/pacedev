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
	
  -- Reference clock is 24MHz
  constant PACE_HAS_PLL                     : boolean := false;
  constant PACE_HAS_SRAM                    : boolean := true;
  constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := false;

	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;

  constant PACE_VIDEO_CONTROLLER_TYPE       : PACEVideoController_t := PACE_VIDEO_NONE;

  constant PACE_CLK0_DIVIDE_BY              : natural := 6;
  constant PACE_CLK0_MULTIPLY_BY            : natural := 5;  		-- 24*5/6 = 20MHz
  constant PACE_CLK1_DIVIDE_BY              : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY            : natural := 1;  		-- 24MHz

	-- Colecovision-specific constants
	constant CV_CART_NAME								      : string := "dkong.hex";
	--constant CV_CART_NAME								      : string := "qbert.hex";
	--constant CV_CART_NAME								      : string := "frogger.hex";
	--constant CV_CART_NAME								      : string := "smurf.hex";
					
  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
