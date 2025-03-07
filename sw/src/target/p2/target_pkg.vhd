library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 				: PACETargetType := PACE_TARGET_P2;
	constant PACE_FPGA_VENDOR		: PACEFpgaVendor_t := PACE_FPGA_VENDOR_ALTERA;
	constant PACE_FPGA_FAMILY		: PACEFpgaFamily_t := PACE_FPGA_FAMILY_CYCLONE2;

  constant PACE_CLKIN0        : natural := 24;
  constant PACE_CLKIN1        : natural := 24;
  constant PACE_HAS_FLASH     : boolean := false;

	-- ADV724 constants
	constant ADV724_STD_PAL		  : std_logic := '0';
	constant ADV724_STD_NTSC	  : std_logic := not ADV724_STD_PAL;

  type from_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

  type to_TARGET_IO_t is record
    not_used  : std_logic;
  end record;

end;
