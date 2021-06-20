library ieee;
use ieee.std_logic_1164.all;

entity estendeSinal is
    generic
    (
        larguraDadoEntrada : natural  :=    8;
        larguraDadoSaida   : natural  :=    8
    );
    port
    (
        -- Input ports
        estendeSinal_IN : in  std_logic_vector(larguraDadoEntrada-1 downto 0);
		  seletor: in std_logic_vector(1 downto 0);
        -- Output ports
        estendeSinal_OUT: out std_logic_vector(larguraDadoSaida-1 downto 0)
    );
end entity;

architecture comportamento of estendeSinal is
begin
    
        estendeSinal_OUT <= 
            (larguraDadoSaida-1 downto larguraDadoEntrada => '1') & estendeSinal_IN when seletor = "00" and (estendeSinal_IN(larguraDadoEntrada-1) = '1') else
            (larguraDadoSaida-1 downto larguraDadoEntrada => '0') & estendeSinal_IN when seletor = "00" and (estendeSinal_IN(larguraDadoEntrada-1) = '0') else
            estendeSinal_IN & x"0000" when seletor = "01" else
            x"0000" & estendeSinal_IN when seletor = "10" else
            x"00000000"; -- ORI
  
end architecture;

