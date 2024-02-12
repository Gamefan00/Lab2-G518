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

COMPONENT proc_controller
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

COMPONENT alu_wRCA
    port(
        alu_inA, alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end COMPONENT;

--Adders
SIGNAL pclncrOut:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL jumpAddr:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL add_inp:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL addOrSub:std_logic;

--PC_Reg
SIGNAL nextPC:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL pcSel:std_logic;
SIGNAL pcLd:std_logic;
SIGNAL pcOut:STD_LOGIC_VECTOR(7 downto 0);

-- Instruction Memory
SIGNAL imRead:std_logic;
SIGNAL imDataOut:STD_LOGIC_VECTOR(11 downto 0);
SIGNAL opcode:STD_LOGIC_VECTOR(3 downto 0);

-- Bus
SIGNAL decoEnable:std_logic;
SIGNAL decoSel:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL busOut:STD_LOGIC_VECTOR(7 downto 0);

-- Data Memory
SIGNAL dmRead:std_logic;
SIGNAL dmWrite:std_logic;
SIGNAL dmDataOut:STD_LOGIC_VECTOR(7 downto 0);

-- ALU
SIGNAL aluOp:STD_LOGIC_VECTOR(1 downto 0);
SIGNAL alu_out:STD_LOGIC_VECTOR(7 downto 0);
SIGNAL flagLd:std_logic;
SIGNAL C:std_logic;
SIGNAL E:std_logic;
SIGNAL Z:std_logic;
SIGNAL flag_in:STD_LOGIC_VECTOR(2 downto 0);
SIGNAL flag_out:STD_LOGIC_VECTOR(2 downto 0);

SIGNAL e_flag:std_logic;
SIGNAL z_flag:std_logic;

-- Mux ALU to ACC
SIGNAL accSel:std_logic;
SIGNAL accSel_out:STD_LOGIC_VECTOR(7 downto 0);

-- ACC
SIGNAL accLd:std_logic;
SIGNAL accOut:STD_LOGIC_VECTOR(7 downto 0);

-- DS
SIGNAL dsLd:std_logic;

BEGIN

mock_cont: entity work.proc_controller PORT MAP(
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
	add_inp <= NOT('0' & busOut(6 DOWNTO 0)) WHEN '1', -- Negerar detta hela talet bitvis ?
		        '0' & busOut(6 DOWNTO 0) WHEN '0',
	                              "ZZZZZZZZ" WHEN OTHERS; -- denna behövs nog inte


rca_jump: entity work.rca PORT MAP(pcOut,add_inp,addOrSub,open,jumpAddr); -- vad händer med carryin?
rca_pclncr: entity work.rca PORT MAP(pcOut,"00000001",'0',open,pclncrOut); -- vad händer med carryin?
--(1 => '1', OTHERS)
with pcSel SELECT 
	nextPC <= pclncrOut WHEN '0',
		  jumpAddr  WHEN '1',
		 "ZZZZZZZZ" WHEN OTHERS;

reg_pc: entity work.reg PORT MAP(clk,resetn,pcLd,nextPC,pcOut); -- vad händer restn?
pc2seg <= pcOut; -- dessa 2steg outputs, ska vi bara inputta värden?

mem_INS: entity work.memory 
generic map (DATA_WIDTH =>12,
             ADDR_WIDTH =>8,
             INIT_FILE => "i_memory_lab3.mif") 
	     PORT MAP(clk,imRead,'0',pcOut,"000000000000",imDataOut);

imDataOut2seg <= imDataOut;
opcode <= imDataOut(11 DOWNTO 8);

bus_THE: entity work.proc_bus PORT MAP(decoEnable,decoSel,imDataOut(7 DOWNTO 0),dmDataOut,accOut,extIn,busOut);
busOut2seg <= busOut;

mem_DAT: entity work.memory PORT MAP(clk,dmRead,dmWrite,busOut,accOut,dmDataOut);
dmDataOut2seg <= dmDataOut;

ALU: entity work.alu_wRCA PORT MAP(accOut,busOut,aluOp,alu_out,C,E,Z);
aluOut2seg <= alu_out;

--flag <= E&C&Z WHEN flagLd = '1' ELSE "ZZZ"; -- spara E C Z som variabler? Skapar latches typ som bilden?
--e_flag <= flag(2);
--z_flag <= flag(0);
flag_in <= E&C&Z;

flag_reg: entity work.reg generic map (width => 3) PORT MAP(clk,resetn,flagLd,flag_in,flag_out);
e_flag <= flag_out(2);
z_flag <= flag_out(0);

with accSel SELECT 
	accSel_out <= alu_out WHEN '0',
		      busOut  WHEN '1',
		   "ZZZZZZZZ" WHEN OTHERS;

acc_reg: entity work.reg PORT MAP(clk,resetn,accLd,accSel_out,accOut); -- vad händer restn?
acc2seg <= accOut;

ds_reg: entity work.reg PORT MAP(clk,resetn,dsLd,accOut,ds2seg); -- vad händer restn?

END Dataflow;