-- 
-- emsx_top.vhd
--   ESE MSX-SYSTEM3 / MSX clone on a Cyclone FPGA (ALTERA)
--   Revision 1.00
-- 
-- Copyright (c) 2006 Kazuhiro Tsujikawa (ESE Artists' factory)
-- All rights reserved.
-- 
-- Redistribution and use of this source code or any derivative works, are 
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, 
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright 
--    notice, this list of conditions and the following disclaimer in the 
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial 
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.vdp_package.all;

entity emsx_top is
  port(
    -- Clock, Reset ports
    pClk21m     : in std_logic;				-- VDP clock ... 21.48MHz
    pExtClk     : in std_logic;				-- Reserved (for multi FPGAs)
    pCpuClk     : out std_logic;			-- CPU clock ... 3.58MHz (up to 10.74MHz/21.48MHz)
--  pCpuRst_n   : out std_logic;			-- CPU reset

    -- MSX cartridge slot ports
    pSltClk     : in std_logic;                         -- pCpuClk returns here, for Z80, etc.
    pSltRst_n   : in std_logic;                         -- pCpuRst_n returns here
    pSltSltsl_n : inout std_logic;
    pSltSlts2_n : inout std_logic;
    pSltIorq_n  : inout std_logic;
    pSltRd_n    : inout std_logic;
    pSltWr_n    : inout std_logic;
    pSltAdr     : inout std_logic_vector(15 downto 0);
    pSltDat     : inout std_logic_vector(7 downto 0);
    pSltBdir_n  : out std_logic;                        -- Bus direction (not used in master mode)

    pSltCs1_n   : inout std_logic;
    pSltCs2_n   : inout std_logic;
    pSltCs12_n  : inout std_logic;
    pSltRfsh_n  : inout std_logic;
    pSltWait_n  : inout std_logic;
    pSltInt_n   : inout std_logic;
    pSltM1_n    : inout std_logic;
    pSltMerq_n  : inout std_logic;

    pSltRsv5    : out std_logic;                        -- Reserved
    pSltRsv16   : out std_logic;                        -- Reserved (w/ external pull-up)
    pSltSw1     : inout std_logic;                      -- Reserved (w/ external pull-up)
    pSltSw2     : inout std_logic;                      -- Reserved

    -- SD-RAM ports
    pMemClk     : out std_logic;                        -- SD-RAM Clock
    pMemCke     : out std_logic;                        -- SD-RAM Clock enable
    pMemCs_n    : out std_logic;                        -- SD-RAM Chip select
    pMemRas_n   : out std_logic;                        -- SD-RAM Row/RAS
    pMemCas_n   : out std_logic;                        -- SD-RAM /CAS
    pMemWe_n    : out std_logic;                        -- SD-RAM /WE
    pMemUdq     : out std_logic;                        -- SD-RAM UDQM
    pMemLdq     : out std_logic;                        -- SD-RAM LDQM
    pMemBa1     : out std_logic;                        -- SD-RAM Bank select address 1
    pMemBa0     : out std_logic;                        -- SD-RAM Bank select address 0
    pMemAdr     : out std_logic_vector(12 downto 0);    -- SD-RAM Address
    pMemDat     : inout std_logic_vector(15 downto 0);  -- SD-RAM Data

    -- PS/2 keyboard ports
    pPs2Clk     : inout std_logic;
    pPs2Dat     : inout std_logic;

    -- Joystick ports (Port_A, Port_B)
    pJoyA       : inout std_logic_vector( 5 downto 0);
    pStrA       : out std_logic;
    pJoyB       : inout std_logic_vector( 5 downto 0);
    pStrB       : out std_logic;

    -- SD/MMC slot ports
    pSd_Ck      : out std_logic;                        -- pin 5
    pSd_Cm      : out std_logic;                        -- pin 2
    pSd_Dt      : inout std_logic_vector( 3 downto 0);  -- pin 1(D3), 9(D2), 8(D1), 7(D0)

    -- DIP switch, Lamp ports
    pDip        : in std_logic_vector( 7 downto 0);     -- 0=ON,  1=OFF(default on shipment)
    pLed        : out std_logic_vector( 7 downto 0);    -- 0=OFF, 1=ON(green)
    pLedPwr     : out std_logic;                        -- 0=OFF, 1=ON(red) ...Power & SD/MMC access lamp

    -- Video, Audio/CMT ports
    pDac_VR     : inout std_logic_vector( 5 downto 0);  -- RGB_Red / Svideo_C
    pDac_VG     : inout std_logic_vector( 5 downto 0);  -- RGB_Grn / Svideo_Y
    pDac_VB     : inout std_logic_vector( 5 downto 0);  -- RGB_Blu / CompositeVideo
    pDac_SL     : out   std_logic_vector( 5 downto 0);  -- Sound-L
    pDac_SR     : inout std_logic_vector( 5 downto 0);  -- Sound-R / CMT

    pVideoHS_n  : out std_logic;                        -- Csync(RGB15K), HSync(VGA31K)
    pVideoVS_n  : out std_logic;                        -- Audio(RGB15K), VSync(VGA31K)

    pVideoClk   : out std_logic;                        -- (Reserved)
    pVideoDat   : out std_logic;                        -- (Reserved)

    -- Reserved ports (USB)
    pUsbP1      : inout std_logic;
    pUsbN1      : inout std_logic;
    pUsbP2      : inout std_logic;
    pUsbN2      : inout std_logic;

    -- Reserved ports
    pIopRsv14   : in std_logic;
    pIopRsv15   : in std_logic;
    pIopRsv16   : in std_logic;
    pIopRsv17   : in std_logic;
    pIopRsv18   : in std_logic;
    pIopRsv19   : in std_logic;
    pIopRsv20   : in std_logic;
    pIopRsv21   : in std_logic
  );
end emsx_top;

architecture rtl of emsx_top is

  component pll4x                       -- Altera specific component
    port(
      inclk0 : in std_logic := '0';     -- 21.48MHz input to PLL    (external I/O pin, from crystal oscillator)
      c0     : out std_logic ;          -- 21.48MHz output from PLL (internal LEs, for VDP, internal-bus, etc.)
      c1     : out std_logic ;          -- 85.92MHz output from PLL (internal LEs, for SD-RAM)
      e0     : out std_logic            -- 85.92MHz output from PLL (external I/O pin, for SD-RAM)
    );
  end component;

  component t80a
    port(
      RESET_n : in std_logic;
      CLK_n   : in std_logic;
      WAIT_n  : in std_logic;
      INT_n   : in std_logic;
      NMI_n   : in std_logic;
      BUSRQ_n : in std_logic;
      M1_n    : out std_logic;
      MREQ_n  : out std_logic;
      IORQ_n  : out std_logic;
      RD_n    : out std_logic;
      WR_n    : out std_logic;
      RFSH_n  : out std_logic;
      HALT_n  : out std_logic;
      BUSAK_n : out std_logic;
      A       : out std_logic_vector(15 downto 0);
      D       : inout std_logic_vector(7 downto 0)
    );
  end component;

  component iplrom
    port(
      clk     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0)
    );
  end component;

  component megasd
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0);
      dbo     : in std_logic_vector(7 downto 0);

      ramreq  : out std_logic;
      ramwrt  : out std_logic;
      ramadr  : out std_logic_vector(19 downto 0);
      ramdbi  : in std_logic_vector(7 downto 0);
      ramdbo  : out std_logic_vector(7 downto 0);

      mmcdbi  : out std_logic_vector(7 downto 0);
      mmcena  : out std_logic;
      mmcact  : out std_logic;

      mmc_ck  : out std_logic;
      mmc_cs  : out std_logic;
      mmc_di  : out std_logic;
      mmc_do  : in std_logic;

      epc_ck  : out std_logic;
      epc_cs  : out std_logic;
      epc_oe  : out std_logic;
      epc_di  : out std_logic;
      epc_do  : in std_logic
    );
  end component;

  component cycloneii_asmiblock   	-- Altera specific component
    port (
      dclkin   : in std_logic;  	-- DCLK
      scein    : in std_logic;  	-- nCSO
      sdoin    : in std_logic;  	-- ASDO
      oe       : in std_logic;  	--(1=disable(Hi-Z))
      data0out : out std_logic  	-- DATA0
    );
  end component;

  component mapper
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      mem     : in std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0);
      dbo     : in std_logic_vector(7 downto 0);

      ramreq  : out std_logic;
      ramwrt  : out std_logic;
      ramadr  : out std_logic_vector(21 downto 0);
      ramdbi  : in std_logic_vector(7 downto 0);
      ramdbo  : out std_logic_vector(7 downto 0)
    );
  end component;

  component eseps2 is
  port (
    clk21m : in std_logic;
    reset  : in std_logic;
    clkena : in std_logic;

    Kmap   : in std_logic;
    
    Caps    : inout std_logic;
    Kana    : inout std_logic;
    Paus    : inout std_logic;
    Scro    : inout std_logic;
    Reso    : inout std_logic;
    
    FKeys   : out std_logic_vector(7 downto 0);

    pPs2Clk  : inout std_logic;
    pPs2Dat  : inout std_logic;
    PpiPortC : inout std_logic_vector(7 downto 0);
    pKeyX    : inout std_logic_vector(7 downto 0)
  );
  end component;

  component rtc
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0);
      dbo     : in std_logic_vector(7 downto 0)
    );
  end component;

  component kanji is
  port (
    clk21m  : in std_logic;
    reset   : in std_logic;
    clkena  : in std_logic;
    req     : in std_logic;
    ack     : out std_logic;
    wrt     : in std_logic;
    adr     : in std_logic_vector(15 downto 0);
    dbi     : out std_logic_vector(7 downto 0);
    dbo     : in std_logic_vector(7 downto 0);

    ramreq  : out std_logic;
    ramadr  : out std_logic_vector(17 downto 0);
    ramdbi  : in std_logic_vector(7 downto 0);
    ramdbo  : out std_logic_vector(7 downto 0)
  );
  end component;

  component vdp
  port(
    -- VDP clock ... 21.477MHz
    clk21m  : in std_logic;
    reset   : in std_logic;
    req     : in std_logic;
    ack     : out std_logic;
    wrt     : in std_logic;
    adr     : in std_logic_vector(15 downto 0);
    dbi     : out std_logic_vector(7 downto 0);
    dbo     : in std_logic_vector(7 downto 0);

    int_n   : out std_logic;

    pRamOe_n: out std_logic;
    pRamWe_n: out std_logic;
    pRamAdr : out std_logic_vector(16 downto 0);
    pRamDbi : in  std_logic_vector(15 downto 0);
    pRamDbo : out std_logic_vector(7 downto 0);

    -- Video Output
    pVideoR : out std_logic_vector( 5 downto 0);
    pVideoG : out std_logic_vector( 5 downto 0);
    pVideoB : out std_logic_vector( 5 downto 0);

    pVideoHS_n : out std_logic;
    pVideoVS_n : out std_logic;
    pVideoCS_n : out std_logic;

    pVideoDHClk : out std_logic;
    pVideoDLClk : out std_logic;

    -- CXA1645(RGB->NTSC encoder) signals
    pVideoSC : out std_logic;
    pVideoSYNC : out std_logic;

    -- Display resolution (0=15kHz, 1=31kHz)
    DispReso : in  std_logic;

    -- Debug window signals
    debugWindowToggle : in std_logic;
    osdLocateX    : in std_logic_vector( 5 downto 0);
    osdLocateY    : in std_logic_vector( 4 downto 0);
    osdCharCodeIn : in std_logic_vector( 7 downto 0);
    osdCharWrReq  : in std_logic;
    osdCharWrAck  : out std_logic
  );
  end component;

  component vencode
    port(
      clk21m    : in std_logic;
      reset     : in std_logic;
      videoR    : in std_logic_vector(5 downto 0);
      videoG    : in std_logic_vector(5 downto 0);
      videoB    : in std_logic_vector(5 downto 0);
      videoHS_n : in std_logic;
      videoVS_n : in std_logic;
      videoY    : out std_logic_vector(5 downto 0);
      videoC    : out std_logic_vector(5 downto 0);
      videoV    : out std_logic_vector(5 downto 0)
    );
  end component;

  component psg
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0);
      dbo     : in std_logic_vector(7 downto 0);

      joya    : inout std_logic_vector(5 downto 0);
      stra    : out std_logic;
      joyb    : inout std_logic_vector(5 downto 0);
      strb    : out std_logic;

      kana    : out std_logic;
      cmtin   : in std_logic;
      keymode : in std_logic;

      wave    : out std_logic_vector(7 downto 0)
    );
  end component;

  component megaram
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbi     : out std_logic_vector(7 downto 0);
      dbo     : in std_logic_vector(7 downto 0);

      ramreq  : out std_logic;
      ramwrt  : out std_logic;
      ramadr  : out std_logic_vector(19 downto 0);
      ramdbi  : in std_logic_vector(7 downto 0);
      ramdbo  : out std_logic_vector(7 downto 0);

      mapsel  : in std_logic_vector(1 downto 0);  -- "0-":SCC+, "10":ASC8K, "11":ASC16K

      wavl    : out std_logic_vector(7 downto 0);
      wavr    : out std_logic_vector(7 downto 0)
    );
  end component;

  component eseopll
    port(
      clk21m  : in std_logic;
      reset   : in std_logic;
      clkena  : in std_logic;
      enawait : in std_logic;
      req     : in std_logic;
      ack     : out std_logic;
      wrt     : in std_logic;
      adr     : in std_logic_vector(15 downto 0);
      dbo     : in std_logic_vector(7 downto 0);
      wav     : out std_logic_vector(9 downto 0)
      );
  end component;

  component esepwm
    generic (
      MSBI : integer
    );
    port(
      clk     : in std_logic;
      reset   : in std_logic;
      DACin   : in std_logic_vector(MSBI downto 0);
      DACout  : out std_logic
    );
  end component;

  -- Operation mode
  signal SelfMode    : std_logic;               -- Operation mode        : 0=slave, 1=master
  signal KeyMode     : std_logic;               -- Kana key board layout : 1=JIS layout
  signal iDipLed     : std_logic_vector(7 downto 0);
  signal DispMode    : std_logic_vector(1 downto 0);
  alias  MegType     : std_logic_vector(1 downto 0) is iDipLed(7 downto 6);
  alias  RedMode     : std_logic is iDipLed(5); -- '0': CPU_3.58MHz,    '1': CPU_10.74MHz
  alias  MmcMode     : std_logic is iDipLed(4); -- '0': disable SD/MMC, '1': enable SD/MMC
  alias  Kmap        : std_logic is iDipLed(3); -- '0': Japanese-106,   '1': English-101
  alias  RchMode     : std_logic is iDipLed(2); -- '0': RCA(red)=CMT,   '1': RCA(red)=Rch_sound

  -- Clock, Reset control signals
  signal clk21m      : std_logic;
  signal memclk      : std_logic;
  signal cpuclk      : std_logic;
  signal clkena      : std_logic;
  signal clkdiv      : std_logic_vector(1 downto 0);
  signal clksel      : std_logic_vector(1 downto 0);
  signal reset       : std_logic;
  signal RstEna      : std_logic := '0';
  signal RstSeq      : std_logic_vector(4 downto 0) := (others => '0');
  signal FreeCounter : std_logic_vector(15 downto 0) := (others => '0');

  -- MSX cartridge slot control signals
  signal BusDir      : std_logic;
  signal iSltSltsl_n : std_logic;
  signal iSltRfsh_n  : std_logic;
  signal iSltMerq_n  : std_logic;
  signal iSltIorq_n  : std_logic;
  signal iSltRd_n    : std_logic;
  signal iSltWr_n    : std_logic;
  signal xSltRd_n    : std_logic;
  signal xSltWr_n    : std_logic;
  signal iSltAdr     : std_logic_vector(15 downto 0);
  signal iSltDat     : std_logic_vector(7 downto 0);
  signal dlydbi      : std_logic_vector(7 downto 0);
  signal BusReq_n    : std_logic;
  signal CpuM1_n     : std_logic;
  signal CpuRst_n    : std_logic;
  signal CpuRfsh_n   : std_logic;

  -- Internal bus signals (common)
  signal req, ireq   : std_logic;
  signal ack, iack   : std_logic;
  signal mem         : std_logic;
  signal wrt         : std_logic;
  signal adr         : std_logic_vector(15 downto 0);
  signal dbi         : std_logic_vector(7 downto 0);
  signal dbo         : std_logic_vector(7 downto 0);

  -- Primary, Expansion slot signals
  signal ExpDbi      : std_logic_vector(7 downto 0);
  signal ExpSlot0    : std_logic_vector(7 downto 0);
  signal ExpSlot3    : std_logic_vector(7 downto 0);
  signal ExpSlotX    : std_logic_vector(7 downto 0);
  signal PriSltNum   : std_logic_vector(1 downto 0);
  signal ExpSltNum0  : std_logic_vector(1 downto 0);
  signal ExpSltNum3  : std_logic_vector(1 downto 0);
  signal ExpSltNumX  : std_logic_vector(1 downto 0);

  -- Slot decode signals
  signal iSltBot     : std_logic;
  signal iSltMap     : std_logic;
  signal jSltMem     : std_logic;
  signal iSltScc     : std_logic;
  signal jSltScc     : std_logic;
  signal iSltErm     : std_logic;

  -- BIOS-ROM decode signals
  signal RomReq      : std_logic;
  signal rom_main    : std_logic;
  signal rom_opll    : std_logic;
  signal rom_extr    : std_logic;
  signal rom_kanj    : std_logic;

  -- IPL-ROM signals
  signal RomDbi      : std_logic_vector(7 downto 0);

  -- ESE-RAM signals
  signal ErmReq      : std_logic;
  signal ErmAck      : std_logic;
  signal ErmDbi      : std_logic_vector(7 downto 0);
  signal ErmRam      : std_logic;
  signal ErmWrt      : std_logic;
  signal ErmDbo      : std_logic_vector(7 downto 0);
  signal ErmAdr      : std_logic_vector(19 downto 0);

  -- SD/MMC signals
  signal MmcEna      : std_logic;
  signal MmcAct      : std_logic;
  signal MmcDbi      : std_logic_vector(7 downto 0);

  -- EPCS/ASMI signals
  signal EPC_CK      : std_logic;
  signal EPC_CS      : std_logic;
  signal EPC_OE      : std_logic;
  signal EPC_DI      : std_logic;
  signal EPC_DO      : std_logic;

  -- Mapper RAM signals
  signal MapReq      : std_logic;
  signal MapAck      : std_logic;
  signal MapDbi      : std_logic_vector(7 downto 0);
  signal MapRam      : std_logic;
  signal MapWrt      : std_logic;
  signal MapDbo      : std_logic_vector(7 downto 0);
  signal MapAdr      : std_logic_vector(21 downto 0);

  -- PPI(8255) signals
  signal PpiReq      : std_logic;
  signal PpiAck      : std_logic;
  signal PpiDbi      : std_logic_vector(7 downto 0);
  signal PpiPortA    : std_logic_vector(7 downto 0);
  signal PpiPortB    : std_logic_vector(7 downto 0);
  signal PpiPortC    : std_logic_vector(7 downto 0);

  -- PS/2 signals
  signal Paus        : std_logic;
  signal Reso, iReso : std_logic;
  signal Reso_v      : std_logic;
  signal Kana        : std_logic;
  signal Caps        : std_logic;
  signal Fkeys       : std_logic_vector(7 downto 0);

  -- CMT signals
  signal CmtIn       : std_logic;
  alias  CmtOut      : std_logic is PpiPortC(5);

  -- 1 bit sound port signal
  alias  KeyClick    : std_logic is PpiPortC(7);

  -- RTC signals
  signal RtcReq      : std_logic;
  signal RtcAck      : std_logic;
  signal RtcDbi      : std_logic_vector(7 downto 0);

  -- Kanji ROM signals
  signal KanReq      : std_logic;
  signal KanAck      : std_logic;
  signal KanDbi      : std_logic_vector(7 downto 0);
  signal KanRom      : std_logic;
  signal KanDbo      : std_logic_vector(7 downto 0);
  signal KanAdr      : std_logic_vector(17 downto 0);

  -- VDP signals
  signal VdpReq      : std_logic;
  signal VdpAck      : std_logic;
  signal VdpDbi      : std_logic_vector(7 downto 0);
  signal VideoSC     : std_logic;
  signal VideoDLClk  : std_logic;
  signal VideoDHClk  : std_logic;
  signal OeVdp_n     : std_logic;
  signal WeVdp_n     : std_logic;
  signal VdpAdr      : std_logic_vector(16 downto 0);
  signal VrmDbo      : std_logic_vector(7 downto 0);
  signal VrmDbi      : std_logic_vector(15 downto 0);
  signal pVdpInt_n   : std_logic;
  -- (for on screen display)
  signal osdLocateX     : std_logic_vector(5 downto 0);
  signal osdLocateY     : std_logic_vector(4 downto 0);
  signal osdCharCodeIn  : std_logic_vector(7 downto 0);
  signal osdCharWrReq   : std_logic;
  signal osdCharWrAck   : std_logic;

  -- Video signals
  signal VideoR      : std_logic_vector( 5 downto 0);   -- RGB_Red
  signal VideoG      : std_logic_vector( 5 downto 0);   -- RGB_Green
  signal VideoB      : std_logic_vector( 5 downto 0);   -- RGB_Blue
  signal VideoHS_n   : std_logic;                       -- Holizontal Sync
  signal VideoVS_n   : std_logic;                       -- Vertical Sync
  signal VideoCS_n   : std_logic;                       -- Composite Sync
  signal videoY      : std_logic_vector( 5 downto 0);   -- Svideo_Y
  signal videoC      : std_logic_vector( 5 downto 0);   -- Svideo_C
  signal videoV      : std_logic_vector( 5 downto 0);   -- CompositeVideo

  -- PSG signals
  signal PsgReq      : std_logic;
  signal PsgAck      : std_logic;
  signal PsgDbi      : std_logic_vector(7 downto 0);
  signal PsgAmp      : std_logic_vector(7 downto 0);
--signal JoyA        : std_logic_vector(5 downto 0);
--signal StrA        : std_logic;
--signal JoyB        : std_logic_vector(5 downto 0);
--signal StrB        : std_logic;

  -- SCC signals
  signal SccReq      : std_logic;
  signal SccAck      : std_logic;
  signal SccDbi      : std_logic_vector(7 downto 0);
  signal SccRam      : std_logic;
  signal SccWrt      : std_logic;
  signal SccAdr      : std_logic_vector(19 downto 0);
  signal SccDbo      : std_logic_vector(7 downto 0);
  signal SccAmpL     : std_logic_vector(7 downto 0);
  signal SccAmpR     : std_logic_vector(7 downto 0);

  -- Opll signals
  signal OpllReq     : std_logic;
  signal OpllAck     : std_logic;
  signal OpllAmp     : std_logic_vector(9 downto 0);
  signal OpllEnaWait : std_logic;

  -- Sound signals
  constant DAC_MSBI  : integer := 11;
  signal DACin       : std_logic_vector(DAC_MSBI downto 0);
  signal DACout      : std_logic;

  signal PsgVol      : std_logic_vector(2 downto 0);
  signal SccVol      : std_logic_vector(2 downto 0);
  signal OpllVol     : std_logic_vector(2 downto 0);
  signal MstrVol     : std_logic_vector(2 downto 0);

  signal pSltSndL    : std_logic_vector(5 downto 0);
  signal pSltSndR    : std_logic_vector(5 downto 0);
  signal pSltSound   : std_logic_vector(5 downto 0);

  -- Exernal memory signals
  signal RamReq      : std_logic;
  signal RamAck      : std_logic;
  signal RamDbi      : std_logic_vector(7 downto 0);
  signal ClrAdr      : std_logic_vector(17 downto 0);
  signal CpuAdr      : std_logic_vector(22 downto 0);

  -- SD-RAM control signals
  signal SdrSta      : std_logic_vector(2 downto 0);
  signal SdrCmd      : std_logic_vector(3 downto 0);
  signal SdrBa0      : std_logic;
  signal SdrBa1      : std_logic;
  signal SdrUdq      : std_logic;
  signal SdrLdq      : std_logic;
  signal SdrAdr      : std_logic_vector(12 downto 0);
  signal SdrDat      : std_logic_vector(15 downto 0);
  signal SdPaus      : std_logic;

  constant SdrCmd_de : std_logic_vector(3 downto 0) := "1111"; -- deselect
  constant SdrCmd_pr : std_logic_vector(3 downto 0) := "0010"; -- precharge all
  constant SdrCmd_re : std_logic_vector(3 downto 0) := "0001"; -- refresh
  constant SdrCmd_ms : std_logic_vector(3 downto 0) := "0000"; -- mode regiser set

  constant SdrCmd_xx : std_logic_vector(3 downto 0) := "0111"; -- no operation
  constant SdrCmd_ac : std_logic_vector(3 downto 0) := "0011"; -- activate
  constant SdrCmd_rd : std_logic_vector(3 downto 0) := "0101"; -- read
  constant SdrCmd_wr : std_logic_vector(3 downto 0) := "0100"; -- write

begin

  ----------------------------------------------------------------
  -- Clock generator (21.48MHz > 3.58MHz)
  -- pCpuClk should be independent from reset
  ----------------------------------------------------------------
  process(clk21m)

    variable jc : std_logic_vector(4 downto 0);

  begin

    if (clk21m'event and clk21m = '1') then

      jc(3) := jc(2);
      jc(2) := jc(1);
      jc(1) := jc(0);

      if (jc(3 downto 1) = "010" or jc(3 downto 1) = "101") then
        jc(0) := jc(3);
      else
        jc(0) := not jc(3);
      end if;

      -- CPUCLK : 3.58MHz = 21.48MHz / 6
      if (jc(3 downto 2) = "10") then
        clkena <= '1';
      else
        clkena <= '0';
      end if;
      cpuclk <= jc(3);

       -- Prescaler : 21.48MHz / 4
      clkdiv <= clkdiv - 1;

    end if;

  end process;


  ----------------------------------------------------------------
  -- Clock selector
  ----------------------------------------------------------------
  process(clk21m)
  begin
    if (clk21m'event and clk21m = '0') then
      if (cpuclk = '0' and clkdiv = "00") then
        if (RedMode = '0') then
          clksel <= "00";                               --  3.58MHz (standard speed)
        elsif (reset = '1') then
          clksel <= "01";                               -- 10.74MHz (workaround for boot failure)
--      elsif (iSltIorq_n = '0' and adr(7 downto 2) = "101010") then
--        clksel <= "11";                               -- 21.48MHz (much troublesome with external device)
        end if;
      end if;
    end if;
  end process;

  pCpuClk <= cpuclk    when SelfMode = '1' and clksel = "00" else
             clkdiv(0) when SelfMode = '1' and clksel = "01" else
             clkdiv(1) when SelfMode = '1' and clksel = "10" else
             clk21m    when SelfMode = '1' and clksel = "11" else 'Z';


  ----------------------------------------------------------------
  -- Reset control
  -- "RstSeq" should be cleared when power-on reset
  ----------------------------------------------------------------
  process(memclk)
    variable cnt : std_logic_vector(1 downto 0);
  begin
    if (memclk'event and memclk = '1') then
      if (cnt = "00") then
        if (FreeCounter = X"FFFF" and RstSeq /= "11111") then
          RstSeq <= RstSeq + 1;             -- 3ms (= 65536 / 21.48MHz)
        end if;
        FreeCounter <= FreeCounter + 1;
      end if;
      -- 00 > 01 > 11 > 10
      cnt := cnt(0) & (not cnt(1));
    end if;
  end process;

  --  Reset pulse width = 48 ms
  process (memclk, RstEna)
  begin
    if (RstEna = '0') then
      CpuRst_n <= '0';
    elsif (memclk'event and memclk = '1') then
      if (RstSeq(4) = '0') then
        CpuRst_n <= 'Z';
      else
        CpuRst_n <= 'Z';
      end if;
    end if;
  end process;

--pCpuRst_n <= CpuRst_n;
  reset     <= not pSltRst_n;


----------------------------------------------------------------
-- Operation mode
----------------------------------------------------------------
  process(clk21m)

    variable seq : std_logic_vector(3 downto 0) := (others => '0');
    variable cnt : std_logic_vector(20 downto 0) := (others => '0');

  begin

    if (clk21m'event and clk21m = '1') then

      if (reset = '1') then
        SelfMode  <= '1';               -- Operation mode : 0=slave, 1=master
        pLedPwr   <= seq(0);            -- Reset status, factory use
      else
        pLedPwr   <= not MmcEna;        -- SD/MMC access lamp
      end if;

      if (seq(3 downto 1) = "000") then
        RstEna   <= '0';
      else
        RstEna   <= '1';
      end if;

      if (cnt = "000000000000000000000") then	-- 21.48MHz / 2^21(approx:2M) => 10Hz
        case seq is
          when "0010"  => pLed <= "000000Z1";  iDipLed(2) <= not pDip(2);
          when "0011"  => pLed <= "0000001Z";  iDipLed(1) <= not pDip(1);
          when "0100"  => pLed <= "000001Z0";  iDipLed(0) <= not pDip(0);
          when "0101"  => pLed <= "00001Z00";  iDipLed(1) <= not pDip(1);
          when "0110"  => pLed <= "0001Z000";  iDipLed(2) <= not pDip(2);
          when "0111"  => pLed <= "001Z0000";  iDipLed(3) <= not pDip(3);
          when "1000"  => pLed <= "01Z00000";  iDipLed(4) <= not pDip(4);
          when "1001"  => pLed <= "1Z000000";  iDipLed(5) <= not pDip(5);
          when "1010"  => pLed <= "Z1000000";  iDipLed(6) <= not pDip(6);
          when "1011"  => pLed <= "0Z100000";  iDipLed(7) <= not pDip(7);
          when "1100"  => pLed <= "00Z10000";  iDipLed(6) <= not pDip(6);
          when "1101"  => pLed <= "000Z1000";  iDipLed(5) <= not pDip(5);
          when "1110"  => pLed <= "0000Z100";  iDipLed(4) <= not pDip(4);
          when "1111"  => pLed <= "00000Z10";  iDipLed(3) <= not pDip(3);
          when others  => pLed <= "ZZZZZZZZ";  iDipLed    <= not pDip   ;
        end case;
      end if;

      if (cnt = "000000000000000000000") then
        if (seq = "1111") then
          seq := "0010";
        else
          seq := seq + 1;
        end if;
      end if;

      cnt := cnt + 1;

    end if;

  end process;

  KeyMode   <= '1';     -- Kana key board layout  : 1=JIS layout


  ----------------------------------------------------------------
  -- MSX cartridge slot control
  ----------------------------------------------------------------
  pSltCs1_n   <= 'Z'      when SelfMode = '0'               else
                 pSltRd_n when pSltAdr(15 downto 14) = "01" else '1';
  pSltCs2_n   <= 'Z'      when SelfMode = '0'               else 
                 pSltRd_n when pSltAdr(15 downto 14) = "10" else '1';
  pSltCs12_n  <= 'Z'      when SelfMode = '0'               else 
                 pSltRd_n when pSltAdr(15 downto 14) = "01" else 
                 pSltRd_n when pSltAdr(15 downto 14) = "10" else '1';
  pSltM1_n    <= CpuM1_n   when SelfMode = '1' else 'Z';
  pSltRfsh_n  <= CpuRfsh_n when SelfMode = '1' else 'Z';

  pSltInt_n   <= pVdpInt_n;

  pSltSltsl_n <= 'Z' when SelfMode = '0' else
                 '0' when pSltMerq_n  = '0' and CpuRfsh_n = '1' and PriSltNum  = "01" else
                 '1';

  pSltSlts2_n <= 'Z' when SelfMode = '0' else
                 '1' when MegType /= "00" else
                 '0' when pSltMerq_n  = '0' and CpuRfsh_n = '1' and PriSltNum  = "10" else
                 '1';

  pSltBdir_n  <= 'Z' when pSltRd_n = '1' else
                 '0' when pSltSltsl_n = '0' and SelfMode = '0' else
                 '0' when pSltIorq_n  = '0' and SelfMode = '0' and pSltAdr(7 downto 2)= "100010" else
                 'Z';

  pSltDat     <= (others => 'Z') when pSltRd_n = '1' else
                 dbi when pSltSltsl_n = '0' and SelfMode = '0' else
                 dbi when pSltIorq_n  = '0' and BusDir   = '1' else
                 dbi when pSltMerq_n  = '0' and SelfMode = '1' and PriSltNum = "00" else
                 dbi when pSltMerq_n  = '0' and SelfMode = '1' and PriSltNum = "11" else
                 dbi when pSltMerq_n  = '0' and SelfMode = '1' and PriSltNum = "10" and MegType /= "00" else
                 (others => 'Z');

  pSltRsv5  <= 'Z';
  pSltRsv16 <= 'Z';
  pSltSw1   <= 'Z';
  pSltSw2   <= 'Z';


  ----------------------------------------------------------------
  -- Z80 CPU wait control
  ----------------------------------------------------------------
  process(pSltClk, reset)

    variable iCpuM1_n : std_logic;
    variable jSltMerq_n : std_logic;
    variable jSltIorq_n : std_logic;
    variable count : std_logic_vector(3 downto 0);

  begin

    if (reset = '1') then
      iCpuM1_n   := '1';
      jSltIorq_n := '1';
      jSltMerq_n := '1';
      count      := (others => '0');
      pSltWait_n <= 'Z';
    elsif (pSltClk'event and pSltClk = '1') then

      if (pSltMerq_n = '0' and jSltMerq_n = '1') then
        if (clksel = "11" and VideoDLClk = '0' and VideoDHClk = '1') then
          count := "0101";
        elsif (clksel = "11" and iSltScc = '1') then
          count := "0111";
        elsif (clksel = "11") then
          count := "0100";
        elsif (clksel = "01") then
          count := "0010";
        end if;
      elsif (pSltIorq_n = '0' and jSltIorq_n = '1') then
        if (clksel = "11") then
          count := "0111";
        elsif (clksel = "01") then
          count := "0011";
        end if;
      elsif (count /= "0000") then
        count := count - 1;
      end if;

      if (SelfMode = '0') then
        pSltWait_n <= 'Z';
      elsif (CpuM1_n = '0' and iCpuM1_n = '1') then
        pSltWait_n <= '0';
      elsif (count /= "0000") then
        pSltWait_n <= '0';
      elsif (clksel /= "00" and OpllReq = '1' and OpllAck = '0') then
        pSltWait_n <= '0';
--    elsif (clksel /= "00" and iSltErm = '1' and MmcAct = '1') then
--      pSltWait_n <= '0';
      elsif (ErmReq = '1' and adr(15 downto 13) = "010" and MmcAct = '1') then
        pSltWait_n <= '0';
      elsif (SdPaus = '1') then
        pSltWait_n <= '0';
      else
        pSltWait_n <= 'Z';
      end if;

      iCpuM1_n := CpuM1_n;
      jSltIorq_n := pSltIorq_n;
      jSltMerq_n := pSltMerq_n;

    end if;

  end process;


  ----------------------------------------------------------------
  -- On chip internal bus control
  ----------------------------------------------------------------
  process(clk21m, reset)

    variable ExpDec : std_logic;

  begin

    if (reset = '1') then

      iSltSltsl_n <= '1';
      iSltRfsh_n  <= '1';
      iSltMerq_n  <= '1';
      iSltIorq_n  <= '1';
      iSltRd_n    <= '1';
      iSltWr_n    <= '1';
      xSltRd_n    <= '1';
      xSltWr_n    <= '1';
      iSltAdr     <= (others => '1');
      iSltDat     <= (others => '1');

      iack        <= '0';

      dlydbi      <= (others => '1');
      ExpDec      := '0';

    elsif (clk21m'event and clk21m = '1') then

      -- MSX slot signals
      if (SelfMode = '0') then
        iSltSltsl_n <= pSltSltsl_n;
      else
        iSltSltsl_n <= '1';
      end if;
      iSltRfsh_n  <= pSltRfsh_n;
      iSltMerq_n  <= pSltMerq_n;
      iSltIorq_n  <= pSltIorq_n;
      iSltRd_n    <= pSltRd_n;
      iSltWr_n    <= pSltWr_n;
      if (clksel = "11") then
        xSltRd_n    <= iSltRd_n;
        xSltWr_n    <= iSltWr_n;
      else
        xSltRd_n    <= pSltRd_n;
        xSltWr_n    <= pSltWr_n;
      end if;
      iSltAdr     <= pSltAdr;
      iSltDat     <= pSltDat;

      if (iSltSltsl_n = '1' and iSltMerq_n  = '1' and iSltIorq_n = '1') then
        iack <= '0';
      elsif (ack = '1') then
        iack <= '1';
      end if;

      if (mem = '1' and ExpDec = '1') then
        dlydbi <= ExpDbi;
      elsif (mem = '1' and iSltBot = '1') then
        dlydbi <= RomDbi;
      elsif (mem = '1' and iSltErm = '1' and MmcEna = '1') then
        dlydbi <= MmcDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "00010") then
        dlydbi <= VdpDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "00110") then
        dlydbi <= VdpDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "01000") then
        dlydbi <= PsgDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "01010") then
        dlydbi <= PpiDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "11111") then
        dlydbi <= MapDbi;
      elsif (mem = '0' and adr(6 downto 1)  = "011010") then
        dlydbi <= RtcDbi;
      elsif (mem = '0' and adr(6 downto 2)  = "10110") then
        dlydbi <= KanDbi;
      else
        dlydbi <= (others => '1');
      end if;

      if (adr = X"FFFF") then
        ExpDec := '1';
      else
        ExpDec := '0';
      end if;

    end if;

  end process;

  ----------------------------------------------------------------
  process(clk21m, reset)

  begin

    if (reset = '1') then

      jSltScc   <= '0';
      jSltMem   <= '0';

      wrt <= '0';

    elsif (clk21m'event and clk21m = '0') then

      if (mem = '1' and iSltScc = '1') then
        jSltScc <= '1';
      else
        jSltScc <= '0';
      end if;

      if (mem = '1' and iSltErm = '1') then
        if (MmcEna = '1' and adr(15 downto 13) = "010") then
          jSltMem <= '0';
        elsif (MmcMode = '1') then      -- enable SD/MMC drive
          jSltMem <= '1';
        else                            -- disable SD/MMC drive
          jSltMem <= '0';
        end if;
      elsif (mem = '1' and (iSltMap = '1' or rom_main = '1' or rom_opll = '1' or rom_extr = '1')) then
          jSltMem <= '1';
--    elsif (mem = '0' and (rom_kanj = '1')) then
--        jSltMem <= '1';
      else
          jSltMem <= '0';
      end if;

      if (req = '0') then
        wrt <= not pSltWr_n;   -- 1=write, 0=read
      end if;

      ireq <= req;

    end if;

  end process;

  -- access request, CPU > Components
  req <= '1' when (((iSltMerq_n = '0' and SelfMode = '1') or
                    iSltSltsl_n = '0' or iSltIorq_n = '0') and
                    (xSltRd_n = '0' or xSltWr_n = '0') and iack = '0') else '0';
  mem <= iSltIorq_n; -- 1=memory area, 0=i/o area
  dbo <= iSltDat;    -- CPU data (CPU > device)
  adr <= iSltAdr;    -- CPU address (CPU > device)

  -- access acknowledge, Components > CPU
  ack     <= RamAck when                RamReq = '1' else       -- ErmAck, MapAck, KanAck;
             SccAck when mem = '1' and iSltScc = '1' else       -- SccAck
             OpllAck when OpllReq = '1' else                    -- OpllAck
             req;                                               -- PsgAck, PpiAck, MapAck, VdpAck, RtcAck
  dbi     <= SccDbi when jSltScc = '1' else
             RamDbi when jSltMem = '1' else
             dlydbi;


  ----------------------------------------------------------------
  -- PPI(8255) / primary-slot, keyboard, 1 bit sound port
  ----------------------------------------------------------------
  process(clk21m, reset)

  begin

    if (reset = '1') then

      PpiPortA <= "11111111"; -- primary slot : page 0 => boot-rom, page 1/2 => ese-mmc, page 3 => mapper
--    PpiPortB <= (others => '1');
      PpiPortC <= (others => '0');

    elsif (clk21m'event and clk21m = '1') then

      -- I/O port access on A8-ABh ... PPI(8255) access
      if (PpiReq = '1') then
        if (wrt = '1' and adr(1 downto 0) = "00") then
          PpiPortA <= dbo;
        elsif (wrt = '1' and adr(1 downto 0) = "10") then
          PpiPortC <= dbo;
        elsif (wrt = '1' and adr(1 downto 0) = "11" and dbo(7) = '0') then
          case dbo(3 downto 1) is
            when "000"  => PpiPortC(0) <= dbo(0); -- key_matrix Y(0)
            when "001"  => PpiPortC(1) <= dbo(0); -- key_matrix Y(1)
            when "010"  => PpiPortC(2) <= dbo(0); -- key_matrix Y(2)
            when "011"  => PpiPortC(3) <= dbo(0); -- key_matrix Y(3)
            when "100"  => PpiPortC(4) <= dbo(0); -- cassete motor on (0=ON,1=OFF)
            when "101"  => PpiPortC(5) <= dbo(0); -- cassete audio out
            when "110"  => PpiPortC(6) <= dbo(0); -- CAPS lamp (0=ON,1=OFF)
            when others => PpiPortC(7) <= dbo(0); -- 1 bit sound port
          end case;
        end if;
      end if;

      PpiAck <= PpiReq;

    end if;

  end process;

  Caps <= PpiPortC(6);

  -- I/O port access on A8-ABh ... PPI(8255) register read
  PpiDbi <= PpiPortA when adr(1 downto 0) = "00" else
            PpiPortB when adr(1 downto 0) = "01" else
            PpiPortC when adr(1 downto 0) = "10" else
            (others => '1');


  ----------------------------------------------------------------
  -- Expansion slot
  ----------------------------------------------------------------
  process(clk21m, reset)

  begin

    if (reset = '1') then

      ExpSlot0 <= (others => '0');
      ExpSlot3 <= "00101011";      -- primary slot : page 0 => iplrom, page 1/2 => megasd, page 3 => mapper
      ExpSlotX <= (others => '0');

    elsif (clk21m'event and clk21m = '1') then

      -- Memory mapped I/O port access on FFFFh ... expansion slot register (master mode)
      if (req = '1' and iSltMerq_n = '0'  and wrt = '1' and adr = X"FFFF") then
        if (PpiPortA(7 downto 6) = "00") then
          ExpSlot0 <= dbo;
        elsif (PpiPortA(7 downto 6) = "11") then
          ExpSlot3 <= dbo;
        end if;
      end if;
      -- Memory mapped I/O port access on FFFFh ... expansion slot register (slave mode)
      if (req = '1' and iSltSltsl_n = '0' and wrt = '1' and adr = X"FFFF") then
        ExpSlotX <= dbo;
      end if;

    end if;

  end process;

  -- primary slot number (master mode)
  PriSltNum  <= PpiPortA(1 downto 0) when adr(15 downto 14) = "00" else
                PpiPortA(3 downto 2) when adr(15 downto 14) = "01" else
                PpiPortA(5 downto 4) when adr(15 downto 14) = "10" else
                PpiPortA(7 downto 6);

  -- expansion slot number : slot 0 (master mode)
  ExpSltNum0 <= ExpSlot0(1 downto 0) when adr(15 downto 14) = "00" else
                ExpSlot0(3 downto 2) when adr(15 downto 14) = "01" else
                ExpSlot0(5 downto 4) when adr(15 downto 14) = "10" else
                ExpSlot0(7 downto 6);

  -- expansion slot number : slot 3 (master mode)
  ExpSltNum3 <= ExpSlot3(1 downto 0) when adr(15 downto 14) = "00" else
                ExpSlot3(3 downto 2) when adr(15 downto 14) = "01" else
                ExpSlot3(5 downto 4) when adr(15 downto 14) = "10" else
                ExpSlot3(7 downto 6);

  -- expansion slot number : slot X (slave mode)
  ExpSltNumX <= ExpSlotX(1 downto 0) when adr(15 downto 14) = "00" else
                ExpSlotX(3 downto 2) when adr(15 downto 14) = "01" else
                ExpSlotX(5 downto 4) when adr(15 downto 14) = "10" else
                ExpSlotX(7 downto 6);

  -- expansion slot register read
  ExpDbi <= not ExpSlot0 when SelfMode = '1' and PpiPortA(7 downto 6) = "00" else
            not ExpSlot3 when SelfMode = '1' and PpiPortA(7 downto 6) = "11" else
            not ExpSlotX;


  ----------------------------------------------------------------
  -- slot / address decode
  ----------------------------------------------------------------
  iSltScc <= '0' when MegType = "00" else
             '0' when adr(15 downto 14) = "00" or adr(15 downto 14) = "11" else
             mem when PriSltNum  = "10" and SelfMode = '1'                 else
             mem when ExpSltNumX = "00" and SelfMode = '0'                 else '0';
  iSltMap <= '0' when adr = X"FFFF"                                        else
             mem when PriSltNum  = "11" and
                      ExpSltNum3 = "00" and SelfMode = '1'                 else
             '1' when ExpSltNumX = "10" and SelfMode = '0'                 else '0';
  iSltErm <= '0' when adr(15 downto 14) = "00" or adr(15 downto 14) = "11" else
             mem when PriSltNum  = "11" and
                      ExpSltNum3 = "10" and SelfMode = '1'                 else
             '1' when ExpSltNumX = "01" and SelfMode = '0'                 else '0';
  iSltBot <= '0' when adr(15 downto 14) = "01" or adr(15 downto 14) = "10" else
             mem when PriSltNum  = "11" and
                      ExpSltNum3 = "11" and SelfMode = '1'                 else '0';

  rom_main <= '0' when adr(15) /= '0'                                      else      -- MAIN-ROM
              mem when PriSltNum  = "00" and
                       ExpSltNum0 = "00" and SelfMode = '1'                else '0';
  rom_opll <= '0' when adr(15 downto 14) /= "01"                           else      -- OPLL
              mem when PriSltNum  = "00" and
                       ExpSltNum0 = "10" and SelfMode = '1'                else '0';
  rom_extr <= '0' when adr(15 downto 14) /= "00"                           else      -- SUB-ROM
              mem when PriSltNum  = "11" and
                       ExpSltNum3 = "01" and SelfMode = '1'                else '0';
  rom_kanj <= '0' when mem = '1'                                           else      -- Kanji-ROM
              '1' when adr(7 downto 2) = "110110" and SelfMode = '1'       else '0';

  -- RamX / RamY access request
  RamReq <= SccRam or ErmRam or MapRam or RomReq or KanRom;

  -- access request to components
  VdpReq <= req when mem = '0' and adr(7 downto 2) = "100010" and SelfMode = '0' else  -- I/O:88-8Bh / VDP(V9958)
            req when mem = '0' and adr(7 downto 2) = "100110" and SelfMode = '1' else  -- I/O:98-9Bh / VDP(V9958)
            '0';
  PsgReq <= req when mem = '0' and adr(7 downto 2) = "101000" else '0'; -- I/O:A0-A3h / PSG(AY-3-8910)
  PpiReq <= req when mem = '0' and adr(7 downto 2) = "101010" else '0'; -- I/O:A8-ABh / PPI(8255)
  OpllReq<= req when mem = '0' and adr(7 downto 2) = "011111" else '0'; -- I/O:7C-7Fh / OPLL(YM2413)
  KanReq <= req when mem = '0' and adr(7 downto 2) = "110110" else '0'; -- I/O:D8-DBh / Kanji
  RomReq <= req when mem = '1' and (rom_main = '1' or rom_opll = '1' or rom_extr = '1') else '0';
  MapReq <= req when mem = '0' and adr(7 downto 2) = "111111" else      -- I/O:FC-FFh / Memory-mapper
            req when mem = '1' and iSltMap = '1'              else '0'; -- MEM        / Memory-mapper
  SccReq <= req when mem = '1' and iSltScc = '1'              else '0'; -- MEM:       / ESE-SCC
  ErmReq <= req when mem = '1' and iSltErm = '1'              else '0'; -- MEM:       / ESE-RAM, MegaSD
  RtcReq <= req when mem = '0' and adr(7 downto 1) = "1011010" else '0';-- I/O:B4-B5h / RTC(RP-5C01)

  BusDir <= '1' when pSltAdr(7 downto 2) = "100010"  and SelfMode = '0' else  -- I/O:88-8Bh / VDP(V9958)
            '1' when pSltAdr(7 downto 2) = "100110"  and SelfMode = '1' else  -- I/O:98-9Bh / VDP(V9958)
            '1' when pSltAdr(7 downto 2) = "101000"  and SelfMode = '1' else  -- I/O:A0-A3h / PSG(AY-3-8910)
            '1' when pSltAdr(7 downto 2) = "101010"  and SelfMode = '1' else  -- I/O:A8-ABh / PPI(8255)
            '1' when pSltAdr(7 downto 2) = "110110"  and SelfMode = '1' else  -- I/O:D8-DBh / Kanji
            '1' when pSltAdr(7 downto 2) = "111111"  and SelfMode = '1' else  -- I/O:FC-FFh / Memory-mapper
            '1' when pSltAdr(7 downto 1) = "1011010" and SelfMode = '1' else  -- I/O:B4-B5h / RTC(RP-5C01)
            '0';


  ----------------------------------------------------------------
  -- Test for on-screen-display
  ----------------------------------------------------------------
  process(clk21m, reset)
    constant str : string := "ESE MSX-SYSTEM3 [2006/11/23]";
    variable state    : std_logic_vector(3 downto 0);
    variable x : std_logic_vector(4 downto 0);
  begin
    if (reset = '1') then
      osdCharWrReq <= '0';
      osdCharCodeIn <= (others => '0');
      osdLocateX <= (others => '0');
      osdLocateY <= (others => '0');
      x := (others => '0');
    elsif (clk21m'event and clk21m = '1') then
      case state is
        when X"0" =>
          osdLocateX <= (others => '0');
          x := (others => '0');
          state := X"1";
        when X"1" =>
          osdCharCodeIn <= char_to_std_logic_vector(str(conv_integer(x)+1));
          osdCharWrReq <= not osdCharWrAck;
          state := X"2";
        when X"2" =>
          -- waiting wr ack
          if( osdCharWrReq = osdCharWrAck ) then
--          if( osdLocateX = str'length -1) then
            if( osdLocateX = 27) then
              state := X"3";
            else
              state := X"1";
              x := x+1;
              osdLocateX <= osdLocateX + 1;
            end if;
          end if;
        when X"3" =>
          null;
        when others => null;
      end case;
      osdLocateY <= (others => '0');
    end if;
  end process;


  ----------------------------------------------------------------
  -- Video output
  ----------------------------------------------------------------
  process (clk21m)

    variable iReso      : std_logic;
    variable DispSel    : std_logic_vector(1 downto 0);

  begin

    if (clk21m'event and clk21m = '1') then

      case (DispMode + DispSel) is
        when "00" =>    -- TV 15KHz
          pDac_VR <= videoC;
          pDac_VG <= videoY;
          pDac_VB <= videoV;
          Reso_v  <= '0';   -- Hsync:15kHz
          pVideoHS_n <= VideoHS_n;
          pVideoVS_n <= VideoVS_n;

        when "01" =>    -- RGB 15kHz (Half amplitude)
          pDac_VR <= '0' & VideoR(5 downto 1);
          pDac_VG <= '0' & VideoG(5 downto 1);
          pDac_VB <= '0' & VideoB(5 downto 1);
          Reso_v  <= '0';   -- Hsync:15kHz
          pVideoHS_n <= VideoCS_n;
          pVideoVS_n <= DACout; -- Audio

        when "10" =>    -- VGA 31KHz (Half amplitude)
          pDac_VR <= '0' & VideoR(5 downto 1);
          pDac_VG <= '0' & VideoG(5 downto 1);
          pDac_VB <= '0' & VideoB(5 downto 1);
          Reso_v  <= '1';   -- Hsync:31kHz
          pVideoHS_n <= VideoHS_n;
          pVideoVS_n <= VideoVS_n;

        when others =>  -- VGA 31kHz (Full amplitude)
          pDac_VR <= VideoR;
          pDac_VG <= VideoG;
          pDac_VB <= VideoB;
          Reso_v  <= '1';   -- Hsync:31kHz
          pVideoHS_n <= VideoHS_n;
          pVideoVS_n <= VideoVS_n;
      end case;

      if (reset = '1') then
          DispSel := ( others => '0' );
      elsif (iReso /= Reso) then
        if Fkeys(7) = '0' then
          DispSel := DispSel + 1;
        else
          DispSel := DispSel - 1;
        end if;
      end if;
      iReso := Reso;

    end if;
  end process;

  DispMode(1)<= iDipLed(0);
  DispMode(0)<= iDipLed(1);

  pVideoClk <= clk21m; -- for DE2 etc
  pVideoDat <= 'Z';


  ----------------------------------------------------------------
  -- Sound output
  ----------------------------------------------------------------
  process (clk21m)

    variable Amp : std_logic_vector(DACin'high + 4 downto DACin'low);
    constant OPLL_ZERO : std_logic_vector(OpllAmp'range) := (OpllAmp'high=>'1', others=>'0');
    variable vFKeys : std_logic_vector(7 downto 0);
    variable chAmp : std_logic_vector(Amp'range);

  begin

    if (clk21m'event and clk21m = '1') then

      if (reset = '1') then
        MstrVol <= "000";
      elsif Fkeys(5) /= vFkeys(5) then -- Master Volume Up
        if "000" < MstrVol then MstrVol <= MstrVol-'1'; end if;        
      elsif Fkeys(4) /= vFkeys(4) then -- Master Volume Down
        if MstrVol < "111" then MstrVol <= MstrVol+'1'; end if;        
      end if;

      if (reset = '1') then
        PsgVol <= "011";
      elsif Fkeys(3) /= vFKeys(3) then -- PSG
        if Fkeys(7) = '1' then
          if "000" < PsgVol then PsgVol <= PsgVol-'1'; end if;
        else
          if PsgVol < "111" then PsgVol <= PsgVol+'1'; end if;
        end if;
      end if;

      if (reset = '1') then
        SccVol <= "110";
      elsif Fkeys(2) /= vFKeys(2) then -- SCC
        if Fkeys(7) = '1' then
          if "000" < SccVol then SccVol <= SccVol-'1'; end if;
        else
          if SccVol < "111" then SccVol <= SccVol+'1'; end if;
        end if;
      end if;

      if (reset = '1') then
        OpllVol <= "110";
      elsif Fkeys(1) /= vFKeys(1) then -- OPLL
        if Fkeys(7) = '1' then
          if "000" < OpllVol then OpllVol <= OpllVol-'1'; end if;
        else
          if OpllVol < "111" then OpllVol <= OpllVol+'1'; end if;
        end if;
      end if;      
      vFkeys := Fkeys;

      Amp := (Amp'high=>'1', others=>'0');
      -- PSG
      chAmp := "0000" & SHR(((PsgAmp + (KeyClick&"00000")) * PsgVol) & "0", MstrVol);
      Amp := Amp + chAmp;
      -- SCC
      chAmp := "000" & SHR((SccAmpL * SccVol)&"00", MstrVol);
      Amp := Amp - chAmp;
      -- OPLL 
      if OpllAmp < OPLL_ZERO then
        chAmp := "00" & SHR(((OPLL_ZERO - OpllAmp) * OpllVol)&"0", MstrVol);
        Amp := Amp - (chAmp - chAmp(chAmp'high downto 3));
      else
        chAmp := "00" & SHR(((OpllAmp - OPLL_ZERO) * OpllVol)&"0", MstrVol);
        Amp := Amp + (chAmp - chAmp(chAmp'high downto 3));
      end if;

      -- Limitter
      case Amp(Amp'high downto Amp'high-2) is
        when "111" => DACin <= (others=>'1');
        when "110" => DACin <= (others=>'1');
        when "101" => DACin <= (others=>'1');
        when "100" => DACin <= "1" & Amp(Amp'high-3 downto 2);
        when "011" => DACin <= "0" & Amp(Amp'high-3 downto 2);
        when "010" => DACin <= (others=>'0');
        when "001" => DACin <= (others=>'0');
        when "000" => DACin <= (others=>'0');
      end case;

    end if;

  end process;

  pDac_SL <= DACout & DACout & DACout & DACout & DACout & DACout;


  ----------------------------------------------------------------
  -- Cassette Magnetic Tape (CMT) interface
  ----------------------------------------------------------------
  process(clk21m)
  begin
    if (clk21m'event and clk21m = '1') then
      if (RchMode = '0') then
        pDac_SR(5 downto 4) <= "ZZ";
        pDac_SR(3 downto 1) <= CmtIn & (not CmtIn) & '0';
        pDac_SR(0) <= CmtOut;
        CmtIn <= pDac_SR(5);
      else
        pDac_SR <= DACout & DACout & DACout & DACout & DACout & DACout;
        CmtIn <= '0';   -- CMT data input : always '0' on MSX turboR
      end if;
    end if;
  end process;


  ----------------------------------------------------------------
  -- External memory access
  ----------------------------------------------------------------
  -- Slot map / SD-RAM memory map in master mode
  --
  -- Slot 0-0 : MainROM         690000-697FFF(  32KB)
  -- Slot 0-2 : FM-BIOS         69C000-69FFFF(  16KB)
  -- Slot 1   : (EXTERNAL-SLOT)
  -- Slot 2   : (EXTERNAL-SLOT)
  --            / MegaRam       600000-67FFFF( 512KB)
  -- Slot 3-0 : Mapper          400000-4FFFFF(1024KB)
  -- Slot 3-1 : SubROM          698000-69BFFF(  16KB)
  -- Slot 3-2 : MegaSD          680000-68FFFF(  64KB) / 680000-6BFFFF(BIOS:256KB)
  -- Slot 3-3 : IPL-ROM         (blockRAM:512Bytes)
  -- VRAM     : VRAM            700000-71FFFF( 128KB)

  CpuAdr(22 downto 20) <= "010"                     when iSltMap    = '1' else
                          "110";
  CpuAdr(19 downto 0)  <=       MapAdr(19 downto 0) when iSltMap    = '1' else
                     '0'      & SccAdr(18 downto 0) when iSltScc    = '1' else
                     "10"     & ErmAdr(17 downto 0) when iSltErm    = '1' else
                     "101"    & KanAdr(16 downto 0) when rom_kanj   = '1' else
                     "10010"  & adr(14 downto 0)    when rom_main   = '1' else
                     "100110" & adr(13 downto 0)    when rom_extr   = '1' else
                     "100111" & adr(13 downto 0); --when rom_opll   = '1'


  ----------------------------------------------------------------
  -- SD-RAM access
  ----------------------------------------------------------------
  --   SdrSta = "000" => idle
  --   SdrSta = "001" => precharge all
  --   SdrSta = "010" => refresh
  --   SdrSta = "011" => mode register set
  --   SdrSta = "100" => read cpu
  --   SdrSta = "101" => write cpu
  --   SdrSta = "110" => read vdp
  --   SdrSta = "111" => write vdp
  ----------------------------------------------------------------
  process(memclk)
    type typSdrSeq is (SdrSeq00, SdrSeq01, SdrSeq02, SdrSeq03, SdrSeq04, SdrSeq05, SdrSeq06, SdrSeq07);
    variable SdrSeq : typSdrSeq := SdrSeq00;
  begin

    if (memclk'event and memclk = '1') then

      if (SdrSeq = SdrSeq07) then
        if (RstSeq(4 downto 2) = "000") then
          SdrSta <= "000";                        -- Idle
        elsif (RstSeq(4 downto 2) = "001") then
          case RstSeq(1 downto 0) is
            when "00"   => SdrSta <= "000";       -- Idle
            when "01"   => SdrSta <= "001";       -- precharge all
            when "10"   => SdrSta <= "010";       -- refresh (more than 8 cycles)
            when others => SdrSta <= "011";       -- mode register set
          end case;
        elsif (RstSeq(4 downto 3) /= "11") then
          SdrSta <= "101";                        -- Write (Initialize memory content)
        elsif (iSltRfsh_n = '0' and VideoDLClk = '1') then
          SdrSta <= "010";                        -- refresh
        elsif (SdPaus = '1' and VideoDLClk = '1') then
          SdrSta <= "010";                        -- refresh
        else
          -- Normal memory access mode
          SdrSta(2) <= '1';                       -- read/write cpu/vdp
        end if;

      elsif (SdrSeq = SdrSeq01 and SdrSta(2) = '1' and RstSeq(4 downto 3) = "11") then
        SdrSta(1) <= VideoDLClk;                  -- 0:cpu, 1:vdp
        if (VideoDLClk = '0') then
          if (RamReq = '1' and ((SccWrt = '1' and iSltScc = '1') or
                                (ErmWrt = '1' and iSltErm = '1') or
                                (MapWrt = '1' and iSltMap = '1')   )) then
            SdrSta(0) <= '1';
          else
            SdrSta(0) <= '0';
          end if;
        else
          if (WeVdp_n = '0') then
            SdrSta(0) <= '1';
          else
            SdrSta(0) <= '0';
          end if;
        end if;
      end if;

      case SdrSeq is
        when SdrSeq00 =>
          if (SdrSta(2) = '1') then               -- CPU/VDP read/write
            SdrCmd <= SdrCmd_ac;
          elsif (SdrSta(1 downto 0) = "00") then  -- idle
            SdrCmd <= SdrCmd_xx;
          elsif (SdrSta(1 downto 0) = "01") then  -- precharge all
            SdrCmd <= SdrCmd_pr;
          elsif (SdrSta(1 downto 0) = "10") then  -- refresh
            SdrCmd <= SdrCmd_re;
          else                                    -- mode register set
            SdrCmd <= SdrCmd_ms;
          end if;
          SdrBa1 <= '0';
          SdrBa0 <= '0';
          SdrUdq <= '1';
          SdrLdq <= '1';
          if (SdrSta(2) = '0') then
            --        single          CL=2 WT=0(seq) BL=1
            SdrAdr <= "00010" & "0" & "010" & "0" & "000";
          else
            if (RstSeq(4 downto 3) /= "11") then
              SdrAdr <= ClrAdr(12 downto 0);      -- clear memory (VRAM, MainRAM)
            elsif (VideoDLClk = '0') then
              SdrAdr <= CpuAdr(13 downto 1);      -- cpu read/write
            else
              SdrAdr <= VdpAdr(12 downto 0);      -- vdp read/write
            end if;
          end if;
        when SdrSeq01 =>
          SdrCmd <= SdrCmd_xx;
        when SdrSeq02 =>
          if (SdrSta(2) = '1') then
            if (SdrSta(0) = '0') then
              SdrCmd <= SdrCmd_rd;                -- "100"(cpu read) / "110"(vdp read)
              SdrUdq <= '0';
              SdrLdq <= '0';
              SdrDat <= (others => 'Z');
            else
              SdrCmd <= SdrCmd_wr;                -- "101"(cpu write) / "111"(vdp write)
              if (RstSeq(4 downto 3) /= "11") then
                SdrDat <= (others => '0');
                SdrUdq <= '0';
                SdrLdq <= '0';
              elsif (VideoDLClk = '0') then
                SdrDat <= dbo & dbo;              -- "101"(cpu write)
                SdrUdq <= not CpuAdr(0);
                SdrLdq <= CpuAdr(0);
              else
                SdrDat <= VrmDbo & VrmDbo;        -- "111"(vdp write)
                SdrUdq <= not VdpAdr(16);
                SdrLdq <= VdpAdr(16);
              end if;
            end if;
          end if;
          SdrAdr(12 downto 9) <= "0010";          -- A10=1 => enable auto precharge
          if (RstSeq(4 downto 2) = "010") then
            SdrAdr(8 downto 0) <= "11" & "1000" & ClrAdr(15 downto 13);  -- clear VRAM(128KB)
          elsif (RstSeq(4 downto 2) = "011") then
            SdrAdr(8 downto 0) <= "11" & "0000" & ClrAdr(15 downto 13);  -- clear ERAM(128KB)
          elsif (RstSeq(4 downto 3) = "10") then
            SdrAdr(8 downto 0) <= "01" & "0000" & ClrAdr(15 downto 13);  -- clear MainRAM(128KB)
          elsif (VideoDLClk = '0') then
            SdrAdr(8 downto 0) <= CpuAdr(22 downto 14);
          else
            SdrAdr(8 downto 0) <= "11" & "1000" & VdpAdr(15 downto 13);
          end if;
          if (RstSeq(4 downto 3) /= "11") then
            ClrAdr <= (others => '0');
          else
            ClrAdr <= ClrAdr + 1;
          end if;
        when SdrSeq03 =>
          SdrCmd <= SdrCmd_xx;
          SdrUdq <= '1';
          SdrLdq <= '1';
          SdrDat <= (others => 'Z');
        when SdrSeq04 =>
        when SdrSeq05 =>
          if (SdrSta(2) = '1') then
            if (SdrSta(0) = '0') then
              if (VideoDLClk = '0') then
                if (CpuAdr(0) = '0') then
                  RamDbi <= pMemDat(7 downto 0);  -- "100"(cpu read)
                else
                  RamDbi <= pMemDat(15 downto 8); -- "100"(cpu read)
                end if;
                SdPaus <= Paus;
              else
                  VrmDbi <= pMemDat(15 downto 0); -- "110"(vdp read)
              end if;
            end if;
          else
            SdPaus <= Paus;
          end if;
        when SdrSeq06 =>
        when others   => null;
      end case;

      case SdrSeq is
        when SdrSeq00 =>
          if (VideoDHClk = '1' or RstSeq(4 downto 3) /= "11") then
            SdrSeq := SdrSeq01;
          end if;
        when SdrSeq01 => SdrSeq := SdrSeq02;
        when SdrSeq02 => SdrSeq := SdrSeq03;
        when SdrSeq03 => SdrSeq := SdrSeq04;
        when SdrSeq04 => SdrSeq := SdrSeq05;
        when SdrSeq05 =>
            SdrSeq := SdrSeq06;
        when SdrSeq06 =>
            SdrSeq := SdrSeq07;
        when others   =>
          if (VideoDHClk = '0' or RstSeq(4 downto 3) /= "11") then
            SdrSeq := SdrSeq00;
          end if;
      end case;

    end if;

  end process;

  process (clk21m, reset)
  begin
    if (reset = '1') then
      RamAck <= '0';
    elsif (clk21m'event and clk21m = '1') then
      if (RamReq = '0') then
        RamAck <= '0';
      elsif (VideoDLClk = '0' and VideoDHClk = '1') then
        RamAck <= '1';
      end if;
    end if;
  end process;

  pMemCke   <= '1';
  pMemCs_n  <= SdrCmd(3);
  pMemRas_n <= SdrCmd(2);
  pMemCas_n <= SdrCmd(1);
  pMemWe_n  <= SdrCmd(0);

  pMemUdq   <= SdrUdq;
  pMemLdq   <= SdrLdq;
  pMemBa1   <= SdrBa1;
  pMemBa0   <= SdrBa0;

  pMemAdr   <= SdrAdr;
  pMemDat   <= SdrDat;


  ----------------------------------------------------------------
  -- Reserved ports (USB)
  ----------------------------------------------------------------
  pUsbP1    <= 'Z';
  pUsbN1    <= 'Z';
  pUsbP2    <= 'Z';
  pUsbN2    <= 'Z';


  ----------------------------------------------------------------
  -- Connect components
  ----------------------------------------------------------------
  U00 : pll4x
    port map(
      inclk0 => pClk21m,        -- 21.48MHz external
      c0     => clk21m,         -- 21.48MHz internal
      c1     => memclk,         -- 85.92MHz = 21.48MHz x 4
      e0     => pMemClk         -- 85.92MHz external
    );

  U01 : t80a
    port map(
      RESET_n => pSltRst_n,
      CLK_n   => pSltClk,
      WAIT_n  => pSltWait_n,
      INT_n   => pSltInt_n,
      NMI_n   => '1',
      BUSRQ_n => BusReq_n,
      M1_n    => CpuM1_n,
      MREQ_n  => pSltMerq_n,
      IORQ_n  => pSltIorq_n,
      RD_n    => pSltRd_n,
      WR_n    => pSltWr_n,
      RFSH_n  => CpuRfsh_n,
      HALT_n  => open,
      BUSAK_n => open,
      A       => pSltAdr,
      D       => pSltDat
    );
    BusReq_n  <= '1' when SelfMode = '1' else '0';

  U02 : iplrom
    port map(clk21m, adr, RomDbi);

  U03 : megasd
    port map(clk21m, reset, clkena, ErmReq, ErmAck, wrt, adr, ErmDbi, dbo, 
             ErmRam, ErmWrt, ErmAdr, RamDbi, ErmDbo, 
             MmcDbi, MmcEna, MmcAct, pSd_Ck, pSd_Dt(3), pSd_Cm, pSd_Dt(0), 
             EPC_CK, EPC_CS, EPC_OE, EPC_DI, EPC_DO);
    pSd_Dt(2 downto 0) <= (others => 'Z');

  U04 : cycloneii_asmiblock
    port map(EPC_CK, EPC_CS, EPC_DI, EPC_OE, EPC_DO);

  U05 : mapper
    port map(clk21m, reset, clkena, MapReq, MapAck, mem, wrt, adr, MapDbi, dbo, 
             MapRam, MapWrt, MapAdr, RamDbi, MapDbo);

  U06 : eseps2
    port map (clk21m, reset, clkena, Kmap, Caps, Kana, Paus, open, Reso, Fkeys, 
              pPs2Clk, pPs2Dat, PpiPortC, PpiPortB);

  U07 : rtc
    port map(clk21m, reset, clkena, RtcReq, RtcAck, wrt, adr, RtcDbi, dbo);

  U08 : kanji
    port map(clk21m, reset, clkena, KanReq, KanAck, wrt, adr, KanDbi, dbo, 
             KanRom, KanAdr, RamDbi, KanDbo);

  U20 : vdp
    port map(
      clk21m, reset, VdpReq, VdpAck, wrt, adr, VdpDbi, dbo, pVdpInt_n, 
      OeVdp_n, WeVdp_n, VdpAdr, VrmDbi, VrmDbo,
      VideoR, VideoG, VideoB, VideoHS_n, VideoVS_n, VideoCS_n, 
      VideoDHClk, VideoDLClk, open, open, Reso_v, Fkeys(0),
      osdLocateX, osdLocateY, osdCharCodeIn, osdCharWrReq, osdCharWrAck
    );

  U21 : vencode
    port map(
      clk21m, reset, VideoR, VideoG, videoB, VideoHS_n, VideoVS_n,
      videoY, videoC, videoV
    );

  U30 : psg
    port map(clk21m, reset, clkena, PsgReq, PsgAck, wrt, adr, PsgDbi, dbo, 
             pJoyA, pStrA, pJoyB, pStrB, Kana, CmtIn, KeyMode, PsgAmp);

  U31 : megaram
    port map(clk21m, reset, clkena, SccReq, SccAck, wrt, adr, SccDbi, dbo, 
             SccRam, SccWrt, SccAdr, RamDbi, SccDbo, MegType, SccAmpL, SccAmpR);

  U32 : eseopll
    port map(clk21m, reset, clkena, OpllEnaWait, OpllReq, OpllAck, wrt, adr, dbo, OpllAmp);
    OpllEnaWait <= '1' when clksel /= "00" else '0';

  U33: esepwm
    generic map ( DAC_MSBI ) port map (clk21m, reset, DACin, DACout);


end rtl;
