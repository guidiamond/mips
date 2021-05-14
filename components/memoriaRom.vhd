library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaRom IS
   generic (
          dataWidth: natural := 32;
          addrWidth: natural := 32;
       memoryAddrWidth:  natural := 6 );   -- 64 posicoes de 32 bits cada
   port ( Endereco : IN  STD_LOGIC_VECTOR (addrWidth-1 DOWNTO 0);
          Dado     : OUT STD_LOGIC_VECTOR (dataWidth-1 DOWNTO 0) );
end entity;

architecture assincrona OF memoriaRom IS
  type blocoMemoria IS ARRAY(0 TO 2**memoryAddrWidth - 1) OF std_logic_vector(dataWidth-1 DOWNTO 0);

  -- signal memROM: blocoMemoria;
  -- attribute ram_init_file : string;
  -- attribute ram_init_file of memROM:
  -- signal is "ROMcontent.mif";
  FUNCTION initMemory
    RETURN blocoMemoria IS VARIABLE tmp : blocoMemoria := (OTHERS => (OTHERS => '0'));
  BEGIN
    -- op|rs|rt|endereco
    -- lw  $rt,  imediato($rs);
    -- R[rt] = M[R[rs]+extSinal(imediato)]
    tmp(0) := x"02324022"; -- sub $t0, $s1, $s2  s1 = 2FD s2 = FD 
    tmp(1) := x"01004020"; -- add $t0, $t0, $0
    tmp(2) := x"02324020"; -- add $t0, $s1, $s2
    tmp(3) := x"01004020"; -- add $t0, $t0, $0
    tmp(4) := x"8FA80048"; -- lw  $t0,  0x48($sp)  bin: 10001111101010000000000001001000
	  tmp(5) := x"AFA90004"; -- sw  $t1,  4($sp)     bin: 10101111101010010000000000000100
	  tmp(6) := x"11090500"; -- beq  $t0, $t1, 0x500 bin: 00010001000010010000010100000000
    tmp(7) := x"80000010"; -- INICIO: j INICIO; -- bin: 00001000000000000000000000010000
    -- 
    RETURN tmp;
  END initMemory;

  SIGNAL memROM : blocoMemoria := initMemory;

-- Utiliza uma quantidade menor de endereços locais:
   signal EnderecoLocal : std_logic_vector(memoryAddrWidth-1 downto 0);

begin
  EnderecoLocal <= Endereco(memoryAddrWidth+1 downto 2);
  Dado <= memROM (to_integer(unsigned(EnderecoLocal)));
end architecture;

