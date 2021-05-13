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
    SW       : in  std_logic_vector(9 downto 0);
    BUT      : in  std_logic_vector(3 downto 0);
    -- Monitora PC
    LED      : out  std_logic_vector(9 downto 0);
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5      : out std_logic_vector(6 downto 0)
);
end entity;

architecture arch_name of main is
  signal saidaPC, saidaSomaCte : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal instrucaoRom : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal saidaRegA : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaRegB : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Instrucao alias
  alias opCode   : std_logic_vector(5 downto 0) is instrucaoRom(ADDR_WIDTH-1 downto 26);
  alias imediatoRs : std_logic_vector(REG_WIDTH-1 downto 0) is instrucaoRom(25 downto 21);
  alias imediatoRt : std_logic_vector(REG_WIDTH-1 downto 0) is instrucaoRom(20 downto 16);
  alias imediatoRd : std_logic_vector(REG_WIDTH-1 downto 0) is instrucaoRom(15 downto 11);
  alias imediato   : std_logic_vector(15 downto 0) is instrucaoRom(15 downto 0);

  -- Usado no pc_imediato
  alias imediatoShift   : std_logic_vector(25 downto 0) is instrucaoRom(25 downto 0);

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

  signal saidaProxPC : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal entradaMuxProxPC: std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaProxPcBeq : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaSomaImedPC : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaUlaMem : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaMuxRtImed : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaMuxRtRd : std_logic_vector(REG_WIDTH-1 downto 0);


  signal selProxPcBeq : std_logic;
   -- MUDAR para chave dps de falar com o Paulo
  signal habLeitura : std_logic;

  -- UCs
  alias selMuxPc_4_BeqJump : std_logic is SW(0);
  alias selMuxRtRd: std_logic is SW(1);
  alias habEscritaReg: std_logic is SW(2);
  alias selMuxRtImed: std_logic is SW(3);
  alias selOpUla: std_logic_vector(2 downto 0) is SW(6 downto 4);
  alias selMuxUlaMem: std_logic is SW(7);
  alias beqUC: std_logic is SW(8);
  alias habEscrita: std_logic is SW(9);

begin

  PC: entity work.registradorGenerico generic map (larguraDados => ADDR_WIDTH)
    port map (DIN => saidaProxPC, DOUT => saidaPC, ENABLE => '1', CLK => auxClk, RST => auxReset);

  detectorSub0: work.edgeDetector(bordaSubida) port map (clk => Clk, entrada => (not BUT(0)), saida => auxReset);
  detectorSub1: work.edgeDetector(bordaSubida) port map (clk => Clk, entrada => (not BUT(1)), saida => auxClk);

  SomaConstante: entity work.somaConstante generic map (larguraDados => ADDR_WIDTH, constante => CONSTANTE_PC)
    port map(entrada => saidaPC, saida => saidaSomaCte);

  ROM: entity work.memoriaRom
    port map(Endereco => SaidaPC, Dado => instrucaoRom);

  LED <= SW;

  muxProxPC: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => saidaProxPcBeq, entradaB_MUX => entradaMuxProxPC, seletor_MUX => selMuxPc_4_BeqJump, saida_MUX => saidaProxPC);

  muxRtImediato: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => saidaRegB, entradaB_MUX => imediatoEstendido, seletor_MUX => selMuxRtImed, saida_MUX => saidaMuxRtImed);

  muxRtRd: entity work.mux2x1 generic map (larguraDados => 5)
    port map(entradaA_MUX => imediatoRt, entradaB_MUX => imediatoRd, seletor_MUX => selMuxRtRd, saida_MUX => saidaMuxRtRd);

  PcImediato: entity work.joinPcImediato
    port map (imediato => imediatoShift, PC => saidaSomaCte(31 downto 28), saida => entradaMuxProxPC);

  SomaImedPC: entity work.somaImedPC
    port map (PC => saidaSomaCte, imExtShift => imediatoEstendido(29 downto 0) & "00", saida => saidaSomaImedPC); -- MUDAR

  muxSomaCteBeq: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => saidaSomaCte, entradaB_MUX => saidaSomaImedPC, seletor_MUX => selProxPcBeq, saida_MUX => saidaProxPcBeq);

  muxUlaMem: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => enderecoRam, entradaB_MUX => saidaRam, seletor_MUX => selMuxUlaMem, saida_MUX => saidaUlaMem);


  BancoRegistradores: entity work.bancoRegistradores generic map (larguraDados => DATA_WIDTH, larguraEndBancoRegs => 5)
    port map (
              clk => Clk,
              enderecoA => imediatoRs,
              enderecoB => imediatoRt,
              enderecoC => saidaMuxRtRd,
              dadoEscritaC => saidaUlaMem,
              escreveC => habEscritaReg, -- UC
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
              we => habEscrita,
              re => habEscrita
              );

  ULA: entity work.ULA generic map (larguraDados => DATA_WIDTH)
    port map (
               entradaA => saidaRegA,
               entradaB => saidaMuxRtImed,
               seletor => selOpUla, -- UC
               saida => enderecoRam,
               flagZero => flagZero
             ); 
  
    selProxPcBeq <= '1' when (flagZero = '1' and beqUC = '1') else '0';
end architecture;
