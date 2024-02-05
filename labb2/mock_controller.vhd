library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;


entity mock_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;

        decoEnable: out std_logic;
        decoSel: out std_logic_vector(1 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        dsLd: out std_logic
    );
end mock_controller;

architecture Behavioral of mock_controller is

    	signal tmp1_out, tmp2_out, tmp3_out, tmp_out_in, tmp_out : std_logic;

begin
    	tmp1_out <= opcode(3) or opcode(2) or opcode(1) or opcode(0);
    	tmp2_out <= e_flag;
    	tmp3_out <= z_flag;
    	
    	tmp_out_in <= tmp1_out xnor tmp2_out xnor tmp3_out;
    	
	process(clk, resetn)
    	begin
        	if resetn = '0' then
            		tmp_out <= '0';
        	else
            		if rising_edge(clk) then
               			if master_load_enable = '1' then
                    			tmp_out <= tmp_out_in;
                		end if;
            		end if;
        	end if;
    	end process;

	decoEnable <= tmp_out;
        decoSel <= "00";
        pcSel <= tmp_out;
        pcLd <= tmp_out;
        imRead <= tmp_out;
        dmRead <= tmp_out;
        dmWrite <= tmp_out;
        aluOp <= "00";
        flagLd <= tmp_out;
        accSel <= tmp_out;
        accLd <= tmp_out;
        dsLd <= tmp_out;

end Behavioral;
