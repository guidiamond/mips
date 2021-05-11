-- 100011 (lw)
-- 101011 (sw)
-- 000100 (beq)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidadeControle is
  generic (
              OPCODE_WIDTH: natural := 6;
              PALAVRA_CONTROLE_WIDTH: natural := 5
  );
  port   (
    -- Input ports
    clk  :  in  std_logic;
    opCode  :  in  std_logic_vector(OPCODE_WIDTH-1 downto 0);
    -- Output ports
    palavraControle  :  out std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0)
  );
end entity;


architecture arch_name of unidadeControle is
  signal pontosControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0);

  -- Output alias (mais facil de atribuir os valores)
  alias habEscritaReg : std_logic is pontosControle(0);
  alias selOperacaoULA : std_logic_vector(2 downto 0) is pontosControle(3 downto 1);
  alias habEscritRam : std_logic is pontosControle(4);

  -- INSTRUCTIONS
  constant lw : std_logic_vector := "100011";
  constant sw  : std_logic_vector := "101011";
  constant beq   : std_logic_vector := "000100";

  begin
      habEscritaReg <= '1' when opCode = lw else '0';

    selOperacaoULA <= "000" when opCode = lw or opCode = sw else
                   "000";

    habEscritRam <= '1' when opCode = sw else '0';


    -- Assign resultado final para output
    palavraControle <= pontosControle;

end architecture;

