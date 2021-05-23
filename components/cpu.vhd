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
    Clk      : in std_logic
);
end entity;

architecture arch_name of cpu is
  signal palavraControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0);
  signal opCode : std_logic_vector(OPCODE_WIDTH-1 downto 0);
begin
    FD: entity work.fluxoDados port map ( clk => Clk, pontosControle => palavraControle, opCode => opCode );
    UC: entity work.unidadeControle port map ( clk => Clk, opCode => opCode, palavraControle => palavraControle );
end architecture;
