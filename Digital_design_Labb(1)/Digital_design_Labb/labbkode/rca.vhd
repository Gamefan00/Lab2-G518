library ieee;
use ieee.std_logic_1164.all;

entity rca is
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end rca;

ARCHITECTURE Dataflow OF rca IS

COMPONENT fa 
    PORT(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic);
end COMPONENT;

SIGNAL m:STD_LOGIC_VECTOR(7 downto 0);

BEGIN
	FA_Right: entity work.fa PORT MAP(a(0),b(0),cin,m(0),s(0));

	G1:FOR i IN 1 TO 6 GENERATE
		FA_I: entity work.fa PORT MAP(a(i),b(i),m(i-1),m(i),s(i));
	END GENERATE;
	FA_Left: entity work.fa PORT MAP(a(7),b(7),m(6),cout,s(7));

END Dataflow;