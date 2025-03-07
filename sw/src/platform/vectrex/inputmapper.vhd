library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.pace_pkg.all;
use work.kbd_pkg.all;

entity inputmapper is
	generic
	(
    NUM_DIPS    : integer := 8;
		NUM_INPUTS  : integer := 2
	);
	port
	(
    clk       : in     std_logic;
    rst_n     : in     std_logic;

    -- inputs from keyboard controller
    reset     : in     std_logic;
    key_down  : in     std_logic;
    key_up    : in     std_logic;
    data      : in     std_logic_vector(7 downto 0);
		-- JAMMA interface
		jamma			: in from_JAMMA_t;

    -- user outputs
    dips			: in		std_logic_vector(NUM_DIPS-1 downto 0);
    inputs		: out   from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1)
	);
	end inputmapper;

architecture SYN of inputmapper is

begin

  latchInputs: process (clk, rst_n)
    variable jamma_v	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
    variable keybd_v 	: from_MAPPED_INPUTS_t(0 to NUM_INPUTS-1);
  begin

    -- note: all inputs are active LOW

    if rst_n = '0' then
      for i in 0 to NUM_INPUTS-2 loop
        jamma_v(i).d := (others => '1');
        keybd_v(i).d := (others => '1');
      end loop;
      -- special inputs are active-high
      keybd_v(NUM_INPUTS-1).d := "00111000";

    elsif rising_edge (clk) then

      -- handle JAMMA inputs
      jamma_v(0).d(0) := jamma.coin(1);
      jamma_v(0).d(1) := jamma.p(2).start;
      jamma_v(0).d(2) := jamma.p(1).start;
      jamma_v(0).d(4) := jamma.p(1).button(1);
      jamma_v(1).d(4) := jamma.p(1).button(1);
      jamma_v(0).d(5) := jamma.p(1).left;
      jamma_v(1).d(5) := jamma.p(1).left;
      jamma_v(0).d(6) := jamma.p(1).right;
      jamma_v(1).d(6) := jamma.p(1).right;

      if (key_down or key_up) = '1' then
        case data(7 downto 0) is
          -- SW
          -- RIGHT controller
          when SCANCODE_UP =>
            keybd_v(0).d(0) := key_up;
          when SCANCODE_DOWN =>
            keybd_v(0).d(1) := key_up;
          when SCANCODE_LEFT =>
            keybd_v(0).d(2) := key_up;
          when SCANCODE_RIGHT =>
            keybd_v(0).d(3) := key_up;
          -- LEFT controller
          when SCANCODE_D =>
            keybd_v(0).d(4) := key_up;
          when SCANCODE_A =>
            keybd_v(0).d(5) := key_up;
          when SCANCODE_S =>
            keybd_v(0).d(6) := key_up;
          when SCANCODE_W =>
            keybd_v(0).d(7) := key_up;

          -- Special keys
          when SCANCODE_F3 =>
            keybd_v(1).d(0) := key_down;			-- CPU RESET
          when SCANCODE_TAB =>
            keybd_v(1).d(1) := key_down;      -- OSD TOGGLE
          when SCANCODE_P =>				          -- pause (toggle)
            if key_down = '1' then
              keybd_v(1).d(2) := not keybd_v(1).d(2);
            end if;
          when SCANCODE_F4 =>                 -- TOGGLE ERASE
            if key_down = '1' then
              keybd_v(1).d(3) := not keybd_v(1).d(3);
            end if;
          when SCANCODE_F5 =>                 -- TOGGLE USE_BLANK
            if key_down = '1' then
              keybd_v(1).d(4) := not keybd_v(1).d(4);
            end if;
          when SCANCODE_F6 =>                 -- TOGGLE USE_Z
            if key_down = '1' then
              keybd_v(1).d(5) := not keybd_v(1).d(5);
            end if;
          when SCANCODE_PADPLUS =>
            keybd_v(1).d(6) := key_down;
          when SCANCODE_PADMINUS =>
            keybd_v(1).d(7) := key_down;
          when others =>
            null;
        end case;
      end if; -- key_down or key_up

      -- this is PS/2 reset only
      if (reset = '1') then
        for i in 0 to NUM_INPUTS-2 loop
          keybd_v(i).d := (others =>'1');
        end loop;
      end if;
    end if; -- rising_edge (clk)

    -- assign outputs
    for i in 0 to NUM_INPUTS-2 loop
      inputs(i).d <= jamma_v(i).d and keybd_v(i).d;
    end loop;
    inputs(NUM_INPUTS-1).d <= keybd_v(NUM_INPUTS-1).d;

  end process latchInputs;

end SYN;


