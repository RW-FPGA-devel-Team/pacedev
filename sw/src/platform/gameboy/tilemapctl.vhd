library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pace_pkg.all;
use work.project_pkg.all;
use work.platform_pkg.all;
use work.video_controller_pkg.all;

--
--	Gameboy (Background) Tilemap Controller
--

architecture TILEMAP_1 of tilemapCtl is

  alias clk       : std_logic is video_ctl.clk;
  alias clk_ena   : std_logic is video_ctl.clk_ena;
  alias stb       : std_logic is video_ctl.stb;
  alias hblank    : std_logic is video_ctl.hblank;
  alias vblank    : std_logic is video_ctl.vblank;
  alias x         : std_logic_vector(video_ctl.x'range) is video_ctl.x;
  alias y         : std_logic_vector(video_ctl.y'range) is video_ctl.y;
  
  alias lcdc      : std_logic_vector(7 downto 0) is graphics_i.bit8(0);
  alias scy       : std_logic_vector(7 downto 0) is graphics_i.bit8(1);
  alias scx       : std_logic_vector(7 downto 0) is graphics_i.bit8(2);

  signal y_adj		: std_logic_vector(y'range);
  
begin

  y_adj <= std_logic_vector(unsigned(y)+ unsigned(scy));

	-- these are constant for a whole line
  ctl_o.map_a(ctl_o.map_a'left downto 10) <= (others => '0');
  ctl_o.map_a(9 downto 5) <= y_adj(7 downto 3);
  ctl_o.tile_a(ctl_o.tile_a'left downto 12) <= (others => '0');
  ctl_o.tile_a(3 downto 1) <= y_adj(2 downto 0);
  ctl_o.tile_a(0) <= '0'; -- not used since we're reading 2 bytes

  -- no attribute (atm)
  ctl_o.attr_a <= (others => '0');
  
  -- generate pixel
  process (clk, clk_ena)

		variable x_adj		  : unsigned(x'range);
    variable tile_d_r   : std_logic_vector(15 downto 0);
		variable map_d_r	  : std_logic_vector(7 downto 0);
    variable pel        : std_logic_vector(1 downto 0);

    variable clut_i     : integer range 0 to 63;
    --variable clut_entry : tile_clut_entry_t;
    variable pel_i      : integer range 0 to 3;
    variable pal_i      : integer range 0 to 255;
    variable pal_entry  : palette_entry_t;

  begin

  	if rising_edge(clk) then
      if clk_ena = '1' then

        x_adj := unsigned(x);
        
        -- 1st stage of pipeline
        -- - read tile from tilemap
        -- - read attribute data
        if stb = '1' then
          ctl_o.map_a(4 downto 0) <= std_logic_vector(x_adj(7 downto 3));
        end if;
        
        -- 2nd stage of pipeline
        -- - read tile data from tile ROM
        if stb = '1' then
          if x_adj(2 downto 0) = "001" then
            --attr_d_r := ctl_i.attr_d(attr_d_r'range);
            --map_d_r := ctl_i.map_d(map_d_r'range);
          end if;
        end if;
        -- lcdc(4)=0 => -127..128
        ctl_o.tile_a(11) <= ctl_i.map_d(7) xor not lcdc(4);
        ctl_o.tile_a(10 downto 4) <= ctl_i.map_d(6 downto 0);
        
        if stb = '1' then
          if x_adj(2 downto 0) = "010" then
            tile_d_r := ctl_i.tile_d(tile_d_r'range);
          else
            tile_d_r(15 downto 8) := tile_d_r(14 downto 8) & '0';
            tile_d_r(7 downto 0) := tile_d_r(6 downto 0) & '0';
          end if;
        end if;

        -- Bit(0) controls BG/window on/off
        if lcdc(0) = '1' then
          -- 1 bit from each byte
          pel := tile_d_r(15) & tile_d_r(7);
        else
          pel := "00";
        end if;
        
        -- extract R,G,B from colour palette
        pel_i := to_integer(unsigned(pel));
        pal_entry := pal(pel_i);
        ctl_o.rgb.r <= pal_entry(0) & "00";
        ctl_o.rgb.g <= pal_entry(1) & "00";
        ctl_o.rgb.b <= pal_entry(2) & "00";

        ctl_o.set <= '1';

      end if; -- clk_ena
		end if;
  end process;

end TILEMAP_1;
