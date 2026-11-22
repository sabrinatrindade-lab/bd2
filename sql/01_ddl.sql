CREATE TABLE tb_pais (
    id_pais         integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_nome       varchar(80)  NOT NULL,
    pais_codigo_iso char(2)      NOT NULL,
    CONSTRAINT uk_pais_nome       UNIQUE (pais_nome),
    CONSTRAINT uk_pais_codigo_iso UNIQUE (pais_codigo_iso)
);

CREATE TABLE tb_estado (
    id_estado    integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pais_id      integer     NOT NULL REFERENCES tb_pais (id_pais),
    estado_nome  varchar(80) NOT NULL,
    estado_sigla char(2)     NOT NULL
);

CREATE TABLE tb_cidade (
    id_cidade   integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    estado_id   integer      NOT NULL REFERENCES tb_estado (id_estado),
    cidade_nome varchar(100) NOT NULL
);

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

CREATE TABLE tb_bloco (
    id_bloco    smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id   smallint NOT NULL REFERENCES tb_campus (id_campus),
    bloco_letra char(1)  NOT NULL,
    CONSTRAINT ck_bloco_letra CHECK (bloco_letra BETWEEN 'A' AND 'L'),
    CONSTRAINT uk_bloco_campus_letra UNIQUE (campus_id, bloco_letra)
);

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
    CONSTRAINT uk_sala_bloco_andar_numero UNIQUE (bloco_id, andar_letra, sala_numero)
);

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

CREATE TABLE tb_curso (
    id_curso       smallint     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campus_id      smallint     NOT NULL REFERENCES tb_campus (id_campus),
    curso_codigo   varchar(10)  NOT NULL,
    curso_nome     varchar(120) NOT NULL,
    curso_grau     varchar(20),
    curso_ch_total integer,
    CONSTRAINT uk_curso_codigo UNIQUE (curso_codigo)
);

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
    CONSTRAINT uk_curriculo_id_curso UNIQUE (id_curriculo, curso_id)
);

CREATE TABLE tb_disciplina (
    id_disciplina     integer     GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    disciplina_codigo varchar(10) NOT NULL,
    disciplina_nome   varchar(120) NOT NULL,
    ch_teorica        smallint    NOT NULL,
    ch_pratica        smallint    NOT NULL,
    ch_total_gerado   smallint    GENERATED ALWAYS AS (ch_teorica + ch_pratica) STORED,
    disciplina_ementa text,
    CONSTRAINT uk_disciplina_codigo UNIQUE (disciplina_codigo),
    CONSTRAINT ck_disciplina_ch_teorica CHECK (ch_teorica >= 0),
    CONSTRAINT ck_disciplina_ch_pratica CHECK (ch_pratica >= 0)
);

CREATE TABLE tb_curriculo_disciplina (
    curriculo_id  integer     NOT NULL REFERENCES tb_curriculo (id_curriculo),
    disciplina_id integer     NOT NULL REFERENCES tb_disciplina (id_disciplina),
    periodo       smallint    NOT NULL,
    tipo          tipo_disc_t NOT NULL DEFAULT 'obrigatoria',
    CONSTRAINT pk_curriculo_disciplina PRIMARY KEY (curriculo_id, disciplina_id)
);

CREATE TABLE tb_prerequisito (
    disciplina_id integer   NOT NULL REFERENCES tb_disciplina (id_disciplina),
    requisito_id  integer   NOT NULL REFERENCES tb_disciplina (id_disciplina),
    vinculo       vinculo_t NOT NULL DEFAULT 'obrigatorio',
    CONSTRAINT pk_prerequisito PRIMARY KEY (disciplina_id, requisito_id),
    CONSTRAINT ck_prerequisito_nao_e_ele_mesmo CHECK (disciplina_id <> requisito_id)
);

CREATE TABLE tb_professor (
    id_professor         integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    professor_matricula  varchar(12)  NOT NULL,
    professor_nome       varchar(120) NOT NULL,
    professor_email      varchar(120) NOT NULL,
    professor_titulacao  varchar(20),
    CONSTRAINT uk_professor_matricula UNIQUE (professor_matricula),
    CONSTRAINT uk_professor_email     UNIQUE (professor_email)
);

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

CREATE TABLE tb_turma_horario (
    id_turma_horario integer   GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    turma_id         integer   NOT NULL REFERENCES tb_turma (id_turma),
    sala_id          integer   NOT NULL REFERENCES tb_sala (id_sala),
    dia_semana       smallint  NOT NULL,
    faixa            timerange NOT NULL,
    CONSTRAINT ck_horario_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT ck_horario_faixa_nao_vazia CHECK (NOT isempty(faixa))
);

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
    CONSTRAINT fk_aluno_curriculo_curso
        FOREIGN KEY (curriculo_id, curso_id) REFERENCES tb_curriculo (id_curriculo, curso_id)
);

CREATE TABLE tb_matricula (
    id_matricula     integer      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_id         integer      NOT NULL REFERENCES tb_aluno (id_aluno),
    turma_id         integer      NOT NULL REFERENCES tb_turma (id_turma),
    data_matricula   timestamptz  NOT NULL DEFAULT now(),
    matricula_status status_mat_t NOT NULL DEFAULT 'ativa',
    CONSTRAINT uk_matricula_aluno_turma UNIQUE (aluno_id, turma_id)
);

CREATE TABLE tb_historico (
    id_historico       integer    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id       integer    NOT NULL REFERENCES tb_matricula (id_matricula),
    nota_a1            nota_t,
    nota_a2            nota_t,
    nota_p3            nota_t,
    frequencia         pct_t,
    situacao           situacao_t NOT NULL DEFAULT 'cursando',
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

CREATE TABLE tb_log_matricula (
    id_log_matricula bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    matricula_id      integer     NOT NULL REFERENCES tb_matricula (id_matricula),
    acao              varchar(20) NOT NULL,
    ocorrido_em       timestamptz NOT NULL DEFAULT now(),
    usuario           name        NOT NULL DEFAULT CURRENT_USER,
    detalhe           jsonb
);
