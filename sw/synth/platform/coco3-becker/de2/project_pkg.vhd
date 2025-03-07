library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_HAS_PLL										  : boolean := true;
  constant PACE_HAS_SRAM                    : boolean := true;
  --constant PACE_HAS_FLASH                   : boolean := false;
  constant PACE_HAS_SDRAM                   : boolean := false;
  constant PACE_HAS_SERIAL                  : boolean := true;
	
	constant PACE_JAMMA	                      : PACEJamma_t := PACE_JAMMA_NONE;
  
  -- Reference clock is 24MHz
  constant PACE_CLK0_DIVIDE_BY        		  : natural := 1;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 1;  	  -- 50MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 1;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 2;  	  -- 50MHz

  constant PACE_HAS_OSD                     : boolean := false;
  constant PACE_OSD_XPOS                    : natural := 128;
  constant PACE_OSD_YPOS                    : natural := 176;

	-- DE2 constants which *MUST* be defined
	
	constant DE2_LCD_LINE2							      : string := " COCO3 (BECKER) ";

	-- Coco3-specific constants

  constant COCO3_ROMS_IN_FLASH              : boolean := true;
  -- derived - do not edit
	constant PACE_HAS_FLASH                   : boolean := COCO3_ROMS_IN_FLASH;

  type from_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PROJECT_IO_t is record
    not_used  : std_logic;
  end record;

end;
