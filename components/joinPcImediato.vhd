library ieee;
use ieee.std_logic_1164.all;

entity joinPcImediato is
	generic ( 
        IMEDIATO_WIDTH   : natural := 26;
        ADDR_WIDTH : natural := 32
	);
	port (
        imediato  : in std_logic_vector((IMEDIATO_WIDTH-1) downto 0);
        PC   : in std_logic_vector(3 downto 0);
        saida : out std_logic_vector((ADDR_WIDTH-1) downto 0)
	);
end entity;

architecture rtl of joinPcImediato is
	begin
        saida <= PC & imediato & "00";
end architecture;

