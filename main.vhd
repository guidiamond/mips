library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity main is
  generic (
            DATA_WIDTH : NATURAL := 32
          );

  port (
         Clk       : in std_logic;
         saida_pc  : out std_logic_vector(DATA_WIDTH-1 downto 0);
         debug_reg : out std_logic_vector(DATA_WIDTH-1 downto 0);
         saida_ula : out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end entity;

architecture arch_name of main is

begin
  -- Cpu criada como componente separado para facilitar/dividir implementação com periféricos externos (hex, botões, etc)
  CPU: entity work.cpu port map ( clk => Clk, saida_pc => saida_pc, saida_ula => saida_ula, debug_reg => debug_reg );
end architecture;
