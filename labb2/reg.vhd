library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (width: integer := 8);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(width-1 downto 0);
        dataOut: out std_logic_vector(width-1 downto 0)
    );
end entity reg;

