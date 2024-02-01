library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity alu_wRCA is
    port(
        alu_inA, alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end alu_wRCA;

ARCHITECTURE Dataflow OF alu_wRCA IS

COMPONENT rca 
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end COMPONENT;

COMPONENT cmp 
port(   a: in   std_logic_vector (7 downto 0);
        b: in   std_logic_vector (7 downto 0);
    	e: out  std_logic);
end COMPONENT;

COMPONENT rotateleft 
port(   a: in   std_logic_vector (7 downto 0);
    	r: out  std_logic_vector (7 downto 0));
end COMPONENT;

SIGNAL op_out:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL addOrSub:std_logic;
SIGNAL b:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL sum:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL Rol_out:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL and_out:STD_LOGIC_VECTOR(7 downto 0);

BEGIN
	
with alu_op SELECT
	addOrSub <= '1' WHEN "11",
	            '0' WHEN "10",
	            '0' WHEN OTHERS; -- denna behövs nog inte
with alu_op SELECT
	b <= NOT(alu_inB) WHEN "11", -- Negerar detta hela talet bitvis ?
		  alu_inB WHEN "10",
	       "00000000" WHEN OTHERS; -- denna behövs nog inte

and_out <= alu_inA And alu_inB;

rca_I: entity work.rca PORT MAP(alu_inA,b,addOrSub,C,sum);
cmp_I: entity work.cmp PORT MAP(alu_inA,alu_inB,E);
rol_I: entity work.rotateleft PORT MAP(alu_inA,Rol_out);

with alu_op SELECT
	op_out <= Rol_out WHEN "00",
	          and_out WHEN "01",
	              sum WHEN OTHERS; -- "10" "11"

Z <= '1' WHEN op_out = "00000000" ELSE '0';

alu_out <= op_out; -- kan inte jämföra alu_out med noll
--if op = "0" then Z <=1;

END Dataflow;

