library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidadeControle is
  generic (
            OPCODE_WIDTH: natural := 6;
            PALAVRA_CONTROLE_WIDTH: natural := 10
          );
  port (
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
  alias mux_PcBeq_J   : std_logic is pontosControle(0);
  alias mux_rt_rd     : std_logic is pontosControle(1);
  alias habEscritaReg : std_logic is pontosControle(2);
  alias mux_rt_imed   : std_logic is pontosControle(3);
  alias mux_ula_mem   : std_logic is pontosControle(4);
  alias beqUC         : std_logic is pontosControle(5);
  alias habLeituraRam : std_logic is pontosControle(6);
  alias habEscritaRam  : std_logic is pontosControle(7);
  alias ulaOP         : std_logic_vector(1 downto 0) is pontosControle(9 downto 8);

  -- INSTRUCTIONS
  constant instrucaoR : std_logic_vector := "000000"; -- Funct define operação
  constant instrucaoJ : std_logic_vector := "000010";
  -- Tipo I
  constant lw   : std_logic_vector := "100011";
  constant sw   : std_logic_vector := "101011";
  constant beq  : std_logic_vector := "000100";

  begin
    mux_PcBeq_J <= '1' when opCode = instrucaoJ else '0';

    mux_rt_rd <= '1' when opCode = instrucaoR;

    habEscritaReg <= '1' when (opCode = instrucaoR or opCode = lw) else '0';

    mux_rt_imed <= '1' when (opCode = lw or opCode = sw) else '0';

    mux_ula_mem <= '1' when opCode = lw else '0';

    beqUC <= '1' when opCode = beq else '0';

    habLeituraRam <= '1' when opCode = lw else '0';

    habEscritaRam <= '1' when opCode = sw else '0';

    ulaOP <= "10" when opCode = instrucaoR else
             "01" when opCode = beq else
             "00";

    -- Assign resultado final para output
    palavraControle <= pontosControle;

end architecture;

