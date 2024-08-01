library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity top is
    port (        
        -- SMA J95 Bank 64-12P
        ams_fpga_ref_clk           : out   std_logic
    );
end entity top;

architecture structural of top is

-- System Clock
signal system_clk                            : std_logic;
signal system_clk_reset                      : std_logic;
signal clk_out_0                             : std_logic;

-- Clocks
signal clk300                                : std_logic;
signal clk200                                : std_logic;
signal clk100                                : std_logic;
signal pl_clk1                               : std_logic;
signal user_si570_ibuf                       : std_logic;
signal mux_out_0                             : std_logic;
signal mux_out_1                             : std_logic;
signal sma_conn                              : std_logic;
signal clk_sel                               : std_logic_vector(1 downto 0);

-- Interrupts
signal ps_interrupt                          : std_logic_vector(15 downto 3);
signal ps_intr                               : std_logic_vector(15 downto 0);
signal irq_rfdc                              : std_logic;

-- Clocks & Resets
signal axi_aclk                              : std_logic;
signal axi_areset                            : std_logic;
signal axi_aresetn                           : std_logic;

signal rf_axis_aclk                          : std_logic;
signal rf_axis_areset                        : std_logic;
signal rf_axis_aresetn                       : std_logic;
    
-- AXI-Lite Interface to the ctl_bus Adapter
signal axi_ctl_araddr                        : std_logic_vector(31 downto 0);
signal axi_ctl_arready                       : std_logic;
signal axi_ctl_arvalid                       : std_logic;
signal axi_ctl_awaddr                        : std_logic_vector(31 downto 0);
signal axi_ctl_awready                       : std_logic;
signal axi_ctl_awvalid                       : std_logic;
signal axi_ctl_bready                        : std_logic;
signal axi_ctl_bresp                         : std_logic_vector(1 downto 0);
signal axi_ctl_bvalid                        : std_logic;
signal axi_ctl_rdata                         : std_logic_vector(31 downto 0);
signal axi_ctl_rready                        : std_logic;
signal axi_ctl_rresp                         : std_logic_vector(1 downto 0);
signal axi_ctl_rvalid                        : std_logic;
signal axi_ctl_wdata                         : std_logic_vector(31 downto 0);
signal axi_ctl_wready                        : std_logic;
signal axi_ctl_wvalid                        : std_logic;

-- AXI-Lite Interface to the Stream Adapter
signal axi_str_araddr                        : std_logic_vector(31 downto 0);
signal axi_str_arready                       : std_logic;
signal axi_str_arvalid                       : std_logic;
signal axi_str_awaddr                        : std_logic_vector(31 downto 0);
signal axi_str_awready                       : std_logic;
signal axi_str_awvalid                       : std_logic;
signal axi_str_bready                        : std_logic;
signal axi_str_bresp                         : std_logic_vector(1 downto 0);
signal axi_str_bvalid                        : std_logic;
signal axi_str_rdata                         : std_logic_vector(31 downto 0);
signal axi_str_rready                        : std_logic;
signal axi_str_rresp                         : std_logic_vector(1 downto 0);
signal axi_str_rvalid                        : std_logic;
signal axi_str_wdata                         : std_logic_vector(31 downto 0);
signal axi_str_wready                        : std_logic;
signal axi_str_wvalid                        : std_logic;

-- DAC NCO Update Controls
signal dac0_nco_nco_update_request           : std_logic;
signal dac0_nco_nco_update_busy              : std_logic_vector(1 downto 0);
signal dac0_nco_sysref_int_gating            : std_logic;
signal dac0_nco_sysref_int_reenable          : std_logic;

-- AXI Streams
signal axis_dac00_tdata                      : std_logic_vector(63 downto 0);
signal axis_dac00_tready                     : std_logic;
signal axis_dac00_tvalid                     : std_logic;

signal dac0_nco_converter0_nco_freq          : std_logic_vector(47 downto 0);
signal dac0_nco_converter0_nco_phase         : std_logic_vector(17 downto 0);
signal dac0_nco_converter0_phase_reset       : std_logic;
signal dac0_nco_converter0_update_en         : std_logic_vector(5 downto 0);

-- DAC RTS Controls
signal dac0_rts_converter0_datapath_overflow : std_logic;
signal dac0_rts_converter0_fast_shutdown     : std_logic_vector(2 downto 0);
signal dac0_rts_converter0_pl_event          : std_logic;

-- ADC NCO Controls
signal adc0_nco_nco_update_request           : std_logic;
signal adc0_nco_nco_update_busy              : std_logic;

-- ADC
signal axis_adc00_tdata                      : std_logic_vector(31 downto 0);
signal axis_adc00_tready                     : std_logic;
signal axis_adc00_tvalid                     : std_logic;

signal axis_adc01_tdata                      : std_logic_vector(31 downto 0);
signal axis_adc01_tready                     : std_logic;
signal axis_adc01_tvalid                     : std_logic;

signal adc0_nco_converter01_nco_freq         : std_logic_vector(47 downto 0);
signal adc0_nco_converter01_nco_phase        : std_logic_vector(17 downto 0);
signal adc0_nco_converter01_phase_reset      : std_logic;
signal adc0_nco_converter01_update_en        : std_logic_vector(5 downto 0);

-- ADC RTS Controls
signal adc0_rts_converter01_clear_or         : std_logic;
signal adc0_rts_converter01_over_range       : std_logic;
signal adc0_rts_converter01_over_threshold1  : std_logic;
signal adc0_rts_converter01_over_threshold2  : std_logic;
signal adc0_rts_converter01_over_voltage     : std_logic;
signal adc0_rts_converter0_datapath_overflow : std_logic;
signal adc0_rts_converter0_pl_event          : std_logic;
signal adc0_rts_converter1_datapath_overflow : std_logic;
signal adc0_rts_converter1_pl_event          : std_logic;

-- ADC
signal axis_adc02_tdata                      : std_logic_vector(31 downto 0);
signal axis_adc02_tready                     : std_logic;
signal axis_adc02_tvalid                     : std_logic;

signal axis_adc03_tdata                      : std_logic_vector(31 downto 0);
signal axis_adc03_tready                     : std_logic;
signal axis_adc03_tvalid                     : std_logic;

signal adc0_nco_converter23_nco_freq         : std_logic_vector(47 downto 0);
signal adc0_nco_converter23_nco_phase        : std_logic_vector(17 downto 0);
signal adc0_nco_converter23_phase_reset      : std_logic;
signal adc0_nco_converter23_update_en        : std_logic_vector(5 downto 0);

-- ADC RTS Controls
signal adc0_rts_converter23_clear_or         : std_logic;
signal adc0_rts_converter23_over_range       : std_logic;
signal adc0_rts_converter23_over_threshold1  : std_logic;
signal adc0_rts_converter23_over_threshold2  : std_logic;
signal adc0_rts_converter23_over_voltage     : std_logic;
signal adc0_rts_converter2_datapath_overflow : std_logic;
signal adc0_rts_converter2_pl_event          : std_logic;
signal adc0_rts_converter3_datapath_overflow : std_logic;
signal adc0_rts_converter3_pl_event          : std_logic;

-- Generated Clocks
signal clk_dac0                              : std_logic;
signal clk_adc0                              : std_logic;

signal user_sysref                           : std_logic;

begin

--------------------------------------------------------------------------------
-- XILINX IP BLOCK DESIGN                                                     --
--------------------------------------------------------------------------------

    bd_inst : entity bd_wrapper
        port map (
            -- System Clock
            clk_out_0                                => clk_out_0
        );

--------------------------------------------------------------------------------
-- SMA Connector 
-------------------------------------------------------------------------------- 
ams_fpga_ref_clk <= clk_out_0;
--------------------------------------------------------------------------------
    
end architecture structural;
