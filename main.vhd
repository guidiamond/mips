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
    Clk      : in std_logic;
    saida_pc : out std_logic_vector(DATA_WIDTH-1 downto 0);
    saida_ula :out std_logic_vector(DATA_WIDTH-1 downto 0);
  -- Debug
    flag_zero_debug : out std_logic;
    Ula_ctl_debug : out std_logic_vector(3 downto 0);
    ula_op_debug : out std_logic_vector(1 downto 0); 
    entradaA_debug: out std_logic_vector(DATA_WIDTH-1 downto 0);
    entradaB_debug: out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end entity;

architecture arch_name of main is

begin
  CPU: entity work.cpu port map (clk => Clk, saida_pc => saida_pc, saida_ula => saida_ula, flag_zero_debug => flag_zero_debug, Ula_ctl_debug => Ula_ctl_debug, entradaA_debug => entradaA_debug, entradaB_debug => entradaB_debug, ula_op_debug => ula_op_debug);
end architecture;
