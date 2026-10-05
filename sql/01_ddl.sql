-- =============================================================================
-- 01_ddl_aprimorado.sql
-- Sistema de Matrícula Acadêmica (IESB) — Banco de Dados II — 2026/2
-- Alvo: PostgreSQL 17
-- =============================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- -----------------------------------------------------------------------------
-- 1. Domínios e Tipos
-- -----------------------------------------------------------------------------
CREATE DOMAIN nota_t AS numeric(4,2) CHECK (VALUE >= 0 AND VALUE <= 10);
CREATE DOMAIN pct_t AS numeric(5,2) CHECK (VALUE >= 0 AND VALUE <= 100);

CREATE TYPE tipo_sala_t        AS ENUM ('teorica', 'laboratorio', 'auditorio', 'outra');
CREATE TYPE status_curriculo_t AS ENUM ('em_elaboracao', 'vigente', 'desativado');
CREATE TYPE tipo_disc_t        AS ENUM ('obrigatoria', 'optativa', 'eletiva');
CREATE TYPE vinculo_t          AS ENUM ('pre_requisito', 'co_requisito');
CREATE TYPE turno_t            AS ENUM ('matutino', 'vespertino', 'noturno');
CREATE TYPE status_mat_t       AS ENUM ('ativa', 'trancada', 'cancelada', 'concluida');
CREATE TYPE situacao_t         AS ENUM ('cursando', 'aprovado', 'reprovado_nota', 'reprovado_frequencia', 'trancado');

CREATE TYPE timerange AS RANGE (SUBTYPE = time);

-- -----------------------------------------------------------------------------
-- 2. Geografia e infraestrutura física
-- -----------------------------------------------------------------------------
CREATE TABLE tb_pais (
    id_pais         integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_nome       varchar(80) NOT NULL UNIQUE,
    pais_codigo_iso char(2)     NOT NULL UNIQUE CHECK (pais_codigo_iso ~ '^[A-Z]{2}$')
);

CREATE TABLE tb_estado (
    id_estado    integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id      integer     NOT NULL REFERENCES tb_pais(id_pais) ON DELETE RESTRICT,
    estado_nome  varchar(80) NOT NULL,
    estado_sigla char(2)     NOT NULL
);

CREATE TABLE tb_cidade (
    id_cidade   integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado_id   integer      NOT NULL REFERENCES tb_estado(id_estado) ON DELETE RESTRICT,
    cidade_nome varchar(100) NOT NULL
);

CREATE TABLE tb_campus (
    id_campus       smallint    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id         integer     NOT NULL REFERENCES tb_pais(id_pais) ON DELETE RESTRICT,
    estado_id       integer     NOT NULL REFERENCES tb_estado(id_estado) ON DELETE RESTRICT,
    cidade_id       integer     NOT NULL REFERENCES tb_cidade(id_cidade) ON DELETE RESTRICT,
    campus_nome     varchar(80) NOT NULL UNIQUE,
    campus_endereco varchar(200),
    campus_cep      varchar(10)
);

CREATE TABLE tb_bloco (
    id_bloco     integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id    smallint    NOT NULL REFERENCES tb_campus(id_campus) ON DELETE CASCADE,
    bloco_nome   char(1)     NOT NULL,
    bloco_codigo varchar(20) NOT NULL UNIQUE
);

CREATE TABLE tb_predio (
    id_predio     integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id     smallint    NOT NULL REFERENCES tb_campus(id_campus) ON DELETE CASCADE,
    predio_nome   varchar(80) NOT NULL,
    predio_codigo varchar(20) NOT NULL UNIQUE
);

CREATE TABLE tb_sala (
    id_sala          integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    predio_id        integer     NOT NULL REFERENCES tb_predio(id_predio) ON DELETE CASCADE,
    bloco_id         integer     NOT NULL REFERENCES tb_bloco(id_bloco) ON DELETE RESTRICT,
    sala_codigo      varchar(10) NOT NULL,
    sala_capacidade  smallint    NOT NULL CHECK (sala_capacidade > 0),
    sala_tipo        tipo_sala_t NOT NULL,
    UNIQUE (predio_id, sala_codigo)
);

CREATE TABLE tb_feriado (
    id_feriado        integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id           integer      REFERENCES tb_pais(id_pais) ON DELETE CASCADE,
    estado_id         integer      REFERENCES tb_estado(id_estado) ON DELETE CASCADE,
    cidade_id         integer      REFERENCES tb_cidade(id_cidade) ON DELETE CASCADE,
    campus_id         smallint     REFERENCES tb_campus(id_campus) ON DELETE CASCADE,
    feriado_data      date         NOT NULL,
    feriado_descricao varchar(120) NOT NULL,
    CHECK (num_nonnulls(pais_id, estado_id, cidade_id, campus_id) >= 1)
);

-- -----------------------------------------------------------------------------
-- 3. Oferta acadêmica
-- -----------------------------------------------------------------------------
CREATE TABLE tb_curso (
    id_curso       smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id      smallint     NOT NULL REFERENCES tb_campus(id_campus) ON DELETE RESTRICT,
    curso_codigo   varchar(10)  NOT NULL UNIQUE,
    curso_nome     varchar(120) NOT NULL,
    curso_grau     varchar(20)  NOT NULL,
    curso_ch_total integer      NOT NULL CHECK (curso_ch_total > 0)
);

CREATE TABLE tb_curriculo (
    id_curriculo      integer              GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    curso_id          smallint             NOT NULL REFERENCES tb_curso(id_curso) ON DELETE CASCADE,
    curriculo_nome    varchar(120)         NOT NULL,
    curriculo_descricao text,
    ano_inicio        smallint             NOT NULL,
    ano_previsto      smallint             NOT NULL CHECK (ano_previsto >= ano_inicio),
    curriculo_status  status_curriculo_t   NOT NULL DEFAULT 'em_elaboracao',
    data_inclusao     timestamptz          NOT NULL DEFAULT now(),
    data_alteracao    timestamptz,
    UNIQUE (id_curriculo, curso_id) -- Necessário para FK composta do Aluno
);

CREATE TABLE tb_disciplina (
    id_disciplina     integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disciplina_codigo varchar(10)  NOT NULL UNIQUE,
    disciplina_nome   varchar(120) NOT NULL,
    ch_teorica        smallint     NOT NULL CHECK (ch_teorica >= 0),
    ch_pratica        smallint     NOT NULL CHECK (ch_pratica >= 0),
    ch_total_gerado   smallint     GENERATED ALWAYS AS ((ch_teorica + ch_pratica)::smallint) STORED,
    disciplina_ementa text
);

CREATE TABLE tb_curriculo_disciplina (
    curriculo_id  integer     NOT NULL REFERENCES tb_curriculo(id_curriculo) ON DELETE CASCADE,
    disciplina_id integer     NOT NULL REFERENCES tb_disciplina(id_disciplina) ON DELETE RESTRICT,
    periodo       smallint    NOT NULL CHECK (periodo > 0),
    tipo          tipo_disc_t NOT NULL,
    PRIMARY KEY (curriculo_id, disciplina_id)
);

CREATE TABLE tb_prerequisito (
    disciplina_id integer   NOT NULL REFERENCES tb_disciplina(id_disciplina) ON DELETE CASCADE,
    requisito_id  integer   NOT NULL REFERENCES tb_disciplina(id_disciplina) ON DELETE CASCADE,
    vinculo       vinculo_t NOT NULL DEFAULT 'pre_requisito',
    PRIMARY KEY (disciplina_id, requisito_id),
    CHECK (disciplina_id <> requisito_id)
);

CREATE TABLE tb_periodo_letivo (
    id_periodo_letivo smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ano               smallint NOT NULL,
    semestre          smallint NOT NULL CHECK (semestre IN (1, 2)),
    data_inicio       date     NOT NULL,
    data_fim          date     NOT NULL CHECK (data_fim > data_inicio),
    UNIQUE (ano, semestre)
);

-- -----------------------------------------------------------------------------
-- 4. Professores e turmas
-- -----------------------------------------------------------------------------
CREATE TABLE tb_professor (
    id_professor        integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    professor_matricula varchar(12)  NOT NULL UNIQUE,
    professor_nome      varchar(120) NOT NULL,
    professor_email     varchar(120) NOT NULL UNIQUE CHECK (professor_email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    professor_titulacao varchar(20)
);

CREATE TABLE tb_turma (
    id_turma          integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    turma_codigo      varchar(15) NOT NULL UNIQUE,
    disciplina_id     integer     NOT NULL REFERENCES tb_disciplina(id_disciplina) ON DELETE RESTRICT,
    periodo_letivo_id smallint    NOT NULL REFERENCES tb_periodo_letivo(id_periodo_letivo) ON DELETE RESTRICT,
    professor_id      integer     REFERENCES tb_professor(id_professor) ON DELETE SET NULL,
    turno             turno_t     NOT NULL,
    vagas             smallint    NOT NULL CHECK (vagas > 0)
);

CREATE TABLE tb_turma_horario (
    id_turma_horario integer   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    turma_id         integer   NOT NULL REFERENCES tb_turma(id_turma) ON DELETE CASCADE,
    sala_id          integer   NOT NULL REFERENCES tb_sala(id_sala) ON DELETE RESTRICT,
    dia_semana       smallint  NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    faixa            timerange NOT NULL CHECK (NOT lower_inf(faixa) AND NOT upper_inf(faixa) AND lower(faixa) < upper(faixa)),
    
    CONSTRAINT ex_horario_sala  EXCLUDE USING gist (sala_id WITH =, dia_semana WITH =, faixa WITH &&),
    CONSTRAINT ex_horario_turma EXCLUDE USING gist (turma_id WITH =, dia_semana WITH =, faixa WITH &&)
);

-- -----------------------------------------------------------------------------
-- 5. Alunos, matrículas e histórico
-- -----------------------------------------------------------------------------
CREATE TABLE tb_aluno (
    id_aluno         integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    curso_id         smallint     NOT NULL REFERENCES tb_curso(id_curso) ON DELETE RESTRICT,
    curriculo_id     integer      NOT NULL,
    aluno_matricula  varchar(12)  NOT NULL UNIQUE,
    aluno_nome       varchar(120) NOT NULL,
    aluno_cpf        char(11)     NOT NULL UNIQUE CHECK (aluno_cpf ~ '^[0-9]{11}$'),
    aluno_email      varchar(120) NOT NULL UNIQUE CHECK (aluno_email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'),
    aluno_nascimento date         NOT NULL,
    aluno_ativo      boolean      NOT NULL DEFAULT true,
    
    FOREIGN KEY (curriculo_id, curso_id) REFERENCES tb_curriculo(id_curriculo, curso_id) ON DELETE RESTRICT
);

CREATE TABLE tb_matricula (
    id_matricula     integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id         integer      NOT NULL REFERENCES tb_aluno(id_aluno) ON DELETE CASCADE,
    turma_id         integer      NOT NULL REFERENCES tb_turma(id_turma) ON DELETE RESTRICT,
    data_matricula   timestamptz  NOT NULL DEFAULT now(),
    matricula_status status_mat_t NOT NULL DEFAULT 'ativa',
    UNIQUE (aluno_id, turma_id)
);

CREATE TABLE tb_historico (
    id_historico       integer    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id       integer    NOT NULL UNIQUE REFERENCES tb_matricula(id_matricula) ON DELETE CASCADE,
    nota_a1            nota_t,
    nota_a2            nota_t,
    nota_p3            nota_t,
    frequencia         pct_t,
    situacao           situacao_t NOT NULL DEFAULT 'cursando',
    
    -- Aprimoramento: Regra de substituição da P3 validada matematicamente direto no banco. 
    -- Compara a média normal com as médias onde a P3 substitui a A1 ou a A2 e escolhe a maior.
    media_final_gerado numeric(4,2) GENERATED ALWAYS AS (
        GREATEST(
            round(COALESCE(nota_a1, 0) * 0.4 + COALESCE(nota_a2, 0) * 0.6, 2),
            round(COALESCE(nota_p3, 0) * 0.4 + COALESCE(nota_a2, 0) * 0.6, 2),
            round(COALESCE(nota_a1, 0) * 0.4 + COALESCE(nota_p3, 0) * 0.6, 2)
        )
    ) STORED
);

CREATE TABLE tb_log_matricula (
    id_log_matricula bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id     integer     REFERENCES tb_matricula(id_matricula) ON DELETE SET NULL,
    acao             varchar(20) NOT NULL,
    ocorrido_em      timestamptz NOT NULL DEFAULT now(),
    usuario          name        NOT NULL DEFAULT current_user,
    detalhe          jsonb
);

-- -----------------------------------------------------------------------------
-- 6. Otimização de Performance (Índices para Chaves Estrangeiras)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_estado_pais         ON tb_estado (pais_id);
CREATE INDEX idx_cidade_estado       ON tb_cidade (estado_id);
CREATE INDEX idx_sala_predio         ON tb_sala (predio_id);
CREATE INDEX idx_curriculo_curso     ON tb_curriculo (curso_id);
CREATE INDEX idx_turma_disciplina    ON tb_turma (disciplina_id);
CREATE INDEX idx_turma_periodo       ON tb_turma (periodo_letivo_id);
CREATE INDEX idx_turma_professor     ON tb_turma (professor_id);
CREATE INDEX idx_horario_turma       ON tb_turma_horario (turma_id);
CREATE INDEX idx_horario_sala        ON tb_turma_horario (sala_id);
CREATE INDEX idx_aluno_curso         ON tb_aluno (curso_id);
CREATE INDEX idx_aluno_curriculo     ON tb_aluno (curriculo_id);
CREATE INDEX idx_matricula_aluno     ON tb_matricula (aluno_id);
CREATE INDEX idx_matricula_turma     ON tb_matricula (turma_id);

COMMIT; 