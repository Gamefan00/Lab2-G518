library ieee;
use ieee.std_logic_1164.all;

entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab2.mif";
             iInitFile : string := "i_memory_lab2.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
end EDA322_processor;

ARCHITECTURE Dataflow OF EDA322_processor IS

COMPONENT mock_controller is
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
end COMPONENT;

COMPONENT proc_bus
    port (
        decoEnable : in std_logic;
        decoSel    : in std_logic_vector(1 downto 0);
        imDataOut  : in std_logic_vector(7 downto 0);
        dmDataOut  : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0)
    );
end COMPONENT;

COMPONENT rca 
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end COMPONENT;

COMPONENT reg 
    generic (width: integer := 8);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(width-1 downto 0);
        dataOut: out std_logic_vector(width-1 downto 0)
    );
end COMPONENT;

COMPONENT memory 
    generic (DATA_WIDTH : integer := 8;
             ADDR_WIDTH : integer := 8;
             INIT_FILE : string := "d_memory_lab2.mif");
    port (
        clk     : in std_logic;
        readEn    : in std_logic;
        writeEn   : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end COMPONENT;

SIGNAL op_out:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL addOrSub:std_logic;

SIGNAL pclncrOut:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL jumpAddr:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL add_inp:STD_LOGIC_VECTOR(7 downto 0);


SIGNAL nextPC:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL pcSel:std_logic;
SIGNAL pcLd:std_logic;
SIGNAL pcOut:STD_LOGIC_VECTOR(7 downto 0);

SIGNAL imRead:std_logic;
SIGNAL imDataOut:STD_LOGIC_VECTOR(11 downto 0);
SIGNAL opcode:STD_LOGIC_VECTOR(3 downto 0); --eller 2 downto 0

SIGNAL decoEnable:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL decoSel:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL accOut:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL busOut:STD_LOGIC_VECTOR(7 downto 0);

BEGIN

mock_controller_I: entity work.mock_controller PORT MAP(
		clk,resetn,master_load_enable, opcode,e_flag,z_flag, -- inputs to controller
		
		decoEnable, decoSel, --outputs to controll bus
		pcSel,pcLd,  --  select adder for PC reg and load PC reg address
		imRead, --  select when to read Instruction memory
		dmRead,dmWrite, -- select when to read/write to Data memory
		aluOp,flagLd, -- select ALU operation, select look at flags
		accSel, -- select output from ALU or BUS
		accLd, dsLd); -- Enable ACC reg, Enable DS reg

addOrSub <= busOut(7);
	
	with busOut(7) SELECT
	add_inp <= NOT('0' & busOut(6 DOWNTO 0)) WHEN "1", -- Negerar detta hela talet bitvis ?
		  '0' & busOut(6 DOWNTO 0) WHEN "0",
	                        "ZZZZZZZZ" WHEN OTHERS; -- denna behövs nog inte


rca_jump: entity work.rca PORT MAP(pcOut,add_inp,addOrSub,C,jumpAddr); -- vad händer med carryin?
rca_pclncr: entity work.rca PORT MAP(pcOut,"00000001",'0',C,pclncrOut); -- vad händer med carryin?

with pcSel SELECT 
	nextPC <= pclncrOut WHEN "0"
		  jumpAddr  WHEN "1"
		 "ZZZZZZZZ" WHEN OTHERS;

reg_pc: entity work.reg PORT MAP(clk,,pcLd,nextPC,pcOut); -- vad händer restn?
pc2steg <= pcOut; -- dessa 2steg outputs, ska vi bara inputta värden?

mem_INS: entity work.memory 
generic map (DATA_WIDTH => 8;
             ADDR_WIDTH =>12;
             INIT_FILE => "i_memory_lab2.mif");) 
	     PORT MAP(clk,imRead,'0',pcOut,"00000000",imDataOut);

imDataOut2seg <= imDataOut;
opcode <= imDataOut(11 DOWNTO 8);

bus_THE: entity work.proc_bus PORT MAP(decoEnable,decoSel,imDataOut(7 DOWNTO 0),dmDataOut,accOut,extIn,busOut);

busOut2seg <= busOut

END Dataflow;