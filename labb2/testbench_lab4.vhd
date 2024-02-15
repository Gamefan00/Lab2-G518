library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EDA322_processor_new is
end entity EDA322_processor_new;

architecture test_arch of EDA322_processor_new is
    CONSTANT c_CLK_PERIOD : time := 10 ns;
    CONSTANT c_MLE_PERIOD : time := 20 ns;
    
    COMPONENT EDA322_processor is
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
   END COMPONENT EDA322_processor;
    
    SIGNAL clk                  : std_logic    := '0';
    SIGNAL resetn               : std_logic    := '0';
    SIGNAL master_load_enable   : std_logic    := '0';
   
    SIGNAL extIn_tb          : std_logic_vector(7 downto 0);
    SIGNAL pc2seg_tb         : std_logic_vector(7 downto 0);
    SIGNAL imDataOut2seg_tb  : std_logic_vector(11 downto 0);
    SIGNAL dmDataOut2seg_tb  : std_logic_vector(7 downto 0);
    SIGNAL acc2seg_tb        : std_logic_vector(7 downto 0);
    SIGNAL aluOut2seg_tb     : std_logic_vector(7 downto 0);
    SIGNAL busOut2seg_tb     : std_logic_vector(7 downto 0);
    SIGNAL ds2seg_tb         : std_logic_vector(7 downto 0);
	
    	type vector_array is ARRAY (natural range <>) of std_logic_vector;
	type MEMORY_ARRAY is ARRAY ( 0 TO (2**ADDR_WIDTH)-1) of std_logic_vector((DATA_WIDTH - 1) DOWNTO 0 );

	impure function init_memory_wfile(mif_file_name : in string) return MEMORY_ARRAY is
    		file mif_file : text open read_mode is mif_file_name;
    		variable mif_line : line;
    		variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
    		variable temp_mem : MEMORY_ARRAY;
		variable i : integer := 0;
	begin
    		while not endfile(mif_file) loop
        		readline(mif_file, mif_line);
        		read(mif_line, temp_bv);
        		temp_mem(i) := to_stdlogicvector(temp_bv);
			i = i + 1;
    		end loop;
    	return temp_mem;
	end function;

SIGNAL Mem_arr: MEMORY_ARRAY := init_memory_wfile(INIT_FILE);
    --signal <name> : vector_array(<length>)(<width>) := <initialization>

begin

    clk <= not clk after c_CLK_PERIOD/2;
    master_load_enable <= not master_load_enable after c_MLE_PERIOD/2;
    
    CHACC_dut : COMPONENT EDA322_processor
        generic map(dInitFile => "d_memory_lab4.mif", iInitFile => "i_memory_lab4.mif")
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
    extIn_tb <= "00001111";--"00000000", "10100110" after 120 ns;
end architecture test_arch;