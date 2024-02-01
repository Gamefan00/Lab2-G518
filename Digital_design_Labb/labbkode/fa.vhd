library ieee;
use ieee.std_logic_1164.all;

entity fa is
    port(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic
    );
end fa;

ARCHITECTURE Dataflow OF fa IS
BEGIN
	cout <= (cin AND (a XOR b)) OR (a AND b);
	s <= (cin XOR a XOR b);
END Dataflow;