library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;

package target_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
	constant PACE_TARGET 		: PACETargetType := PACE_TARGET_NX2_12;
	constant PACE_FPGA_VENDOR	: PACEFpgaVendor_t := PACE_FPGA_VENDOR_XILINX;
	constant PACE_FPGA_FAMILY	: PACEFpgaFamily_t := PACE_FPGA_FAMILY_SPARTAN3E;
	
	constant PACE_CLKIN0		: natural := 50;
	constant PACE_CLKIN1		: natural := 0;   -- not available
	constant PACE_HAS_SRAM		: boolean := false;
	constant PACE_HAS_SDRAM		: boolean := false;
	constant PACE_HAS_SPI		: boolean := false;
	constant PACE_HAS_FLASH		: boolean := false;
  
end;
