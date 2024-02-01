library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity cmp is
    port(   a: in   std_logic_vector (7 downto 0);
            b: in   std_logic_vector (7 downto 0);
    	    e: out  std_logic);
end cmp;

ARCHITECTURE Dataflow OF cmp IS
BEGIN
	e <= AND_REDUCE(a XNOR b);
END Dataflow;