library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity cpu is
  generic (
            DATA_WIDTH : NATURAL := 32;
            PALAVRA_CONTROLE_WIDTH: NATURAL := 13; -- Num. dos pontos de controle
            OPCODE_WIDTH: NATURAL := 6
          );

  port (
         Clk       : in std_logic;
         saida_pc  : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Usado para testar funcionamento no waveform
         debug_reg : out std_logic_vector(DATA_WIDTH-1 downto 0);
         saida_ula : out std_logic_vector(DATA_WIDTH-1 downto 0) -- Usado para testar funcionamento no waveform
);
end entity;

architecture arch_name of cpu is
  -- Signals definidos aqui para poder ser usado tanto no FD quanto na UC.
  signal palavraControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0); -- Vem da UC [saida do UC / entrada do FD]
  signal opCode : std_logic_vector(OPCODE_WIDTH-1 downto 0); -- Vem do FD ( Rom ) [entrada do UC / saida do FD]

begin
  FD: entity work.fluxoDados port map (
                                        clk => Clk, pontosControle => palavraControle,
                                        opCode => opCode,
                                        debug_reg => debug_reg,
                                        saida_pc => saida_pc,
                                        saida_ula => saida_ula 
                                      );

  UC: entity work.unidadeControle port map (
                                             clk => Clk,
                                             opCode => opCode,
                                             palavraControle => palavraControle 
                                           );
end architecture;
