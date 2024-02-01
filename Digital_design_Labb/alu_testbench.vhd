library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

library work;
use work.chacc_pkg.all;


-- 2023-01-24 With zero-flag fix

entity alu_testbench is
end alu_testbench;

architecture BEHAVIORAL of alu_testbench is

    -----------------------------------------------------------------------------
    -- Declarations
    -----------------------------------------------------------------------------

    constant Size : integer := 199;
    type Operand_array is array (Size downto 0) of std_logic_vector(7 downto 0);
    type OpCode_array is array (Size downto 0) of std_logic_vector(1 downto 0);

    -----------------------------------------------------------------------------
    -- Functions
    -----------------------------------------------------------------------------
    function bin(
        myChar : character)
    return std_logic is
        variable bin : std_logic;
    begin
        case myChar is
            when '0'    => bin := '0';
            when '1'    => bin := '1';
            when 'x'    => bin := '0';
            when others => assert (false) report "no binary character read" severity failure;
        end case;
        return bin;
    end bin;

    impure function loadOperand(
        fileName : string)
    return Operand_array is
        file objectFile : text open read_mode is fileName;
        variable memory : Operand_array;
        variable L      : line;
        variable index  : natural := 0;
        variable myChar : character;
    begin
        while not endfile(objectFile) loop
            readline(objectFile, L);
            for i in 7 downto 0 loop
                read(L, myChar);
                memory(index)(i) := bin(myChar);
            end loop;
            index := index + 1;
        end loop;
        return memory;
    end loadOperand;

    impure function loadOpCode(
        fileName : string)
    return OpCode_array is
        file objectFile : text open read_mode is fileName;
        variable memory : OpCode_array;
        variable L      : line;
        variable index  : natural := 0;
        variable myChar : character;
    begin
        while not endfile(objectFile) loop
            readline(objectFile, L);
            for i in 1 downto 0 loop
                read(L, myChar);
                memory(index)(i) := bin(myChar);
            end loop;
            index := index + 1;
        end loop;
        return memory;
    end loadOpCode;

    component ALU_WRCA is
    Port(ALU_inA : in  STD_LOGIC_VECTOR(7 downto 0);
         ALU_inB : in  STD_LOGIC_VECTOR(7 downto 0);
         ALU_op  : in  STD_LOGIC_VECTOR(1 downto 0);
         ALU_out : out STD_LOGIC_VECTOR(7 downto 0);
         C       : out STD_LOGIC;
         E       : out STD_LOGIC;
         Z       : out STD_LOGIC
        );
    end component alu_wRCA;

    signal AMem  : Operand_array := (others => (others => '0'));
    signal BMem  : Operand_array := (others => (others => '0'));
    signal OpMem : OpCode_array  := (others => (others => '0'));

    signal op_a, op_b, op_out, exp_op_out : std_logic_vector(7 downto 0);
    signal opcode                         : std_logic_vector(1 downto 0);

    signal Carry, Eq, isOutZero : std_logic;
    
    signal exp_carry, exp_eq, exp_zero: std_logic;
    signal flags_correct : boolean;

    signal vec_count : std_logic_vector(7 downto 0) := "00000000";

begin

    AMem  <= loadOperand(string'("A_mod_FINAL.tv"));
    BMem  <= loadOperand(string'("B_mod_FINAL.tv"));
    OpMem <= loadOpCode(string'("Op_mod_FINAL.tv"));

    test_inst : alu_wRCA port map(op_a, op_b, opcode, op_out, Carry, Eq, isOutZero);

    with opcode select exp_op_out <=
        op_a + op_b when A_ADD,
        op_a - op_b when A_SUB,
        op_a and op_b when A_AND,
        op_a rol 1 when A_ROL,
        "01000100" when others;
    
    exp_carry <= '1' when (to_integer(unsigned(op_a)) + to_integer(unsigned(op_b)) > 255) else '0';
    exp_eq <= '1' when op_a = op_b else '0';
    exp_zero <= '1' when exp_op_out = 0 else '0';

    flags_correct <= exp_eq = Eq and exp_zero = isOutZero and (exp_carry = Carry or opcode /= A_ADD);

    process
        variable i, final : integer := 0;
    begin
        wait for 10 ns;
        while_loop : while i < Size loop
            -- set operands and opcode
            op_a   <= AMem(i);
            op_b   <= BMem(i);
            opcode <= OpMem(i);
            
            wait for 5 ns;
            assert (exp_op_out = op_out and flags_correct) report "Test failed" severity failure; --assert if unexpected output
            wait for 5 ns;
            i := i + 1;                 -- Goto next test vector
        end loop while_loop;

        report "Test passed";
        assert (false) report "Simulation Ended" severity failure;

    end process;

end BEHAVIORAL;
