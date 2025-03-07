library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity saa505x is
	port
	(
		clk				: in std_logic;
		reset			: in std_logic;

		si_i_n		: in std_logic;
		si_o			: out std_logic;
		data_n		: in std_logic;
		d					: in std_logic_vector(6 downto 0);
		dlim			: in std_logic;
		glr				: in std_logic;
		dew				: in std_logic;
		crs				: in std_logic;
		bcs_n			: in std_logic;
		tlc_n			: out std_logic;
		tr6				: in std_logic;
		f1				: in std_logic;
		y					: out std_logic;
		b					: out std_logic;
		g					: out std_logic;
		r					: out std_logic;
		blan			: out std_logic;
		lose			: in std_logic;
		po				: in std_logic;
		de				: in std_logic
	);
end entity saa505x;

architecture SYN of saa505x is

	type charset_row_t is array (0 to 9) of std_logic_vector(5 downto 0);
	type charset_t is array (0 to 95) of charset_row_t;
	
	constant charset : charset_t :=
	(
	  -- $20
	  0 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000000",
	    4=>"000000",
	    5=>"000000",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $21
	  1 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"000100",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000000",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $22
	  2 => (
	    0=>"000000",
	    1=>"001010",
	    2=>"001010",
	    3=>"001010",
	    4=>"000000",
	    5=>"000000",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $23
	  3 => (
	    0=>"000000",
	    1=>"000110",
	    2=>"001001",
	    3=>"001000",
	    4=>"011100",
	    5=>"001000",
	    6=>"001000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $24
	  4 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010101",
	    3=>"010100",
	    4=>"001110",
	    5=>"000101",
	    6=>"010101",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $25
	  5 => (
	    0=>"000000",
	    1=>"011000",
	    2=>"011001",
	    3=>"000010",
	    4=>"000100",
	    5=>"001000",
	    6=>"010011",
	    7=>"000011",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $26
	  6 => (
	    0=>"000000",
	    1=>"001000",
	    2=>"010100",
	    3=>"010100",
	    4=>"001000",
	    5=>"010101",
	    6=>"010010",
	    7=>"001101",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $27
	  7 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"000100",
	    3=>"000100",
	    4=>"000000",
	    5=>"000000",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $28
	  8 => (
	    0=>"000000",
	    1=>"000010",
	    2=>"000100",
	    3=>"001000",
	    4=>"001000",
	    5=>"001000",
	    6=>"000100",
	    7=>"000010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $29
	  9 => (
	    0=>"000000",
	    1=>"001000",
	    2=>"000100",
	    3=>"000010",
	    4=>"000010",
	    5=>"000010",
	    6=>"000100",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2A
	  10 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"010101",
	    3=>"001110",
	    4=>"000100",
	    5=>"001110",
	    6=>"010101",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2B
	  11 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000100",
	    3=>"000100",
	    4=>"011111",
	    5=>"000100",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2C
	  12 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000000",
	    4=>"000000",
	    5=>"000100",
	    6=>"000100",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2D
	  13 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001110",
	    4=>"000000",
	    5=>"000000",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2E
	  14 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000000",
	    4=>"000000",
	    5=>"000000",
	    6=>"000000",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $2F
	  15 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000001",
	    3=>"000010",
	    4=>"000100",
	    5=>"001000",
	    6=>"010000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $30
	  16 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"001010",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"001010",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $31
	  17 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"001100",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $32
	  18 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"000001",
	    4=>"000110",
	    5=>"001000",
	    6=>"010000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $33
	  19 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"000001",
	    3=>"000010",
	    4=>"000110",
	    5=>"000001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $34
	  20 => (
	    0=>"000000",
	    1=>"000010",
	    2=>"000110",
	    3=>"001010",
	    4=>"010010",
	    5=>"011111",
	    6=>"000010",
	    7=>"000010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $35
	  21 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"010000",
	    3=>"011110",
	    4=>"000001",
	    5=>"000001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $36
	  22 => (
	    0=>"000000",
	    1=>"000110",
	    2=>"001000",
	    3=>"010000",
	    4=>"011110",
	    5=>"010001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $37
	  23 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"000001",
	    3=>"000010",
	    4=>"000100",
	    5=>"001000",
	    6=>"001000",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $38
	  24 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010001",
	    4=>"001110",
	    5=>"010001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $39
	  25 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010001",
	    4=>"001111",
	    5=>"000001",
	    6=>"000010",
	    7=>"001100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3A
	  26 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000100",
	    4=>"000000",
	    5=>"000000",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3B
	  27 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000100",
	    4=>"000000",
	    5=>"000100",
	    6=>"000100",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3C
	  28 => (
	    0=>"000000",
	    1=>"000010",
	    2=>"000100",
	    3=>"001000",
	    4=>"010000",
	    5=>"001000",
	    6=>"000100",
	    7=>"000010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3D
	  29 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"011111",
	    4=>"000000",
	    5=>"011111",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3E
	  30 => (
	    0=>"000000",
	    1=>"001000",
	    2=>"000100",
	    3=>"000010",
	    4=>"000001",
	    5=>"000010",
	    6=>"000100",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $3F
	  31 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"000010",
	    4=>"000100",
	    5=>"000100",
	    6=>"000000",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $40
	  32 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010111",
	    4=>"010101",
	    5=>"010111",
	    6=>"010000",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $41
	  33 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"001010",
	    3=>"010001",
	    4=>"010001",
	    5=>"011111",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $42
	  34 => (
	    0=>"000000",
	    1=>"011110",
	    2=>"010001",
	    3=>"010001",
	    4=>"011110",
	    5=>"010001",
	    6=>"010001",
	    7=>"011110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $43
	  35 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010000",
	    4=>"010000",
	    5=>"010000",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $44
	  36 => (
	    0=>"000000",
	    1=>"011110",
	    2=>"010001",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"011110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $45
	  37 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"010000",
	    3=>"010000",
	    4=>"011110",
	    5=>"010000",
	    6=>"010000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $46
	  38 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"010000",
	    3=>"010000",
	    4=>"011110",
	    5=>"010000",
	    6=>"010000",
	    7=>"010000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $47
	  39 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010000",
	    4=>"010000",
	    5=>"010011",
	    6=>"010001",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $48
	  40 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"010001",
	    4=>"011111",
	    5=>"010001",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $49
	  41 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"000100",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4A
	  42 => (
	    0=>"000000",
	    1=>"000001",
	    2=>"000001",
	    3=>"000001",
	    4=>"000001",
	    5=>"000001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4B
	  43 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010010",
	    3=>"010100",
	    4=>"011000",
	    5=>"010100",
	    6=>"010010",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4C
	  44 => (
	    0=>"000000",
	    1=>"010000",
	    2=>"010000",
	    3=>"010000",
	    4=>"010000",
	    5=>"010000",
	    6=>"010000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4D
	  45 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"011011",
	    3=>"010101",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4E
	  46 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"011001",
	    4=>"010101",
	    5=>"010011",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $4F
	  47 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $50
	  48 => (
	    0=>"000000",
	    1=>"011110",
	    2=>"010001",
	    3=>"010001",
	    4=>"011110",
	    5=>"010000",
	    6=>"010000",
	    7=>"010000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $51
	  49 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010001",
	    4=>"010001",
	    5=>"010101",
	    6=>"010010",
	    7=>"001101",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $52
	  50 => (
	    0=>"000000",
	    1=>"011110",
	    2=>"010001",
	    3=>"010001",
	    4=>"011110",
	    5=>"010100",
	    6=>"010010",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $53
	  51 => (
	    0=>"000000",
	    1=>"001110",
	    2=>"010001",
	    3=>"010000",
	    4=>"001110",
	    5=>"000001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $54
	  52 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"000100",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $55
	  53 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $56
	  54 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"010001",
	    4=>"001010",
	    5=>"001010",
	    6=>"000100",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $57
	  55 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"010001",
	    4=>"010101",
	    5=>"010101",
	    6=>"010101",
	    7=>"001010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $58
	  56 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"001010",
	    4=>"000100",
	    5=>"001010",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $59
	  57 => (
	    0=>"000000",
	    1=>"010001",
	    2=>"010001",
	    3=>"001010",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $5A
	  58 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"000001",
	    3=>"000010",
	    4=>"000100",
	    5=>"001000",
	    6=>"010000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $5B
	  59 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000100",
	    3=>"001000",
	    4=>"011111",
	    5=>"001000",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $5C
	  60 => (
	    0=>"000000",
	    1=>"010000",
	    2=>"010000",
	    3=>"010000",
	    4=>"010110",
	    5=>"000001",
	    6=>"000010",
	    7=>"000100",
	    8=>"000111",
	    9=>"000000"
	  ),
	  -- $5D
	  61 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000100",
	    3=>"000010",
	    4=>"011111",
	    5=>"000010",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $5E
	  62 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000100",
	    3=>"001110",
	    4=>"010101",
	    5=>"000100",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $5F
	  63 => (
	    0=>"000000",
	    1=>"001010",
	    2=>"001010",
	    3=>"011111",
	    4=>"001010",
	    5=>"011111",
	    6=>"001010",
	    7=>"001010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $60
	  64 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"000000",
	    4=>"000000",
	    5=>"011111",
	    6=>"000000",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $61
	  65 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001110",
	    4=>"000001",
	    5=>"001111",
	    6=>"010001",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $62
	  66 => (
	    0=>"000000",
	    1=>"010000",
	    2=>"010000",
	    3=>"011110",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"011110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $63
	  67 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001111",
	    4=>"010000",
	    5=>"010000",
	    6=>"010000",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $64
	  68 => (
	    0=>"000000",
	    1=>"000001",
	    2=>"000001",
	    3=>"001111",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $65
	  69 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001110",
	    4=>"010001",
	    5=>"011111",
	    6=>"010000",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $66
	  70 => (
	    0=>"000000",
	    1=>"000010",
	    2=>"000100",
	    3=>"000100",
	    4=>"001110",
	    5=>"000100",
	    6=>"000100",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $67
	  71 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001111",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001111",
	    8=>"000001",
	    9=>"001110"
	  ),
	  -- $68
	  72 => (
	    0=>"000000",
	    1=>"010000",
	    2=>"010000",
	    3=>"011110",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $69
	  73 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"000000",
	    3=>"001100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $6A
	  74 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"000000",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"000100",
	    8=>"001000",
	    9=>"000000"
	  ),
	  -- $6B
	  75 => (
	    0=>"000000",
	    1=>"001000",
	    2=>"001000",
	    3=>"001001",
	    4=>"001010",
	    5=>"001100",
	    6=>"001010",
	    7=>"001001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $6C
	  76 => (
	    0=>"000000",
	    1=>"001100",
	    2=>"000100",
	    3=>"000100",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $6D
	  77 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"011010",
	    4=>"010101",
	    5=>"010101",
	    6=>"010101",
	    7=>"010101",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $6E
	  78 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"011110",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $6F
	  79 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001110",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $70
	  80 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"011110",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"011110",
	    8=>"010000",
	    9=>"010000"
	  ),
	  -- $71
	  81 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001111",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001111",
	    8=>"000001",
	    9=>"000001"
	  ),
	  -- $72
	  82 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001011",
	    4=>"001100",
	    5=>"001000",
	    6=>"001000",
	    7=>"001000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $73
	  83 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"001111",
	    4=>"010000",
	    5=>"001110",
	    6=>"000001",
	    7=>"011110",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $74
	  84 => (
	    0=>"000000",
	    1=>"000100",
	    2=>"000100",
	    3=>"001110",
	    4=>"000100",
	    5=>"000100",
	    6=>"000100",
	    7=>"000010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $75
	  85 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $76
	  86 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"010001",
	    4=>"010001",
	    5=>"001010",
	    6=>"001010",
	    7=>"000100",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $77
	  87 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"010001",
	    4=>"010001",
	    5=>"010101",
	    6=>"010101",
	    7=>"001010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $78
	  88 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"010001",
	    4=>"001010",
	    5=>"000100",
	    6=>"001010",
	    7=>"010001",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $79
	  89 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"010001",
	    4=>"010001",
	    5=>"010001",
	    6=>"010001",
	    7=>"001111",
	    8=>"000001",
	    9=>"001110"
	  ),
	  -- $7A
	  90 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000000",
	    3=>"011111",
	    4=>"000010",
	    5=>"000100",
	    6=>"001000",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $7B
	  91 => (
	    0=>"000000",
	    1=>"001000",
	    2=>"001000",
	    3=>"001000",
	    4=>"001001",
	    5=>"000011",
	    6=>"000101",
	    7=>"000111",
	    8=>"000001",
	    9=>"000000"
	  ),
	  -- $7C
	  92 => (
	    0=>"000000",
	    1=>"001010",
	    2=>"001010",
	    3=>"001010",
	    4=>"001010",
	    5=>"001010",
	    6=>"001010",
	    7=>"001010",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $7D
	  93 => (
	    0=>"000000",
	    1=>"011000",
	    2=>"000100",
	    3=>"011000",
	    4=>"000100",
	    5=>"011001",
	    6=>"000011",
	    7=>"000101",
	    8=>"000111",
	    9=>"000001"
	  ),
	  -- $7E
	  94 => (
	    0=>"000000",
	    1=>"000000",
	    2=>"000100",
	    3=>"000000",
	    4=>"011111",
	    5=>"000000",
	    6=>"000100",
	    7=>"000000",
	    8=>"000000",
	    9=>"000000"
	  ),
	  -- $7F
	  95 => (
	    0=>"000000",
	    1=>"011111",
	    2=>"011111",
	    3=>"011111",
	    4=>"011111",
	    5=>"011111",
	    6=>"011111",
	    7=>"011111",
	    8=>"000000",
	    9=>"000000"
	  )
	);

  signal ra   : integer range 0 to 9;

begin

  -- generate row address
  process (clk, reset)
    variable glr_r  : std_logic;
  begin
    if reset = '1' then
    elsif rising_edge(clk) then
      -- VSYNC, reset row address
      if dew = '1' then
        ra <= 0;
      -- HYSNC, increment row address
      elsif glr = '1' and glr_r = '0' then
        if ra = 9 then
          ra <= 0;
        else
          ra <= ra + 1;
        end if;
      end if;
      glr_r := glr;
    end if;
  end process;

  -- latch and output data
  process (clk, reset)
    variable char_row_data  : std_logic_vector(5 downto 0);
  begin
    if reset = '1' then
      null;
    elsif rising_edge(clk) then
      if f1 = '1' then
        --latch data
        if d(6 downto 5) = "00" then
          char_row_data := (others => '0');
        else
          char_row_data := charset(conv_integer(d)-32)(ra);
        end if;
      elsif tr6 = '1' then
        -- shift data
        char_row_data := char_row_data(4 downto 0) & '0';
      end if;
    end if;
    -- assign output
    r <= char_row_data(char_row_data'left);
    g <= char_row_data(char_row_data'left);
    b <= char_row_data(char_row_data'left);
  end process;

  -- not supported
  si_o <= 'X';
  tlc_n <= 'X';
  y <= 'X';
  blan <= 'X';

end SYN;
