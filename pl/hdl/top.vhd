library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity top is
    port (
        -- 300 MHz Source Clock
        user_si570_p               : in    std_logic;
        user_si570_n               : in    std_logic;

        -- Push Button Reset
        cpu_reset                  : in    std_logic;

        -- RFDC SYSREF
        sysref_in_diff_p           : in    std_logic;
        sysref_in_diff_n           : in    std_logic;

        -- FPGA Refclk (LMK04208 OUT2)
        fpga_refclk_p              : in    std_logic;
        fpga_refclk_n              : in    std_logic;
        
        -- LEDs
        gpio_led                   : out   std_logic_vector (1 downto 0);
        
        -- SMA J95 Bank 64-12P
        ams_fpga_ref_clk           : out   std_logic
    );
end entity top;

architecture structural of top is

-- System Clock
signal system_clk                            : std_logic;
signal system_clk_reset                      : std_logic;

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
-- Clock (Si570 (300MHz) -> MMCM -> clkxxxMHz)
--------------------------------------------------------------------------------
	-- Buffer the input clocks.
	user_si570_ibufds : IBUFDS
		port map (
			I  => user_si570_p,
			IB => user_si570_n,
			O  => user_si570_ibuf
		);
        
    -- Generate the 300 MHz, 200 MHz, and 100 MHz clocks.
    clkwiz_inst : entity clk_wiz_0
       port map(	
            -- Clock in ports
            clk_in1 => user_si570_ibuf,     -- input clk_in1_p
            
            -- Clock out ports
            clk_out1 => clk300,     -- output clk_out1
            clk_out2 => clk200,     -- output clk_out2
            clk_out3 => clk100      -- output clk_out3
       );
--------------------------------------------------------------------------------
-- XILINX IP BLOCK DESIGN                                                     --
--------------------------------------------------------------------------------

    bd_inst : entity bd_wrapper
        port map (
            -- System Clock
            clk100                                => clk100,
            
            -- Asynchronous Reset
            reset                                 => cpu_reset,

            -- Interrupts
            ps_intr                               => ps_interrupt,
            irq_rfdc                              => irq_rfdc,

            -- AXI-Lite Clock
            m_axi_aclk                            => axi_aclk,
            m_axi_areset(0)                       => axi_areset,
            m_axi_aresetn(0)                      => axi_aresetn,

            -- CTL AXI-Lite Interface
            m_axi_ctl_araddr                      => axi_ctl_araddr,
            m_axi_ctl_arprot                      => OPEN,
            m_axi_ctl_arready(0)                  => axi_ctl_arready,
            m_axi_ctl_arvalid(0)                  => axi_ctl_arvalid,
            m_axi_ctl_awaddr                      => axi_ctl_awaddr,
            m_axi_ctl_awprot                      => OPEN,
            m_axi_ctl_awready(0)                  => axi_ctl_awready,
            m_axi_ctl_awvalid(0)                  => axi_ctl_awvalid,
            m_axi_ctl_bready(0)                   => axi_ctl_bready,
            m_axi_ctl_bresp                       => axi_ctl_bresp,
            m_axi_ctl_bvalid(0)                   => axi_ctl_bvalid,
            m_axi_ctl_rdata                       => axi_ctl_rdata,
            m_axi_ctl_rready(0)                   => axi_ctl_rready,
            m_axi_ctl_rresp                       => axi_ctl_rresp,
            m_axi_ctl_rvalid(0)                   => axi_ctl_rvalid,
            m_axi_ctl_wdata                       => axi_ctl_wdata,
            m_axi_ctl_wready(0)                   => axi_ctl_wready,
            m_axi_ctl_wstrb                       => OPEN,
            m_axi_ctl_wvalid(0)                   => axi_ctl_wvalid,

            -- STR AXI-Lite Interface
            m_axi_str_araddr                      => axi_str_araddr,
            m_axi_str_arprot                      => OPEN,
            m_axi_str_arready(0)                  => axi_str_arready,
            m_axi_str_arvalid(0)                  => axi_str_arvalid,
            m_axi_str_awaddr                      => axi_str_awaddr,
            m_axi_str_awprot                      => OPEN,
            m_axi_str_awready(0)                  => axi_str_awready,
            m_axi_str_awvalid(0)                  => axi_str_awvalid,
            m_axi_str_bready(0)                   => axi_str_bready,
            m_axi_str_bresp                       => axi_str_bresp,
            m_axi_str_bvalid(0)                   => axi_str_bvalid,
            m_axi_str_rdata                       => axi_str_rdata,
            m_axi_str_rready(0)                   => axi_str_rready,
            m_axi_str_rresp                       => axi_str_rresp,
            m_axi_str_rvalid(0)                   => axi_str_rvalid,
            m_axi_str_wdata                       => axi_str_wdata,
            m_axi_str_wready(0)                   => axi_str_wready,
            m_axi_str_wstrb                       => OPEN,
            m_axi_str_wvalid(0)                   => axi_str_wvalid,

            -- RF AXI Stream Clock (FPGA REF CLK -> MMCM ->  250MHz)
            rf_axis_aclk                          => rf_axis_aclk,
            rf_axis_aresetn(0)                    => rf_axis_aresetn,
            rf_axis_areset(0)                     => rf_axis_areset,
            
            -- PL CLK 1
            pl_clk1                               => pl_clk1,

            -- DAC 0-3 NCO Update Controls
            dac0_nco_nco_update_request           => dac0_nco_nco_update_request,
            dac0_nco_nco_update_busy              => dac0_nco_nco_update_busy,
            dac0_nco_sysref_int_gating            => dac0_nco_sysref_int_gating,
            dac0_nco_sysref_int_reenable          => dac0_nco_sysref_int_reenable,

            -- DAC 0
            s00_axis_tdata                        => axis_dac00_tdata,                   -- in  (63:0)
            s00_axis_tready                       => axis_dac00_tready,                  -- out
            s00_axis_tvalid                       => axis_dac00_tvalid,                  -- in

            dac0_nco_converter0_nco_freq          => dac0_nco_converter0_nco_freq,
            dac0_nco_converter0_nco_phase         => dac0_nco_converter0_nco_phase,
            dac0_nco_converter0_phase_reset       => dac0_nco_converter0_phase_reset,
            dac0_nco_converter0_update_en         => dac0_nco_converter0_update_en,

            dac0_rts_converter0_datapath_overflow => dac0_rts_converter0_datapath_overflow,
            dac0_rts_converter0_fast_shutdown     => dac0_rts_converter0_fast_shutdown,
            dac0_rts_converter0_pl_event          => dac0_rts_converter0_pl_event,

            -- ADC 0-1 NCO Update Controls
            adc0_nco_nco_update_request           => adc0_nco_nco_update_request,
            adc0_nco_nco_update_busy              => adc0_nco_nco_update_busy,

            -- ADC 0
            m00_axis_tdata                        => axis_adc00_tdata,
            m00_axis_tready                       => axis_adc00_tready,
            m00_axis_tvalid                       => axis_adc00_tvalid,

            m01_axis_tdata                        => axis_adc01_tdata,
            m01_axis_tready                       => axis_adc01_tready,
            m01_axis_tvalid                       => axis_adc01_tvalid,

            adc0_nco_converter01_nco_freq         => adc0_nco_converter01_nco_freq,
            adc0_nco_converter01_nco_phase        => adc0_nco_converter01_nco_phase,
            adc0_nco_converter01_phase_reset      => adc0_nco_converter01_phase_reset,
            adc0_nco_converter01_update_en        => adc0_nco_converter01_update_en,

            adc0_rts_converter01_clear_or         => adc0_rts_converter01_clear_or,
            adc0_rts_converter01_over_range       => adc0_rts_converter01_over_range,
            adc0_rts_converter01_over_threshold1  => adc0_rts_converter01_over_threshold1,
            adc0_rts_converter01_over_threshold2  => adc0_rts_converter01_over_threshold2,
            adc0_rts_converter01_over_voltage     => adc0_rts_converter01_over_voltage,
            adc0_rts_converter0_datapath_overflow => adc0_rts_converter0_datapath_overflow,
            adc0_rts_converter0_pl_event          => adc0_rts_converter0_pl_event,
            adc0_rts_converter1_datapath_overflow => adc0_rts_converter1_datapath_overflow,
            adc0_rts_converter1_pl_event          => adc0_rts_converter1_pl_event,

            -- ADC 1
            m02_axis_tdata                        => axis_adc02_tdata,
            m02_axis_tready                       => axis_adc02_tready,
            m02_axis_tvalid                       => axis_adc02_tvalid,

            m03_axis_tdata                        => axis_adc03_tdata,
            m03_axis_tready                       => axis_adc03_tready,
            m03_axis_tvalid                       => axis_adc03_tvalid,

            adc0_nco_converter23_nco_freq         => adc0_nco_converter23_nco_freq,
            adc0_nco_converter23_nco_phase        => adc0_nco_converter23_nco_phase,
            adc0_nco_converter23_phase_reset      => adc0_nco_converter23_phase_reset,
            adc0_nco_converter23_update_en        => adc0_nco_converter23_update_en,

            adc0_rts_converter23_clear_or         => adc0_rts_converter23_clear_or,
            adc0_rts_converter23_over_range       => adc0_rts_converter23_over_range,
            adc0_rts_converter23_over_threshold1  => adc0_rts_converter23_over_threshold1,
            adc0_rts_converter23_over_threshold2  => adc0_rts_converter23_over_threshold2,
            adc0_rts_converter23_over_voltage     => adc0_rts_converter23_over_voltage,
            adc0_rts_converter2_datapath_overflow => adc0_rts_converter2_datapath_overflow,
            adc0_rts_converter2_pl_event          => adc0_rts_converter2_pl_event,
            adc0_rts_converter3_datapath_overflow => adc0_rts_converter3_datapath_overflow,
            adc0_rts_converter3_pl_event          => adc0_rts_converter3_pl_event,

            -- Generated Clocks
            clk_dac0                              => clk_dac0,
            clk_adc0                              => clk_adc0,

            -- SYSREF
            sysref_in_diff_p                      => sysref_in_diff_p,
            sysref_in_diff_n                      => sysref_in_diff_n,

            -- PL SYSREF
            user_sysref                           => user_sysref,
            
            -- Clock Mux Select
            GPIO_0                                => clk_sel,

            -- FPGA Refclk (LMK04208 OUT2)
            fpga_refclk_clk_p                     => fpga_refclk_p,
            fpga_refclk_clk_n                     => fpga_refclk_n,

            -- DAC 0 Reference Clock
            dac0_clk_clk_p                        => dac0_clk_clk_p,
            dac0_clk_clk_n                        => dac0_clk_clk_n,

            -- ADC 0 Reference Clock
            adc0_clk_clk_p                        => adc0_clk_clk_p,
            adc0_clk_clk_n                        => adc0_clk_clk_n,
            
            -- Analog Pins
            vout00_v_p                            => vout00_v_p,
            vout00_v_n                            => vout00_v_n,

            vin0_01_v_p                           => vin0_01_v_p,
            vin0_01_v_n                           => vin0_01_v_n,

            vin0_23_v_p                           => vin0_23_v_p,
            vin0_23_v_n                           => vin0_23_v_n
        );

--------------------------------------------------------------------------------
-- Debug SMA
--------------------------------------------------------------------------------
   BUFGMUX0_inst : BUFGMUX
    generic map (
        CLK_SEL_TYPE => "SYNC"  -- ASYNC, SYNC
    )
    port map (
        S  => clk_sel(0),     -- 1-bit input: Clock select
        I0 => clk100,         -- 1-bit input: Clock input (S=0)
        I1 => pl_clk1,        -- 1-bit input: Clock input (S=1)
        O  => mux_out_0       -- 1-bit output: Clock output
    );
   
   BUFGMUX1_inst : BUFGMUX
    generic map (
        CLK_SEL_TYPE => "SYNC"  -- ASYNC, SYNC
    )
    port map (
        S  => clk_sel(1),     -- 1-bit input: Clock select
        I0 => clk100,         -- 1-bit input: Clock input (S=0)
        I1 => rf_axis_aclk,   -- 1-bit input: Clock input (S=1)
        O  => mux_out_1       -- 1-bit output: Clock output
    );
   
-- Mux
process(clk_sel) 
    begin
        case clk_sel is
            when "00"   => sma_conn <= clk100;         -- clk100        100MHz
            when "01"   => sma_conn <= pl_clk1;        -- pl_clk1       250MHz
            when "10"   => sma_conn <= rf_axis_aclk;   -- rf_axis_aclk  360MHz
            when others => sma_conn <= clk100;         -- pl_clk1       100MHz
        end case;
end process;

-- Assignment 
--ams_fpga_ref_clk <= sma_conn;
ams_fpga_ref_clk <= pl_clk1;
gpio_led(0)      <=  clk_sel(0);
gpio_led(1)      <=  clk_sel(1);

--------------------------------------------------------------------------------
    
end architecture structural;
