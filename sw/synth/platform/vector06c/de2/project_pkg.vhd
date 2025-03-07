library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.target_pkg.all;

package project_pkg is

	--  
	-- PACE constants which *MUST* be defined
	--
	
  -- Reference clock is 24MHz
	constant PACE_HAS_PLL										  : boolean := false;

  constant PACE_CLK0_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK0_MULTIPLY_BY      		  : natural := 4;   -- 24*4/3 = 32MHz
  constant PACE_CLK1_DIVIDE_BY        		  : natural := 3;
  constant PACE_CLK1_MULTIPLY_BY      		  : natural := 4;  	-- 24*4/3 = 32MHz
	constant PACE_ENABLE_ADV724							  : std_logic := '1';

  -- DE2-specific constants
  constant DE2_JAMMA_IS_MAPLE               : boolean := false;
  constant DE2_JAMMA_IS_NGC                 : boolean := false;

	-- BBC-specific constants

  -- implementation options

end;
