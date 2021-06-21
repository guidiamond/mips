library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity main is
  generic (
            DATA_WIDTH : NATURAL := 32
          );

  port (
         CLOCK_50       : in std_logic;
         KEY            : in std_logic_vector(3 downto 0);
         HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

         LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)

);
end entity;

architecture arch_name of main is
  
  signal clk        : std_logic;
  signal saida_pc   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saida_ula  : std_logic_vector(DATA_WIDTH-1 downto 0);


begin
  -- Cpu criada como componente separado para facilitar/dividir implementação com periféricos externos (hex, botões, etc)
  CPU: entity work.cpu port map ( clk => clk, saida_pc => saida_pc, saida_ula => saida_ula );

  EDGE : work.edgeDetector(bordaSubida)
  PORT MAP(
            clk => CLOCK_50,
            entrada => (NOT KEY(0)),
            saida => clk
          );


  LEDR(3 downto 0) <= KEY(3 downto 0);

  DISP0 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_pc(3 DOWNTO 0),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX0
          );

  DISP1 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_pc(7 DOWNTO 4),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX1
          );

  DISP2 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_ula(3 downto 0),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX2
          );

  DISP3 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_ula(7 downto 4),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX3
          );

  DISP4 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_ula(11 downto 8),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX4
          );

  DISP5 : ENTITY work.conversorHex7Seg
  PORT MAP(
            dadoHex => saida_ula(15 downto 12),
            apaga => '0',
            negativo => '0',
            overFlow => '0',
            saida7seg => HEX5
          );
  

end architecture;
