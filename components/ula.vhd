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
      seletor:  in STD_LOGIC_VECTOR(3 downto 0);
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      flagZero: out std_logic
    );
end entity;

architecture comportamento of ULA is
  constant zero : std_logic_vector(larguraDados-1 downto 0) := (others => '0');

  signal op_add, op_sub, op_or, op_and, op_slt : std_logic_vector(larguraDados-1 downto 0);
  signal overflow : std_logic;
  signal temp_output : std_logic_vector(larguraDados-1 downto 0);


  constant add_ctl : std_logic_vector := "0010";
  constant sub_ctl : std_logic_vector := "0110";
  constant and_ctl : std_logic_vector := "0000";
  constant or_ctl  : std_logic_vector := "0001";
  constant slt_ctl : std_logic_vector := "0111";
  constant lui_ctl : std_logic_vector := "1000";

begin
  op_add <= std_logic_vector(signed(entradaA) + signed(entradaB));
  op_sub <= std_logic_vector(signed(entradaA) + (not (signed(entradaB))) + 1);
  op_or  <= entradaA or entradaB;
  op_and <= entradaA and entradaB;
  op_slt <= (0 => op_sub(larguraDados - 1) xor overflow, OTHERS => '0');

  temp_output <= op_add when (seletor = add_ctl) else
		op_sub when (seletor = sub_ctl) else
		op_and when (seletor = and_ctl) else
		op_or when (seletor = or_ctl) else
		op_slt when (seletor = slt_ctl) else
		entradaB when (seletor = lui_ctl) else
		entradaA; 

  flagZero <= '1' when unsigned(saida) = unsigned(zero) else '0';
  overflow <= (not(entradaA(larguraDados - 1)) and not(entradaB(larguraDados - 1)) and temp_output(larguraDados - 1))
		or (entradaA(larguraDados - 1) and entradaB(larguraDados - 1) and not(temp_output(larguraDados - 1)));

  saida <= temp_output;

end architecture;
