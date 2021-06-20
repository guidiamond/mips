library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidadeControle is
  generic (
            PALAVRA_CONTROLE_WIDTH : natural := 13;
            OPCODE_WIDTH           : natural := 6
          );
  port (
         -- Input ports
         clk             :  in  std_logic;
         opCode          :  in  std_logic_vector(OPCODE_WIDTH-1 downto 0);
         -- Output ports
         palavraControle :  out std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0)
       );
end entity;

architecture arch_name of unidadeControle is
  signal pontosControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0);

  -- Output alias (mais facil de atribuir os valores)
  alias mux_PcBeq_J   : std_logic is pontosControle(0);
  alias mux_rt_rd     : std_logic is pontosControle(1);
  alias habEscritaReg : std_logic is pontosControle(2);
  alias mux_rt_imed   : std_logic is pontosControle(3);
  alias mux_ula_mem_imed   : std_logic_vector is pontosControle(5 downto 4);
  alias beqUC         : std_logic is pontosControle(6);
  alias habLeituraRam : std_logic is pontosControle(7);
  alias habEscritaRam : std_logic is pontosControle(8);
  alias ulaOP         : std_logic_vector(1 downto 0) is pontosControle(10 downto 9);
  alias extSig        : std_logic_vector(1 downto 0) is pontosControle(12 downto 11);

  -- INSTRUCTIONS
  constant instrucaoR : std_logic_vector := "000000"; -- Funct define operação
  constant instrucaoJ : std_logic_vector := "000010";

  -- INSTRUCTIONS (Tipo I)
  constant lw       : std_logic_vector := "100011";
  constant sw       : std_logic_vector := "101011";
  constant beqInst  : std_logic_vector := "000100";
  constant ori      : std_logic_vector := "001111";
  constant lui      : std_logic_vector := "001101";

  begin
    mux_PcBeq_J <= '1' when opCode = instrucaoJ else '0';

    mux_rt_rd <= '1' when opCode = instrucaoR;

    habEscritaReg <= '1' when (opCode = instrucaoR or opCode = lw or opCode = ori or opCode = lui) else '0';

    mux_rt_imed <= '1' when (opCode = lw or opCode = sw or opCode = ori or opCode = lui) else '0';

    mux_ula_mem_imed <= "01" when opCode = lw else
                        "10" when opCode = lui else "00";

    beqUC <= '1' when opCode = beqInst else '0';

    habLeituraRam <= '1' when opCode = lw else '0';

    habEscritaRam <= '1' when opCode = sw else '0';

    ulaOP <= "10" when opCode = instrucaoR else
             "01" when opCode = beqInst else
             "11" when opCode = ori else
             "00";

    extSig <= "01" when opCode = lui else 
              "10" when opCode = ori else
              "00";


    -- Assign resultado final para output
    palavraControle <= pontosControle;

end architecture;

