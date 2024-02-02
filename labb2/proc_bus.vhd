library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_bus is
    port (
        decoEnable : in std_logic;
        decoSel    : in std_logic_vector(1 downto 0);
        imDataOut   : in std_logic_vector(7 downto 0);
        dmDataOut     : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0)
    );
end proc_bus;

ARCHITECTURE behaviora OF proc_bus IS 
BEGIN
    -- BUS states
    --subtype bsel_t is std_logic_vector(1 downto 0);
    --constant B_IMEM : bsel_t := "00";
    --constant B_DMEM : bsel_t := "01";
    --constant B_ACC  : bsel_t := "10";
    --constant B_EXT  : bsel_t := "11";

 -- typ decodern
Sel <= decoSel WHEN decoEnable = '1' ELSE "ZZ";
with Sel SELECT
	deco_out <= "0001" WHEN B_IMEM,
	            "0010" WHEN B_DMEM,
		    "0100" WHEN B_ACC,
		    "1000" WHEN B_EXT,
	            "ZZZZ" WHEN OTHERS;

--typ 4:1 multiplexer
with deco_out SELECT
	busOut <=     imDataOut WHEN "0001",
	              dmDataOut WHEN "0010",
		         accOut WHEN "0100",
		          extIn WHEN "1000",
	                 "ZZZZ" WHEN OTHERS;

  PROCESS ( clk ) 
  BEGIN
    
    IF rising_edge(clk)THEN
	 
    END IF;

  END PROCESS ; 
END behaviora;