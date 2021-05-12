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
        -- Output ports
        estendeSinal_OUT: out std_logic_vector(larguraDadoSaida-1 downto 0)
    );
end entity;

architecture comportamento of estendeSinal is
begin
    process (estendeSinal_IN) is
    begin
            -- Substitui todos os bits estendidos pelo valor do 1o bit do sinal de entrada
            if (estendeSinal_IN(larguraDadoEntrada-1) = '1') then
                estendeSinal_OUT <= (larguraDadoSaida-1 downto larguraDadoEntrada => '1') & estendeSinal_IN;
            else
                estendeSinal_OUT <= (larguraDadoSaida-1 downto larguraDadoEntrada => '0') & estendeSinal_IN;
            end if;
    end process;
end architecture;