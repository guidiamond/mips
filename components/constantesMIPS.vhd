library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package constantesMIPS is

--  Exemplos:
--  signal Instruction : Bit_Vector(15 downto 0);
--  alias OpCode : Bit_Vector(3 downto 0) is Instruction(15 downto 12);
--  subtype TypeWord is unsigned( 31 downto 0 );
--  type    TypeArrayWord is array (natural range <>) of unsigned( 31 downto 0 );
--  constant FUNCT_WIDTH : natural := 6;

    constant FUNCT_WIDTH    : natural := 6;
    constant OPCODE_WIDTH   : natural := 6;
    constant DATA_WIDTH     : natural := 32;
    constant ADDR_WIDTH     : natural := 32;
    constant REGBANK_ADDR_WIDTH : natural := 5;
    constant ALU_OP_WIDTH   : natural := 2;
    constant CTRL_ALU_WIDTH : natural := 3;
    constant CONTROLWORD_WIDTH : natural := 10;

-- codigos das instrucoes do DLX:
    subtype opCode_t       is std_logic_vector(OPCODE_WIDTH-1 downto 0);
    subtype funct_t        is std_logic_vector(FUNCT_WIDTH-1 downto 0);
    subtype ctrlWorld_t    is std_logic_vector(CONTROLWORD_WIDTH-1 downto 0);
    subtype aluOp_t        is std_logic_vector(ALU_OP_WIDTH-1 downto 0);
    subtype ctrlALU_t      is std_logic_vector(CTRL_ALU_WIDTH-1 downto 0);

    subtype dado_t         is std_logic_vector(DATA_WIDTH-1 downto 0);
    subtype addr_t         is std_logic_vector(ADDR_WIDTH-1 downto 0);
--
    constant functADD   : funct_t := "100000";
    constant functSUB   : funct_t := "100010";
    constant functAND   : funct_t := "100100";
    constant functOR    : funct_t := "100101";
    constant functSLT   : funct_t := "101010";

    constant opCodeTipoR  : opCode_t := "000000";
--
    constant opCodeLW     : opCode_t := "100011";
    constant opCodeSW     : opCode_t := "101011";
    constant opCodeBEQ    : opCode_t := "000100";
--
    constant opCodeTipoJ  : opCode_t := "000010";

--
-- Codigos da palavra de controle:
--  alias memWRsignal: std_logic is controlWord(0);
--  alias memRDsignal: std_logic is controlWord(1);
--  alias beqSignal:   std_logic is controlWord(2);
--  alias muxUlaMem:   std_logic is controlWord(3);
--  alias ulaOPvalue:  std_logic_vector(1 downto 0) is controlWord(5 downto 4);
--  alias muxRtImed:   std_logic is controlWord(6);
--  alias regcWRsignal:std_logic is controlWord(7);
--  alias muxRtRd:     std_logic is controlWord(8);
--  alias muxPcBeqJ:   std_logic is controlWord(9);
--
-- ControlWorld Bit:    9   8       7           6     5,4    3     2      1       0
--Instrução  Opcode    Mux1 Mux2 HabEscritaReg Mux3  ULAOp  Mux4  BEQ HabLeMEM HabEscME
--Tipo R    |00.0000  | 0 |  1 |     1        |  0  |  10  |  0  | 0 |    0   |    0    |
--LW        |10.0011  | 0 |  0 |     1        |  1  |  00  |  1  | 0 |    1   |    0    |
--SW        |10.1011  | 0 |  0 |     0        |  1  |  00  |  0  | 0 |    0   |    1    |
--BEQ       |00.0100  | 0 |  0 |     0        |  0  |  01  |  0  | 1 |    0   |    0    |
--J         |00.0010  | 1 |  X |     0        |  X  |  XX  |  X  | X |    0   |    0    |

--  Mux1: mux([PC+4, BEQ]/J);  Mux2: mux(Rt/Rd); Mux3: mux(Rt/imediato);  Mux4: mux(ULA/mem).

    constant ctrlTipoR:       ctrlWorld_t := "0110100000";
    constant ctrlTipoJ:       ctrlWorld_t := "1X0XXXXX00";
    constant ctrlTipoLW:      ctrlWorld_t := "0011001010";
    constant ctrlTipoSW:      ctrlWorld_t := "0001000001";
    constant ctrlTipoBEQ:     ctrlWorld_t := "0000010100";
    constant ctrlZERO:        ctrlWorld_t := "0000000000";

--  -- ULA ---
    subtype operacaoULA_t is std_logic_vector(2 downto 0);

    constant execAndULA : operacaoULA_t := "000";
    constant execOrULA  : operacaoULA_t := "001";
    constant execAddULA : operacaoULA_t := "010";
    constant execSubULA : operacaoULA_t := "110";
    constant execSltULA : operacaoULA_t := "111";
end package constantesMIPS;
