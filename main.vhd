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

  port
  (
    Clk      : in std_logic;
    SW       : in  std_logic_vector(7 downto 0);
    BUT      : in  std_logic_vector(3 downto 0);
    -- Monitora PC
    LED      : out  std_logic_vector(LED_WIDTH-1 downto 0);
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5      : out std_logic_vector(6 downto 0)
);
end entity;

architecture arch_name of main is
  signal saidaPC, saidaSomaUm : std_logic_vector(ADDR_WIDTH-1 downto 0);

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

  -- BUT
  signal auxReset, auxClk : std_logic;

  -- Display Output (from Mux)
  signal displayOut : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Signal flagzero
  signal flagZero : std_logic;


begin

  PC: entity work.registradorGenerico generic map (larguraDados => ADDR_WIDTH)
    port map (DIN => saidaSomaUm, DOUT => saidaPC, ENABLE => '1', CLK => auxClk, RST => auxReset);

  detectorSub0: work.edgeDetector(bordaSubida) port map (clk => Clk, entrada => (not BUT(0)), saida => auxReset);
  detectorSub1: work.edgeDetector(bordaSubida) port map (clk => Clk, entrada => (not BUT(1)), saida => auxClk);

  SomaConstante: entity work.somaConstante generic map (larguraDados => ADDR_WIDTH, constante => CONSTANTE_PC)
    port map(entrada => saidaPC, saida => saidaSomaUm);

  ROM: entity work.memoriaRom
    port map(Endereco => SaidaPC, Dado => instrucaoRom);

    LED <= saidaPC(LED_WIDTH-1 downto 0);


  BancoRegistradores: entity work.bancoRegistradores generic map (larguraDados => DATA_WIDTH, larguraEndBancoRegs => 5)
    port map (
              clk => Clk,
              enderecoA => imediatoRs,
              enderecoB => imediatoRt,
              enderecoC => imediatoRt,
              dadoEscritaC => saidaRam,
              escreveC => SW(0), -- UC
              saidaA => saidaRegA,
              saidaB => saidaRegB
            );

    MuxSaida7Seg: entity work.mux3x1 
      port map(entradaA_MUX => enderecoRam, entradaB_MUX => saidaRegB, entradaC_MUX => saidaRam, seletor_MUX => SW(7 downto 6), saida_MUX => displayOut);

    DISPLAY0 : entity work.conversorHex7Seg
      port map
      (
        dadoHex   => displayOut(3 downto 0),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX0
      );

   
    DISPLAY1 : entity work.conversorHex7Seg
      port map
      (
        dadoHex   => displayOut(7 downto 4),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX1
      );
   
    DISPLAY2 : ENTITY work.conversorHex7Seg
      PORT MAP
      (
        dadoHex   => displayOut(11 downto 8),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX2
      );
    
    DISPLAY3 : entity work.conversorHex7Seg
      port map
      (
        dadoHex   => displayOut(15 downto 12),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX3
      );
    
    DISPLAY4 : entity work.conversorHex7Seg
      port map
      (
        dadoHex   => displayOut(19 downto 16),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX4
      );
    
    DISPLAY5 : entity work.conversorHex7Seg
      port map
      (
        dadoHex   => displayOut(23 downto 20),
        apaga     => '0',
        negativo  => '0',
        overFlow  => '0',
        saida7seg => HEX5
      );


    EstendeSinal: entity work.estendeSinal generic map (larguraDadoEntrada => 16 , larguraDadoSaida => DATA_WIDTH)
      port map ( estendeSinal_IN => imediato, estendeSinal_OUT => imediatoEstendido);

    MemoriaRam: entity work.memoriaRam
    port map (
              clk      => Clk,
              Endereco => enderecoRam,
              Dado_in  => saidaRegB,
              Dado_out => saidaRam,
              we => SW(4),
              re => SW(5)
              );

  ULA: entity work.ULA generic map (larguraDados => DATA_WIDTH)
    port map (
               entradaA => saidaRegA,
               entradaB => imediatoEstendido,
               seletor => SW(3 downto 1), -- UC
               saida => enderecoRam,
               flagZero => flagZero
             ); 
  
end architecture;
