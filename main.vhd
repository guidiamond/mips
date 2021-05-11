library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity main is
  generic (
            DATA_WIDTH : NATURAL := 32;
            ADDR_WIDTH : NATURAL := 32;
            CONSTANTE_PC: NATURAL := 4;
            PALAVRA_CONTROLE_WIDTH: NATURAL := 6;
            REG_WIDTH: NATURAL := 5
          );

  port
  (
      -- Input ports
    Clk : in std_logic;
	  ULAout: out std_logic_vector(DATA_WIDTH-1 downto 0);
	  PCout: out std_logic_vector(ADDR_WIDTH-1 downto 0)
);
end entity;

architecture arch_name of main is
  signal saidaPC, saidaSomaUm : std_logic_vector(ADDR_WIDTH-1 downto 0);

  -- signal flagZero : std_logic; -- Ocorre se EntradaUlaA == EntradaUlaB 
  signal instrucaoRom : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal saidaRegA : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaRegB : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Instrucao alias
  alias opCode   : std_logic_vector(5 downto 0) is instrucaoRom(ADDR_WIDTH-1 downto 26);
  alias imediatoRs : std_logic_vector(REG_WIDTH-1 downto 0) is instrucaoRom(25 downto 21);
  alias imediatoRt : std_logic_vector(REG_WIDTH-1 downto 0) is instrucaoRom(20 downto 16);
  alias imediato   : std_logic_vector(15 downto 0) is instrucaoRom(15 downto 0);

  -- Saida estende sinal
  signal imediatoEstendido   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal enderecoRam   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaRam   : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal palavraControle : std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0);


begin

  PC: entity work.registradorGenerico generic map (larguraDados => ADDR_WIDTH)
    port map (DIN => saidaSomaUm, DOUT => saidaPC, ENABLE => '1', CLK =>  clk, RST => '0');

  SomaConstante: entity work.somaConstante generic map (larguraDados => ADDR_WIDTH, constante => CONSTANTE_PC)
    port map(entrada => saidaPC, saida => saidaSomaUm);

  ROM: entity work.memoriaRom
    port map(Endereco => SaidaPC, Dado => instrucaoRom);

  UC: entity work.unidadeControle port map (clk => Clk, opCode => opCode, palavraControle => palavraControle);

  BancoRegistradores: entity work.bancoRegistradores generic map (larguraDados => DATA_WIDTH, larguraEndBancoRegs => 5)
    port map (
              clk => Clk,
              enderecoA => imediatoRs,
              enderecoB => imediatoRt,
              enderecoC => imediatoRt,
              dadoEscritaC => saidaRam,
              escreveC => palavraControle(0), -- UC
              saidaA => saidaRegA,
              saidaB => saidaRegB
            );

    EstendeSinal: entity work.estendeSinal generic map (larguraDadoEntrada => 16 , larguraDadoSaida => DATA_WIDTH)
      port map ( estendeSinal_IN => imediato, estendeSinal_OUT => imediatoEstendido);

    MemoriaRam: entity work.memoriaRam
    port map (
              clk      => Clk,
              Endereco => enderecoRam,
              Dado_in  => saidaRegB,
              Dado_out => saidaRam,
              we => palavraControle(4),
              re => palavraControle(5)
              );

  ULA: entity work.ULA generic map (larguraDados => DATA_WIDTH)
    port map (
               entradaA => saidaRegA,
               entradaB => imediatoEstendido,
               seletor => palavraControle(3 downto 1), -- UC
               saida => enderecoRam
               -- flagZero => flagZero
             ); 
  ULAout <= enderecoRam;
  PCout <= saidaPC;
  
end architecture;
