###########################################################################
#
# Generated by : Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Full Version
#
# Project      : tpg
# Revision     : tpg
#
# Date         : Fri Oct 15 15:15:03 +1100 2010
#
###########################################################################
 
 
# WARNING: Expected ENABLE_CLOCK_LATENCY to be set to 'ON', but it is set to 'OFF'
#          In SDC, create_generated_clock auto-generates clock latency
#
# ------------------------------------------
#
# Create generated clocks based on PLLs
derive_pll_clocks -use_tan_name
#
# ------------------------------------------


# Original Clock Setting Name: clk_25_a
create_clock -period "40.960 ns" \
             -name {clk_25_a} {clk_25_a}
# ---------------------------------------------


# Original Clock Setting Name: pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]
# WARNING: Ignoring OFFSET_FROM_BASE_CLOCK assignment for clock 'pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]'
create_generated_clock -divide_by 3 -multiply_by 5  \
                       -source clk_25_a \
                       -name {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]} \
                       {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]}
# ---------------------------------------------


# Original Clock Setting Name: pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[1]
# WARNING: Ignoring OFFSET_FROM_BASE_CLOCK assignment for clock 'pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[1]'
create_generated_clock -divide_by 3 -multiply_by 5  \
                       -source clk_25_a \
                       -name {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[1]} \
                       {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[1]}
# ---------------------------------------------

#create_generated_clock -name vdo_clk -source [get_nets {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[1]}] [get_ports {clkrst_i.clk(1)}]
create_generated_clock -name vo_idck -source {pll:\BLK_CLOCKING:GEN_PLL:pll_inst|altpll:altpll_component|pll_altpll:auto_generated|wire_pll1_clk[0]} [get_ports {vo_idck}]

# ** Clock Latency
#    -------------

# ** Clock Uncertainty
#    -----------------

# ** Multicycles
#    -----------
# ** Cuts
#    ----

# ** Input/Output Delays
#    -------------------

# TFP410 register timing (timing defined as source synchronous)
set vo_idck_tsu_min 1.2
set vo_idck_th_min 1.3

# TFP410 board trace delays relative to clock trace
set vo_data_delay_max 0.500
set vo_data_delay_min -0.100

# TFP410 output min and max delays
set_output_delay -clock vo_idck -max [expr $vo_data_delay_max + $vo_idck_tsu_min] [get_ports {vo_blue[*] vo_de vo_green[*] vo_hsync vo_red[*] vo_vsync}]
set_output_delay -clock vo_idck -min [expr $vo_data_delay_min - $vo_idck_th_min] [get_ports {vo_blue[*] vo_de vo_green[*] vo_hsync vo_red[*] vo_vsync}]


# ** Tpd requirements
#    ----------------

# ** Setup/Hold Relationships
#    ------------------------

# ** Tsu/Th requirements
#    -------------------


# ** Tco/MinTco requirements
#    -----------------------



# ---------------------------------------------

