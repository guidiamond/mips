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
    AuxReset : in std_logic;
    SW       : in  std_logic_vector(10 downto 0);
    -- Out
    PC_IN   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    PC_OUT   : out std_logic_vector(DATA_WIDTH-1 downto 0);
    LED      : out  std_logic_vector(10 downto 0) -- Valores dos Pontos de Controle
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
  signal auxClk : std_logic;

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

  -- UCs
  alias selMuxPc_4_BeqJump : std_logic is SW(0);
  alias selMuxRtRd: std_logic is SW(1);
  alias habEscritaReg: std_logic is SW(2);
  alias selMuxRtImed: std_logic is SW(3);
  alias selOpUla: std_logic_vector(2 downto 0) is SW(6 downto 4);
  alias selMuxUlaMem: std_logic is SW(7);
  alias beqUC: std_logic is SW(8);
  alias habEscrita: std_logic is SW(9);
  alias habLeitura: std_logic is SW(10);

begin

  PC: entity work.registradorGenerico generic map (larguraDados => ADDR_WIDTH)
    port map (DIN => saidaProxPC, DOUT => saidaPC, ENABLE => '1', CLK => Clk, RST => AuxReset);

  SomaConstante: entity work.somaConstante generic map (larguraDados => ADDR_WIDTH, constante => CONSTANTE_PC)
    port map(entrada => saidaPC, saida => saidaSomaCte);

  ROM: entity work.memoriaRom
    port map(Endereco => SaidaPC, Dado => instrucaoRom);

  LED <= SW;

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


    EstendeSinal: entity work.estendeSinal generic map (larguraDadoEntrada => 16 , larguraDadoSaida => DATA_WIDTH)
      port map ( estendeSinal_IN => imediato, estendeSinal_OUT => imediatoEstendido);

    MemoriaRam: entity work.memoriaRam
    port map (
              clk      => Clk,
              Endereco => enderecoRam,
              Dado_in  => saidaRegB,
              Dado_out => saidaRam,
              we => habEscrita,
              re => habLeitura
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

    PC_IN <= saidaProxPC;
    PC_OUT <= saidaPC;
end architecture;
