library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULA is
    generic
    (
        larguraDados : natural := 8
    );
    port
    (
      entradaA, entradaB:  in STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      seletor:  in STD_LOGIC_VECTOR(2 downto 0);
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      flagZero: out std_logic
    );
end entity;

architecture comportamento of ULA is
  constant zero : std_logic_vector(larguraDados-1 downto 0) := (others => '0');

   signal soma :      STD_LOGIC_VECTOR((larguraDados-1) downto 0);
   signal subtracao : STD_LOGIC_VECTOR((larguraDados-1) downto 0);

    begin
      soma      <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
      subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));

      saida <= soma when (seletor = "000") else
          subtracao when (seletor = "001") else
          entradaA when  (seletor = "010") else
          entradaB when  (seletor = "011") else
          entradaA;      -- outra opcao: saida = entradaA

      flagZero <= '1' when unsigned(saida) = unsigned(zero) else '0';

end architecture;
