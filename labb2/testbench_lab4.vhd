library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.ALL;

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
	--type MEMORY_ARRAY is ARRAY ( 0 TO (2**ADDR_WIDTH)-1) of std_logic_vector((DATA_WIDTH - 1) DOWNTO 0 );

	impure function init_testval_wfile(mif_file_name : in string; Lines: in integer; bit_length: in Integer) return vector_array is
    		file mif_file : text open read_mode is mif_file_name;
    		variable mif_line : line;
    		variable temp_bv : bit_vector(bit_length - 1 downto 0); -- antalet bitar som behövs förändras 11 behövs vi ett tillfälle
    		variable temp_val_vec : vector_array(Lines - 1 downto 0)(bit_length - 1 downto 0);
		variable i : integer := 0;
	begin
    		while not endfile(mif_file) loop
        		readline(mif_file, mif_line);
        		read(mif_line, temp_bv);
        		temp_val_vec(i) := to_stdlogicvector(temp_bv);
			i := i + 1;
    		end loop;
    	return temp_val_vec;
	end function;

--SIGNAL Mem_arr: MEMORY_ARRAY := init_memory_wfile(INIT_FILE);
--SIGNAL <name> : vector_array(<length>)(<width>) := <initialization>

-- finns 32 lines i pc2seg.trace så antar 32 with behövs
SIGNAL pcTrace        : vector_array(0 TO 31)(0 TO 7) := init_testval_wfile("pc2seg.trace",32,8);
SIGNAL imDataOutTrace : vector_array(0 TO 31)(0 TO 11) := init_testval_wfile("imDataOut2seg.trace",32,12);
SIGNAL dmDataOutTrace : vector_array(0 TO 31)(0 TO 7) := init_testval_wfile("dmDataOut2seg.trace",32,8);
SIGNAL accTrace       : vector_array(0 TO 31)(0 TO 7) := init_testval_wfile("acc2seg.trace",32,8);
SIGNAL dsTrace        : vector_array(0 TO 31)(0 TO 7) := init_testval_wfile("ds2seg.trace",32,8);

BEGIN

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

    pcTesting: PROCESS(clk)
	variable u0 : integer := 0;
    BEGIN -- aktiveras processen vid fel tillfälle? kanke ska vara en klock cykel efter?
	IF (clk'EVENT AND clk = '0' AND master_load_enable = '1' AND (u0 < 32))
	THEN
		pc2seg_tb <= pcTrace(u0);
		-- behöver kolla här om värdet vi får är fel?
		u0 := u0 + 1;
	END IF;
    END PROCESS pcTesting;

    imDataTesting: PROCESS(clk)
	variable u1 : integer := 0;
    BEGIN -- aktiveras processen vid fel tillfälle? kanke ska vara en klock cykel efter?
	IF (clk'EVENT AND clk = '0' AND master_load_enable = '1' AND (u1 < 32))
	THEN
		imDataOut2seg_tb <= imDataOutTrace(u1);
		-- behöver kolla här om värdet vi får är fel?
		u1 := u1 + 1;
	END IF;
    END PROCESS imDataTesting;

    dmDataTesting: PROCESS(clk)
    variable u2 : integer := 0;
    BEGIN -- aktiveras processen vid fel tillfälle? kanke ska vara en klock cykel efter?
	IF (clk'EVENT AND clk = '0' AND master_load_enable = '1' AND (u2 < 32))
	THEN
		dmDataOut2seg_tb <= dmDataOutTrace(u2);
		-- behöver kolla här om värdet vi får är fel?
		u2 := u2 + 1;
	END IF;
    END PROCESS dmDataTesting;

    accTesting: PROCESS(clk)
    variable u3 : integer := 0;
    BEGIN -- aktiveras processen vid fel tillfälle? kanke ska vara en klock cykel efter?
	IF (clk'EVENT AND clk = '0' AND master_load_enable = '1' AND (u3 < 32))
	THEN
		acc2seg_tb <= accTrace(u3);
		-- behöver kolla här om värdet vi får är fel?
		u3 := u3 + 1;
	END IF;
    END PROCESS accTesting;

    dsTesting: PROCESS(clk)
    variable u4 : integer := 0;
    BEGIN -- aktiveras processen vid fel tillfälle? kanke ska vara en klock cykel efter?
	IF (clk'EVENT AND clk = '0' AND master_load_enable = '1' AND (u4 < 32))
	THEN
		ds2seg_tb <= dsTrace(u4);
		-- behöver kolla här om värdet vi får är fel?
		u4 := u4 + 1;
	END IF;
    END PROCESS dsTesting;

end architecture test_arch;