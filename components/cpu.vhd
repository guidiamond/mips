library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity cpu is
  generic (
            DATA_WIDTH : NATURAL := 32;
            PALAVRA_CONTROLE_WIDTH: NATURAL := 10;
            OPCODE_WIDTH: NATURAL := 6
          );

  port (
    Clk      : in std_logic;
    saida_pc  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    saida_ula : out std_logic_vector(DATA_WIDTH-1 downto 0);
  -- Debug
    flag_zero_debug : out std_logic;
    Ula_ctl_debug : out std_logic_vector(3 downto 0);
    ula_op_debug : out std_logic_vector(1 downto 0); 
    entradaA_debug: out std_logic_vector(DATA_WIDTH-1 downto 0);
    entradaB_debug: out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end entity;

architecture arch_name of cpu is
  signal palavraControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0);
  signal opCode : std_logic_vector(OPCODE_WIDTH-1 downto 0);
begin
    FD: entity work.fluxoDados port map ( clk => Clk, pontosControle => palavraControle, opCode => opCode, saida_pc => saida_pc, saida_ula => saida_ula, flag_zero_debug => flag_zero_debug, Ula_ctl_debug => Ula_ctl_debug, entradaA_debug => entradaA_debug, entradaB_debug => entradaB_debug, ula_op_debug => ula_op_debug );
    UC: entity work.unidadeControle port map ( clk => Clk, opCode => opCode, palavraControle => palavraControle );
end architecture;
