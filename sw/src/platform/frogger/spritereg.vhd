Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sprite_pkg.all;

entity sptReg is

	generic
	(
		INDEX			: natural
	);
	port
	(
    reg_i     : in to_SPRITE_REG_t;
    reg_o     : out from_SPRITE_REG_t
	);

end sptReg;

architecture SYN of sptReg is

  alias clk       : std_logic is reg_i.clk;
  alias clk_ena   : std_logic is reg_i.clk_ena;

begin

	process (clk)
	begin
		if rising_edge(clk) then
      if reg_i.a(4 downto 2) = std_logic_vector(to_unsigned(INDEX, 3)) then
        if reg_i.wr = '1' then
          case reg_i.a(1 downto 0) is
            when "00" =>
              reg_o.x <= "000" & reg_i.d(3 downto 0) & reg_i.d(7 downto 4);
            when "01" =>
              reg_o.n <= "000000" & reg_i.d(5 downto 0);
              reg_o.yflip <= reg_i.d(6);
              reg_o.xflip <= reg_i.d(7);
            when "10" =>
              reg_o.colour <= "00000" & reg_i.d(0) & reg_i.d(2 downto 1);
            when others =>
              reg_o.y <= std_logic_vector(resize(unsigned(reg_i.d), reg_o.y'length));
          end case;
        end if;
      end if;
		end if;
	end process;
	
  reg_o.pri <= '1';

end SYN;

