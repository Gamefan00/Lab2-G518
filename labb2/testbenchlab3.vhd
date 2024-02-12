library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EDA322_processor_tb is
end entity EDA322_processor_tb;

architecture test_arch of EDA322_processor_tb is
    constant c_CLK_PERIOD : time := 10 ns;
    constant c_MLE_PERIOD : time := 20 ns;
    
    component EDA322_processor is
    generic (dInitFile : string; iInitFile : string);
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
	    aluOut2seg         : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
    end component EDA322_processor;
    
    signal clk                  : std_logic    := '0';
    signal resetn               : std_logic    := '0';
    signal master_load_enable   : std_logic    := '0';
   
    signal extIn_tb          : std_logic_vector(7 downto 0);
    signal pc2seg_tb         : std_logic_vector(7 downto 0);
    signal imDataOut2seg_tb  : std_logic_vector(11 downto 0);
    signal dmDataOut2seg_tb  : std_logic_vector(7 downto 0);
    signal acc2seg_tb        : std_logic_vector(7 downto 0);
    signal aluOut2seg_tb     : std_logic_vector(7 downto 0);
    signal busOut2seg_tb     : std_logic_vector(7 downto 0);
    signal ds2seg_tb         : std_logic_vector(7 downto 0);
    
begin

    clk <= not clk after c_CLK_PERIOD/2;
    master_load_enable <= not master_load_enable after c_MLE_PERIOD/2;
    
    CHACC_dut : component EDA322_processor
        generic map(dInitFile => "d_memory_lab3.mif", iInitFile => "i_memory_lab3.mif")
        port map(
            clk                 => clk,
            resetn              => resetn,
            master_load_enable  => master_load_enable,
            extIn               => extIn_tb,
            pc2seg              => pc2seg_tb,
            imDataOut2seg       => imDataOut2seg_tb,
            dmDataOut2seg       => dmDataOut2seg_tb,
            acc2seg             => acc2seg_tb,
            aluOut2seg          => aluOut2seg_tb,
            busOut2seg          => busOut2seg_tb,
            ds2seg              => ds2seg_tb
        );
        
        
    resetn <= '0',
              '1' after c_CLK_PERIOD;
    extIn_tb <= "00000000", "10100110" after 120 ns;
end architecture test_arch;
