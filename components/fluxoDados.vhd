library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;      

entity fluxoDados is
  generic (
            DATA_WIDTH              : NATURAL := 32;
            PALAVRA_CONTROLE_WIDTH  : NATURAL := 10;
            OPCODE_WIDTH            : NATURAL := 6;
            FUNCT_WIDTH             : NATURAL := 6;
            REG_WIDTH               : NATURAL := 5;
            ULA_CTRL_WIDTH          : NATURAL := 4;
            CONSTANTE_PC            : NATURAL := 4
          );

  port (
           -- Inputs
           Clk            : in std_logic;
           pontosControle : in std_logic_vector(PALAVRA_CONTROLE_WIDTH-1 downto 0); -- gerado da UC para realizar as instruções
           -- Outputs
           opCode         : out std_logic_vector(OPCODE_WIDTH-1 downto 0); -- usado na UC para gerar os pontosControle
           saida_pc       : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Usados para testes com o waveform
           saida_ula      : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Usados para testes com o waveform
);
end entity;

architecture arch_name of fluxoDados is
  signal saidaPC, saidaSomaCte : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal instRom : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal saidaRegA : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaRegB : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Instrucao alias
  alias imedOpCode : std_logic_vector(OPCODE_WIDTH-1 downto 0) is instRom(DATA_WIDTH-1 downto 26);
  alias imedRs     : std_logic_vector(REG_WIDTH-1 downto 0) is instRom(25 downto 21);
  alias imedRt     : std_logic_vector(REG_WIDTH-1 downto 0) is instRom(20 downto 16);
  alias imedRd     : std_logic_vector(REG_WIDTH-1 downto 0) is instRom(15 downto 11);
  alias imediato   : std_logic_vector(15 downto 0) is instRom(15 downto 0);
  alias funct      : std_logic_vector(FUNCT_WIDTH-1 downto 0) is instRom(FUNCT_WIDTH-1 downto 0);

  -- Usado no pc_imediato
  alias imediatoShift   : std_logic_vector(25 downto 0) is instRom(25 downto 0);

  -- Saida estende sinal
  signal imedExt      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal enderecoRam  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaRam     : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Signal flagzero
  signal flagZero : std_logic;

  signal proxInstrucao   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal pc_or_beq       : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaSomaImedPC : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaUlaMem     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal saidaMuxRtImed  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal rt_or_rd        : std_logic_vector(REG_WIDTH-1 downto 0);


  signal selProxPcBeq : std_logic;

  -- UCs
  alias sel_PcBeq_J   : std_logic is pontosControle(0);
  alias sel_rt_rd     : std_logic is pontosControle(1);
  alias habEscritaReg : std_logic is pontosControle(2);
  alias sel_rt_imed   : std_logic is pontosControle(3);
  alias sel_ula_mem   : std_logic is pontosControle(4);
  alias beqUC         : std_logic is pontosControle(5);
  alias habLeituraRam : std_logic is pontosControle(6);
  alias habEscritaRam : std_logic is pontosControle(7);
  alias ulaOP         : std_logic_vector(1 downto 0) is pontosControle(9 downto 8);

  signal ulaCtrl : std_logic_vector(ULA_CTRL_WIDTH-1 downto 0);
  signal jump    : std_logic_vector(DATA_WIDTH-1 downto 0);


begin

  PC: entity work.registradorGenerico generic map (larguraDados => DATA_WIDTH)
    port map ( DIN => proxInstrucao, DOUT => saidaPC, ENABLE => '1', CLK => Clk, RST => '0' );


  Mux_PcBeq_J: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map( entradaA_MUX => pc_or_beq, entradaB_MUX => jump, seletor_MUX => sel_PcBeq_J, saida_MUX => proxInstrucao );

  SomaConstante: entity work.somaConstante generic map (larguraDados => DATA_WIDTH, constante => CONSTANTE_PC)
    port map(entrada => saidaPC, saida => saidaSomaCte);

  PcImediato: entity work.joinPcImediato
    port map (imediato => imediatoShift, PC => saidaSomaCte(31 downto 28), saida => jump);

  ROM: entity work.memoriaRom
    port map(Endereco => saidaPC, Dado => instRom);

  MuxRtRd: entity work.mux2x1 generic map (larguraDados => REG_WIDTH)
    port map( entradaA_MUX => imedRt, entradaB_MUX => imedRd, seletor_MUX => sel_rt_rd, saida_MUX => rt_or_rd );

  BancoRegistradores: entity work.bancoRegistradores generic map (larguraDados => DATA_WIDTH, larguraEndBancoRegs => REG_WIDTH)
    port map (
              clk => Clk,
              enderecoA => imedRs,
              enderecoB => imedRt,
              enderecoC => rt_or_rd,
              dadoEscritaC => saidaUlaMem,
              escreveC => habEscritaReg, -- UC
              saidaA => saidaRegA,
              saidaB => saidaRegB
            );

  MuxRtImediato: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => saidaRegB, entradaB_MUX => imedExt, seletor_MUX => sel_rt_imed, saida_MUX => saidaMuxRtImed);

  SomaImedPC: entity work.somaImedPC
    port map (PC => saidaSomaCte, imExtShift => imedExt(29 downto 0) & "00", saida => saidaSomaImedPC); -- MUDAR

  MuxSomaCteBeq: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => saidaSomaCte, entradaB_MUX => saidaSomaImedPC, seletor_MUX => selProxPcBeq, saida_MUX => pc_or_beq);

  MuxUlaMem: entity work.mux2x1 generic map (larguraDados => DATA_WIDTH)
    port map(entradaA_MUX => enderecoRam, entradaB_MUX => saidaRam, seletor_MUX => sel_ula_mem, saida_MUX => saidaUlaMem);

  EstendeSinal: entity work.estendeSinal generic map (larguraDadoEntrada => 16 , larguraDadoSaida => DATA_WIDTH)
    port map ( estendeSinal_IN => imediato, estendeSinal_OUT => imedExt );

    MemoriaRam: entity work.memoriaRam
      port map (
              clk      => Clk,
              Endereco => enderecoRam,
              Dado_in  => saidaRegB,
              Dado_out => saidaRam,
              we => habEscritaRam,
              re => habLeituraRam
            );

    UC_ULA: entity work.unidadeControleULA port map ( clk => Clk, funct => funct, ulaOP => ulaOP, ulaCtrl => ulaCtrl );

    ULA: entity work.ULA generic map (larguraDados => DATA_WIDTH)
      port map (
               entradaA => saidaRegA,
               entradaB => saidaMuxRtImed,
               seletor  => ulaCtrl, -- vem da UC
               saida    => enderecoRam,
               flagZero => flagZero
             ); 
  
    selProxPcBeq <= '1' when (flagZero = '1' and beqUC = '1') else '0';
    opCode <= imedOpCode;

    -- Usado para teste no waveform
    saida_pc <= saidaPC;
    saida_ula <= enderecoRam;

end architecture;
