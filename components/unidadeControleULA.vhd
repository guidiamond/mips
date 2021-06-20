library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidadeControleULA is
  generic (
            FUNCT_WIDTH: natural := 6;
            ULA_CTRL_WIDTH: natural := 4;
            ULA_OP_WIDTH: natural := 2
          );
  port (
         -- Input ports
         funct    : in std_logic_vector(FUNCT_WIDTH-1 downto 0);
         ulaOP    : in std_logic_vector(ULA_OP_WIDTH-1 downto 0);
         clk      :  in  std_logic;
         -- Output ports
         ulaCtrl  :  out std_logic_vector(ULA_CTRL_WIDTH-1 downto 0)
       );
end entity;

architecture arch_name of unidadeControleULA is
  -- ULA OP
  constant r_inst   : std_logic_vector := "10"; -- Funct define operação
  constant add_inst : std_logic_vector := "00";
  constant sub_inst : std_logic_vector := "01";

  -- Funct (Instruções tipo R)
  constant add_funct : std_logic_vector := "100000"; --20
  constant sub_funct : std_logic_vector := "100010"; --22
  constant and_funct : std_logic_vector := "100100"; --24
  constant or_funct  : std_logic_vector := "100101"; --25
  constant slt_funct : std_logic_vector := "101010"; --2a
  constant ori_funct : std_logic_vector := "001101"; --d

  begin

    ulaCtrl <= "0010" when (ulaOP=r_inst and funct = add_funct) else -- add
               "0110" when (ulaOP=r_inst and funct = sub_funct) else -- sub
               "0000" when (ulaOP=r_inst and funct = and_funct) else -- and
               "0001" when (ulaOP=r_inst and funct = or_funct) else -- or
               "0111" when (ulaOP=r_inst and funct = slt_funct) else -- slt
               "0010" when (ulaOP=add_inst) else -- lw, sw
               "0110" when (ulaOP=sub_inst) else -- beq
               "0000";

end architecture;
