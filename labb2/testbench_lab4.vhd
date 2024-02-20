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

	impure function init_testval_wfile(mif_file_name : in string; Lines: in integer; bit_length: in Integer) return vector_array is
    		file mif_file : text open read_mode is mif_file_name;
    		variable mif_line : line;
    		variable temp_bv : bit_vector(bit_length - 1 downto 0); 
    		variable temp_val_vec : vector_array(0 To Lines - 1)(bit_length - 1 downto 0);
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

SIGNAL pcTrace        : vector_array(0 TO 31)(0 TO 7) := init_testval_wfile("pc2seg.trace",32,8);
SIGNAL imDataOutTrace : vector_array(0 TO 27)(0 TO 11) := init_testval_wfile("imDataOut2seg.trace",28,12);
SIGNAL dmDataOutTrace : vector_array(0 TO 6)(0 TO 7) := init_testval_wfile("dmDataOut2seg.trace",7,8);
SIGNAL accTrace       : vector_array(0 TO 7)(0 TO 7) := init_testval_wfile("acc2seg.trace",8,8);
SIGNAL dsTrace        : vector_array(0 TO 4)(0 TO 7) := init_testval_wfile("ds2seg.trace",5,8);

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
    extIn_tb <= "00001111";


    Test_bt: PROCESS
    BEGIN
	wait for 1700 ns;
        
        assert false report "Simulation complete at 1700 ns" severity failure;
        
        wait;
    END PROCESS Test_bt;

    pcTesting: PROCESS(pc2seg_tb,resetn)
	variable u0 : integer := 0;
	variable truthval : integer := 0;
	variable ErrorMsg: LINE;
    BEGIN
	IF (pc2seg_tb'EVENT AND resetn = '1' AND (u0 < 32))
	THEN
		IF pc2seg_tb /= pcTrace(u0) THEN
			write(ErrorMsg, STRING'("Incorrect Output at pc2seg "));
			write(ErrorMsg, now);
			writeline(output, ErrorMsg);
		ELSE
			truthval := truthval + 1;
			IF (truthval = 31) THEN
				write(ErrorMsg, STRING'("Correct Output at pc2seg "));
				write(ErrorMsg, now);
				writeline(output, ErrorMsg);
			END IF;
		END IF;
		u0 := u0 + 1;
	END IF;
    END PROCESS pcTesting;

    imDataTesting: PROCESS(imDataOut2seg_tb,resetn)
	variable u1 : integer := 0;
	variable truthval : integer := 0;
	variable ErrorMsg: LINE;
    BEGIN
	IF (imDataOut2seg_tb'EVENT AND resetn = '1' AND (u1 < 28))
	THEN
		IF imDataOut2seg_tb /= imDataOutTrace(u1) THEN
			write(ErrorMsg, STRING'("Incorrect Output at imDataOut2seg "));
			write(ErrorMsg, now);
			writeline(output, ErrorMsg);
		ELSE
			truthval := truthval + 1;
			IF (truthval = 27) THEN 
				write(ErrorMsg, STRING'("Correct Output at imDataOut2seg "));
				write(ErrorMsg, now);
				writeline(output, ErrorMsg);
			END IF;
		END IF;
		u1 := u1 + 1;
	END IF;
    END PROCESS imDataTesting;

    dmDataTesting: PROCESS(dmDataOut2seg_tb,resetn)
	variable u2 : integer := 0;
	variable truthval : integer := 0;
	variable ErrorMsg: LINE;
    BEGIN
	IF (dmDataOut2seg_tb'EVENT AND resetn = '1' AND (u2 < 7))
	THEN
		IF dmDataOut2seg_tb /= dmDataOutTrace(u2) THEN
			write(ErrorMsg, STRING'("Incorrect Output at dmDataOut2seg "));
			write(ErrorMsg, now);
			writeline(output, ErrorMsg);
		ELSE
			truthval := truthval + 1;
			IF (truthval = 6) THEN
				write(ErrorMsg, STRING'("Correct Output at dmDataOut2seg "));
				write(ErrorMsg, now);
				writeline(output, ErrorMsg);
			END IF;
		END IF;
		u2 := u2 + 1;
	END IF;
    END PROCESS dmDataTesting;

    accTesting: PROCESS(acc2seg_tb,resetn)
	variable u3 : integer := 0;
	variable truthval : integer := 0;
	variable ErrorMsg: LINE;
    BEGIN
	IF (acc2seg_tb'EVENT AND resetn = '1' AND (u3 < 8))
	THEN
		IF acc2seg_tb /= accTrace(u3) THEN
			write(ErrorMsg, STRING'("Incorrect Output at acc2seg_tb "));
			write(ErrorMsg, now);
			writeline(output, ErrorMsg);
		ELSE
			truthval := truthval + 1;
			IF (truthval = 7) THEN
				write(ErrorMsg, STRING'("Correct Output at acc2seg_tb "));
				write(ErrorMsg, now);
				writeline(output, ErrorMsg);
			END IF;
		END IF;
		u3 := u3 + 1;
	END IF;
    END PROCESS accTesting;

    dsTesting: PROCESS(ds2seg_tb,resetn)
	variable u4 : integer := 0;
	variable truthval : integer := 0;
	variable ErrorMsg: LINE;
    BEGIN
	IF (ds2seg_tb'EVENT AND resetn = '1' AND (u4 < 5))
	THEN
		IF ds2seg_tb /= dsTrace(u4) THEN
			write(ErrorMsg, STRING'("Incorrect Output at ds2seg_tb "));
			write(ErrorMsg, now);
			writeline(output, ErrorMsg);
		ELSE
			truthval := truthval + 1;
			IF (truthval = 4) THEN
				write(ErrorMsg, STRING'("Correct Output at ds2seg_tb "));
				write(ErrorMsg, now);
				writeline(output, ErrorMsg);
			END IF;
		END IF;
		u4 := u4 + 1;
	END IF;
    END PROCESS dsTesting;


end architecture test_arch;