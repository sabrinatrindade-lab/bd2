-- =====================================================================
-- 01_ddl.sql
-- DDL completo do Sistema de Matrícula Acadêmica.
-- Modelo lógico fornecido pelo professor (mesmo para todos os grupos);
-- aqui só transformamos esse modelo em tabelas reais, com tipos,
-- chaves e restrições de integridade.
--
-- Execute depois de 00_tipos_dominios.sql.
-- Ordem das tabelas = ordem de dependência (quem é referenciado vem
-- primeiro, senão a FK não tem para onde apontar).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Geografia: país / estado / cidade
--    Usada só como referência para campus e feriado.
-- ---------------------------------------------------------------------
CREATE TABLE tb_pais (
    id_pais         integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_nome       varchar(80)  NOT NULL,
    pais_codigo_iso char(2)      NOT NULL,
    CONSTRAINT uk_pais_nome       UNIQUE (pais_nome),
    CONSTRAINT uk_pais_codigo_iso UNIQUE (pais_codigo_iso)
);
COMMENT ON TABLE tb_pais IS 'Entidade de referência geográfica: países.';

CREATE TABLE tb_estado (
    id_estado    integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id      integer     NOT NULL REFERENCES tb_pais (id_pais),
    estado_nome  varchar(80) NOT NULL,
    estado_sigla char(2)     NOT NULL
);
COMMENT ON TABLE tb_estado IS 'Estados, cada um pertence a um país (N:1 com tb_pais).';

CREATE TABLE tb_cidade (
    id_cidade   integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado_id   integer      NOT NULL REFERENCES tb_estado (id_estado),
    cidade_nome varchar(100) NOT NULL
);
COMMENT ON TABLE tb_cidade IS 'Cidades, cada uma pertence a um estado (N:1 com tb_estado).';

-- ---------------------------------------------------------------------
-- 2) Estrutura física do campus
-- ---------------------------------------------------------------------
CREATE TABLE tb_campus (
    id_campus       smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id         integer      NOT NULL REFERENCES tb_pais (id_pais),
    estado_id       integer      NOT NULL REFERENCES tb_estado (id_estado),
    cidade_id       integer      NOT NULL REFERENCES tb_cidade (id_cidade),
    campus_nome     varchar(80)  NOT NULL,
    campus_endereco varchar(200),
    campus_cep      varchar(10),
    CONSTRAINT uk_campus_nome UNIQUE (campus_nome)
);
COMMENT ON TABLE tb_campus IS 'Um campus físico do centro universitário.';

-- Estrutura real do IESB: cada sala é identificada por um código de 3
-- caracteres, ex. "IA4" = Bloco I, Andar A, Sala 4. Por isso:
--   - tb_bloco guarda a LETRA do bloco (A a L);
--   - tb_sala guarda a LETRA do andar (A a C) e o NÚMERO da sala
--     (1 a 20) daquele bloco/andar.
-- Não existe uma tabela separada de "prédio": aqui, cada bloco já
-- identifica univocamente a edificação (ver docs/guia_apresentacao.md,
-- pergunta 10, sobre por que essa simplificação foi feita).
CREATE TABLE tb_bloco (
    id_bloco    smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id   smallint NOT NULL REFERENCES tb_campus (id_campus),
    bloco_letra char(1)  NOT NULL,
    CONSTRAINT ck_bloco_letra CHECK (bloco_letra BETWEEN 'A' AND 'L'),
    CONSTRAINT uk_bloco_campus_letra UNIQUE (campus_id, bloco_letra)
);
COMMENT ON TABLE tb_bloco IS 'Bloco físico de um campus, identificado por uma letra de A a L (ex.: Bloco I).';

CREATE TABLE tb_sala (
    id_sala         integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bloco_id        smallint    NOT NULL REFERENCES tb_bloco (id_bloco),
    andar_letra     char(1)     NOT NULL,
    sala_numero     smallint    NOT NULL,
    sala_capacidade smallint    NOT NULL,
    sala_tipo       tipo_sala_t NOT NULL DEFAULT 'sala de aula',
    CONSTRAINT ck_sala_andar_letra CHECK (andar_letra BETWEEN 'A' AND 'C'),
    CONSTRAINT ck_sala_numero      CHECK (sala_numero BETWEEN 1 AND 20),
    CONSTRAINT ck_sala_capacidade  CHECK (sala_capacidade > 0),
    -- Garante que não existam duas salas com o mesmo
    -- bloco+andar+número (isso é o que torna o código "IA4" único).
    CONSTRAINT uk_sala_bloco_andar_numero UNIQUE (bloco_id, andar_letra, sala_numero)
);
COMMENT ON TABLE tb_sala IS
  'Sala de aula/laboratório. O código visível (ex.: "IA4") não é uma coluna própria: é a letra do bloco + andar_letra + sala_numero (ver consulta que monta esse código em sql/03_consultas_marco1.sql, Consulta 9).';
COMMENT ON COLUMN tb_sala.andar_letra IS 'Andar dentro do bloco: A, B ou C.';
COMMENT ON COLUMN tb_sala.sala_numero IS 'Número da sala dentro daquele bloco/andar: 1 a 20.';

CREATE TABLE tb_feriado (
    id_feriado        integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id           integer      REFERENCES tb_pais (id_pais),
    estado_id         integer      REFERENCES tb_estado (id_estado),
    cidade_id         integer      REFERENCES tb_cidade (id_cidade),
    campus_id         smallint     REFERENCES tb_campus (id_campus),
    feriado_data      date         NOT NULL,
    feriado_descricao varchar(120) NOT NULL,
    CONSTRAINT ck_feriado_abrangencia CHECK (
        pais_id IS NOT NULL OR estado_id IS NOT NULL
        OR cidade_id IS NOT NULL OR campus_id IS NOT NULL
    )
);
COMMENT ON TABLE tb_feriado IS
  'Feriado válido para um país, estado, cidade ou campus específico (pelo menos um precisa estar preenchido).';

-- ---------------------------------------------------------------------
-- 3) Estrutura acadêmica: curso, currículo, disciplina
-- ---------------------------------------------------------------------
CREATE TABLE tb_curso (
    id_curso       smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id      smallint     NOT NULL REFERENCES tb_campus (id_campus),
    curso_codigo   varchar(10)  NOT NULL,
    curso_nome     varchar(120) NOT NULL,
    curso_grau     varchar(20),
    curso_ch_total integer,
    CONSTRAINT uk_curso_codigo UNIQUE (curso_codigo)
);
COMMENT ON TABLE tb_curso IS 'Curso de graduação oferecido em um campus (ex.: Ciência da Computação).';

CREATE TABLE tb_curriculo (
    id_curriculo        integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    curso_id             smallint     NOT NULL REFERENCES tb_curso (id_curso),
    curriculo_nome       varchar(120) NOT NULL,
    curriculo_descricao  text,
    ano_inicio           smallint     NOT NULL,
    ano_previsto         smallint     NOT NULL,
    curriculo_status     status_curriculo_t NOT NULL DEFAULT 'ativo',
    data_inclusao        timestamptz  NOT NULL DEFAULT now(),
    data_alteracao       timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT ck_curriculo_anos CHECK (ano_previsto >= ano_inicio),
    -- UNIQUE composta: existe só para servir de "âncora" de uma FK
    -- composta lá na frente (tb_aluno), garantindo que o currículo do
    -- aluno realmente pertence ao curso do aluno.
    CONSTRAINT uk_curriculo_id_curso UNIQUE (id_curriculo, curso_id)
);
COMMENT ON TABLE tb_curriculo IS 'Versão de currículo (grade curricular) de um curso.';

CREATE TABLE tb_disciplina (
    id_disciplina     integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disciplina_codigo varchar(10) NOT NULL,
    disciplina_nome   varchar(120) NOT NULL,
    ch_teorica        smallint    NOT NULL,
    ch_pratica        smallint    NOT NULL,
    -- Coluna gerada: carga horária total é sempre teórica + prática,
    -- não faz sentido o usuário poder digitar um valor incoerente.
    ch_total_gerado   smallint    GENERATED ALWAYS AS (ch_teorica + ch_pratica) STORED,
    disciplina_ementa text,
    CONSTRAINT uk_disciplina_codigo UNIQUE (disciplina_codigo),
    CONSTRAINT ck_disciplina_ch_teorica CHECK (ch_teorica >= 0),
    CONSTRAINT ck_disciplina_ch_pratica CHECK (ch_pratica >= 0)
);
COMMENT ON TABLE tb_disciplina IS 'Disciplina que pode ser ofertada em turmas.';
COMMENT ON COLUMN tb_disciplina.ch_total_gerado IS
  'Coluna gerada (STORED): sempre igual a ch_teorica + ch_pratica.';

CREATE TABLE tb_curriculo_disciplina (
    curriculo_id  integer     NOT NULL REFERENCES tb_curriculo (id_curriculo),
    disciplina_id integer     NOT NULL REFERENCES tb_disciplina (id_disciplina),
    periodo       smallint    NOT NULL,
    tipo          tipo_disc_t NOT NULL DEFAULT 'obrigatoria',
    CONSTRAINT pk_curriculo_disciplina PRIMARY KEY (curriculo_id, disciplina_id)
);
COMMENT ON TABLE tb_curriculo_disciplina IS
  'Tabela associativa N:N entre currículo e disciplina (qual disciplina entra em qual currículo, em qual período).';

CREATE TABLE tb_prerequisito (
    disciplina_id integer   NOT NULL REFERENCES tb_disciplina (id_disciplina),
    requisito_id  integer   NOT NULL REFERENCES tb_disciplina (id_disciplina),
    vinculo       vinculo_t NOT NULL DEFAULT 'obrigatorio',
    CONSTRAINT pk_prerequisito PRIMARY KEY (disciplina_id, requisito_id),
    CONSTRAINT ck_prerequisito_nao_e_ele_mesmo CHECK (disciplina_id <> requisito_id)
);
COMMENT ON TABLE tb_prerequisito IS
  'Tabela associativa N:N "auto-relacionamento" de disciplina com disciplina: cada linha diz "X exige Y como pré-requisito".';

-- ---------------------------------------------------------------------
-- 4) Professor e oferta de turmas
-- ---------------------------------------------------------------------
CREATE TABLE tb_professor (
    id_professor         integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    professor_matricula  varchar(12)  NOT NULL,
    professor_nome       varchar(120) NOT NULL,
    professor_email      varchar(120) NOT NULL,
    professor_titulacao  varchar(20),
    CONSTRAINT uk_professor_matricula UNIQUE (professor_matricula),
    CONSTRAINT uk_professor_email     UNIQUE (professor_email)
);
COMMENT ON TABLE tb_professor IS 'Professor que pode lecionar turmas.';

CREATE TABLE tb_periodo_letivo (
    id_periodo_letivo smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ano               smallint NOT NULL,
    semestre          smallint NOT NULL,
    data_inicio       date     NOT NULL,
    data_fim          date     NOT NULL,
    CONSTRAINT ck_periodo_semestre CHECK (semestre IN (1, 2)),
    CONSTRAINT ck_periodo_datas    CHECK (data_fim > data_inicio),
    CONSTRAINT uk_periodo_ano_semestre UNIQUE (ano, semestre)
);
COMMENT ON TABLE tb_periodo_letivo IS 'Período letivo (ex.: 2026/2), com data de início e fim.';

CREATE TABLE tb_turma (
    id_turma          integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    professor_id      integer     NOT NULL REFERENCES tb_professor (id_professor),
    disciplina_id     integer     NOT NULL REFERENCES tb_disciplina (id_disciplina),
    periodo_letivo_id smallint    NOT NULL REFERENCES tb_periodo_letivo (id_periodo_letivo),
    turma_codigo      varchar(15) NOT NULL,
    turno             turno_t     NOT NULL,
    vagas             smallint    NOT NULL,
    CONSTRAINT uk_turma_codigo UNIQUE (turma_codigo),
    CONSTRAINT ck_turma_vagas  CHECK (vagas > 0)
);
COMMENT ON TABLE tb_turma IS 'Oferta de uma disciplina, por um professor, em um período letivo, com N vagas.';

CREATE TABLE tb_turma_horario (
    id_turma_horario integer   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    turma_id         integer   NOT NULL REFERENCES tb_turma (id_turma),
    sala_id          integer   NOT NULL REFERENCES tb_sala (id_sala),
    dia_semana       smallint  NOT NULL,
    faixa            timerange NOT NULL,
    CONSTRAINT ck_horario_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    -- O tipo "timerange" por construção já exige início < fim (o
    -- Postgres recusa um range com limite inferior maior que o
    -- superior); só garantimos aqui que a faixa não foi deixada vazia.
    CONSTRAINT ck_horario_faixa_nao_vazia CHECK (NOT isempty(faixa))
);
COMMENT ON TABLE tb_turma_horario IS
  'Um horário semanal de uma turma (dia da semana + faixa de horário) em uma sala.';
COMMENT ON COLUMN tb_turma_horario.dia_semana IS
  '1 = segunda-feira ... 6 = sábado, 7 = domingo. Usamos smallint + CHECK em vez de ENUM (ver docs/guia_apresentacao.md).';

-- ---------------------------------------------------------------------
-- 5) Aluno, matrícula e histórico
-- ---------------------------------------------------------------------
CREATE TABLE tb_aluno (
    id_aluno            integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    curso_id            smallint     NOT NULL REFERENCES tb_curso (id_curso),
    curriculo_id        integer      NOT NULL,
    aluno_matricula     varchar(120) NOT NULL,
    aluno_nome          varchar(120) NOT NULL,
    aluno_cpf           char(11)     NOT NULL,
    aluno_nascimento    date,
    aluno_data_ingresso date         NOT NULL DEFAULT CURRENT_DATE,
    aluno_ativo         boolean      NOT NULL DEFAULT true,
    CONSTRAINT uk_aluno_matricula UNIQUE (aluno_matricula),
    CONSTRAINT uk_aluno_cpf       UNIQUE (aluno_cpf),
    -- FK composta: garante que o par (currículo, curso) do aluno é um
    -- par que realmente existe em tb_curriculo (evita, por exemplo, um
    -- aluno de Engenharia estar amarrado a um currículo de Direito).
    CONSTRAINT fk_aluno_curriculo_curso
        FOREIGN KEY (curriculo_id, curso_id) REFERENCES tb_curriculo (id_curriculo, curso_id)
);
COMMENT ON TABLE tb_aluno IS 'Aluno matriculado em um curso, seguindo um currículo específico daquele curso.';

CREATE TABLE tb_matricula (
    id_matricula     integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id         integer      NOT NULL REFERENCES tb_aluno (id_aluno),
    turma_id         integer      NOT NULL REFERENCES tb_turma (id_turma),
    data_matricula   timestamptz  NOT NULL DEFAULT now(),
    matricula_status status_mat_t NOT NULL DEFAULT 'ativa',
    CONSTRAINT uk_matricula_aluno_turma UNIQUE (aluno_id, turma_id)
);
COMMENT ON TABLE tb_matricula IS
  'Tabela associativa N:N entre aluno e turma: cada linha é uma inscrição de um aluno em uma turma.';

CREATE TABLE tb_historico (
    id_historico       integer    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id       integer    NOT NULL REFERENCES tb_matricula (id_matricula),
    nota_a1            nota_t,
    nota_a2            nota_t,
    nota_p3            nota_t,
    frequencia         pct_t,
    situacao           situacao_t NOT NULL DEFAULT 'cursando',
    -- Coluna gerada: reproduz a regra de nota do próprio edital do
    -- professor -> MF = 0,4*A1 + 0,6*A2, e a P3 substitui essa média
    -- quando ela é maior (prova que recupera a média mais baixa).
    media_final_gerado numeric(4,2) GENERATED ALWAYS AS (
        CASE
            WHEN nota_a1 IS NULL OR nota_a2 IS NULL THEN NULL
            WHEN nota_p3 IS NOT NULL
                 AND nota_p3 > round(nota_a1 * 0.4 + nota_a2 * 0.6, 2)
                THEN nota_p3
            ELSE round(nota_a1 * 0.4 + nota_a2 * 0.6, 2)
        END
    ) STORED,
    CONSTRAINT uk_historico_matricula UNIQUE (matricula_id)
);
COMMENT ON TABLE tb_historico IS
  'Histórico/boletim de UMA matrícula: notas, frequência, situação e média final (calculada automaticamente).';

CREATE TABLE tb_log_matricula (
    id_log_matricula bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id      integer     NOT NULL REFERENCES tb_matricula (id_matricula),
    acao              varchar(20) NOT NULL,
    ocorrido_em       timestamptz NOT NULL DEFAULT now(),
    usuario           name        NOT NULL DEFAULT CURRENT_USER,
    detalhe           jsonb
);
COMMENT ON TABLE tb_log_matricula IS
  'Log de auditoria: registra ações (inserção, cancelamento etc.) ocorridas sobre uma matrícula.';
