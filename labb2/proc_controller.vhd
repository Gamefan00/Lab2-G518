library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_controller is
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
end proc_controller;

ARCHITECTURE Behavior OF proc_controller IS
	type state_type is (FE, DE1, DE2, EX, ME);
	SIGNAL curr_state : state_type;
	SIGNAL next_state : state_type;
	SIGNAL OPout:STD_LOGIC_VECTOR(13 downto 0); -- 14 bit's 

BEGIN
	FSM_FF: PROCESS(clk, resetn)
	BEGIN 	
		IF resetn = '0' THEN -- Asyncron reset
	   	   curr_state <= FE;
		ELSIF (clk'EVENT AND clk = '1') THEN
		   curr_state <= next_state;
		END IF;

	END PROCESS FSM_FF;
		
	--The logic that decides the next state
	FSM_LOGIC: PROCESS (curr_state, opcode)-- current state and input
	BEGIN
	next_state <= curr_state;
	CASE curr_state IS
		WHEN FE =>
			IF opcode = O_NOOP THEN
			next_state <= FE;
			ELSIF opcode < O_CMP THEN -- Behöver inte hoppa till DE1
			next_state <= EX;
			ELSIF opcode = O_SB THEN 
			next_state <= ME;
			ELSE
			next_state <= DE1;
			END IF;
		WHEN DE1 =>
			IF opcode = O_LBI THEN
			  next_state <= DE2;
			ELSIF opcode = O_SBI THEN
			  next_state <= ME;
			ELSE
			  next_state <= EX;
		END IF;
		WHEN DE2 => next_state <= EX;
		WHEN OTHERS => next_state <= FE;
		END CASE;
		
	END PROCESS FSM_LOGIC;

	-- z <= '1' WHEN (y = B) AND (w=?1?) ELSE '0' ;
	-- OPout <= "0000" WHEN (curr_state = FE) AND (opcode = "0000") ELSE " ";
	
	-- outputs värde sättning vid state FE:
	-- börjar med en sammling av värden som FE kan ändra på
	--OPout(6 DOWNTO 0) <= "0000000" WHEN (curr_state = FE) AND (opcode = "0000") ELSE " ";

	OUTPUT: PROCESS (next_state, opcode)
	BEGIN
	CASE next_state IS
		WHEN FE => 
			  OPout(13 DOWNTO 7) <= "0--0---";
			  OPout(6 DOWNTO 0)  <= "1001000";
		WHEN DE1 =>
			IF opcode = O_ROL THEN -- behövs detta äns om rol inte sättser något?
			  OPout(13 DOWNTO 7) <= "0--0000";
			  OPout(6 DOWNTO 0)  <= (OTHERS => '0');
			ELSE 
			  OPout(13 DOWNTO 7) <= "1000---";
			  OPout(6 DOWNTO 0)  <= "0100000";
			END IF;
		WHEN DE2 => 
			  OPout(13 DOWNTO 7) <= "10100--";
			  OPout(6 DOWNTO 0)  <= "0100000";
		WHEN EX =>
			OPout(8 DOWNTO 7) <= opcode(1 DOWNTO 0);

			IF opcode = O_IN THEN
			  OPout(13 DOWNTO 7) <= "11101";
			  OPout(6 DOWNTO 0) <="0000010";
			ELSIF opcode = O_DS THEN
			  OPout(13 DOWNTO 7) <= "0--0-";
			  OPout(6 DOWNTO 0) <="0000001";
			ELSIF opcode = O_MOV THEN
			  OPout(13 DOWNTO 7) <= "10001";
			  OPout(6 DOWNTO 0) <="0000010";
			ELSIF((opcode = O_JE) AND (e_flag = '1')) OR
			   (opcode = O_JE AND NOT (e_flag = '1'))OR
			   (opcode = O_JE AND (z_flag = '1')) THEN
				OPout(13 DOWNTO 7) <= "1001-";
				OPout(6 DOWNTO 0)  <="0001000";
			ELSIF opcode = O_ROL THEN
			  OPout(13 DOWNTO 7) <= "0--00";
			  OPout(6 DOWNTO 0) <="0000110";
			ELSIF opcode = O_CMP THEN
			  OPout(13 DOWNTO 7) <= "1010-";
			  OPout(6 DOWNTO 0) <="0000100";
			ELSIF opcode > O_SUB THEN
			  OPout(13 DOWNTO 7) <= "10101";
			  OPout(6 DOWNTO 0) <="0000010";
			ELSE
			  OPout(13 DOWNTO 7) <= "10100";
			  OPout(6 DOWNTO 0) <="0000110";
			END IF;
		WHEN ME =>
			  OPout(13 DOWNTO 7) <= "1000---";
			  OPout(6 DOWNTO 0)  <= "0001000";
			IF opcode = O_SBI THEN
			  OPout(11) <= '1';
			END IF;
			END CASE;
	END PROCESS OUTPUT;

	OUTPUT_REG: PROCESS(clk)
	BEGIN
	IF (clk'event AND clk='1') THEN
		decoEnable <= OPout(13);
		decoSel    <= OPout(12 DOWNTO 11);
		pcSel      <= OPout(10);
		accSel     <= OPout(9);
		aluOp      <= OPout(8 DOWNTO 7);
	
	IF master_load_enable = '1' THEN
		imRead     <= OPout(6);
		dmRead     <= OPout(5);
		pcLd       <= OPout(4);
		flagLd     <= OPout(3);
		accLd      <= OPout(2);
		dsLd       <= OPout(1);
	ELSE
		imRead     <= '0';
		dmRead     <= '0';
		pcLd       <= '0';
		flagLd     <= '0';
		accLd      <= '0';
		dsLd       <= '0';
	END IF;

	END IF;
	END PROCESS OUTPUT_REG ;


END Behavior ;