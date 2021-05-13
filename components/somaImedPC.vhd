library ieee;
use ieee.std_logic_1164.all;

entity somaImedPC is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 32);
  port (
    PC, imExtShift: in std_logic_vector(larguraDados-1 downto 0);
    saida : out std_logic_vector(larguraDados-1 downto 0)
  );
end entity;

architecture comportamento of somaImedPC is
  begin
    saida <= PC + imExtShift;
end architecture;
