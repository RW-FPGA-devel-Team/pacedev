library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.project_pkg.all;
use work.target_pkg.all;

package platform_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--

	constant PACE_VIDEO_NUM_BITMAPS		: natural := 1;
	constant PACE_VIDEO_NUM_TILEMAPS 	: natural := 0;
	constant PACE_VIDEO_NUM_SPRITES 	: natural := 0;
	constant PACE_VIDEO_H_SIZE				: integer := 224;
	constant PACE_VIDEO_V_SIZE				: integer := 256; -- why not 240?
	
	--
	-- Platform-specific constants (optional)
	--

  type from_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

  type to_PLATFORM_IO_t is record
    not_used  : std_logic;
  end record;

end;
