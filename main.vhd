library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity main is
  generic (
            DATA_WIDTH : NATURAL := 32;
            ADDR_WIDTH : NATURAL := 32;
            CONSTANTE_PC: NATURAL := 4;
            PALAVRA_CONTROLE_WIDTH: NATURAL := 6;
            REG_WIDTH: NATURAL := 5;
            LED_WIDTH: NATURAL := 8 -- 2⁸
          );

  port (
    Clk      : in std_logic
);
end entity;

architecture arch_name of main is
begin
  CPU: entity work.cpu port map (clk => Clk);
end architecture;
