-- =====================================================================
-- 02_carga_dados.sql
-- Carga de dados de exemplo (dados fictícios, só para fins didáticos).
--
-- IMPORTANTE: este script assume um banco ZERADO, recém-criado a
-- partir de 00_tipos_dominios.sql + 01_ddl.sql. Como as tabelas de
-- referência (país, estado, cidade, campus...) são inseridas uma única
-- vez e nessa ordem, sabemos que seus IDs (gerados por IDENTITY) vão
-- ser 1, 2, 3... Por isso usamos esses números diretamente nas FKs
-- das tabelas seguintes, em vez de reconsultar o ID toda hora — isso
-- deixa o script bem mais simples de ler.
--
-- Resumo do volume gerado (mínimo exigido pelo Marco 1 entre
-- parênteses): 150 alunos (100), 16 turmas (6), ~600 matrículas (300).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Geografia e campus (dados pequenos, inseridos manualmente)
-- ---------------------------------------------------------------------
INSERT INTO tb_pais (pais_nome, pais_codigo_iso) VALUES ('Brasil', 'BR');                 -- id_pais = 1
INSERT INTO tb_estado (pais_id, estado_nome, estado_sigla) VALUES (1, 'Distrito Federal', 'DF'); -- id_estado = 1
INSERT INTO tb_cidade (estado_id, cidade_nome) VALUES (1, 'Brasília');                    -- id_cidade = 1

INSERT INTO tb_campus (pais_id, estado_id, cidade_id, campus_nome, campus_endereco, campus_cep)
VALUES (1, 1, 1, 'IESB Asa Sul', 'SGAS 613, Brasília - DF', '70200-630');                 -- id_campus = 1

-- Dois blocos do campus: A e I (letras de A a L).
INSERT INTO tb_bloco (campus_id, bloco_letra) VALUES
    (1, 'A'),   -- id_bloco = 1
    (1, 'I');   -- id_bloco = 2

-- Salas = bloco + andar (A a C) + número (1 a 20). O código "IA4" que
-- aparece no enunciado é exatamente a sala abaixo: bloco_id 2 (bloco
-- I), andar 'A', número 4.
INSERT INTO tb_sala (bloco_id, andar_letra, sala_numero, sala_capacidade, sala_tipo) VALUES
    (1, 'A', 1, 50, 'sala de aula'),   -- id_sala = 1  -> código AA1
    (1, 'A', 2, 50, 'sala de aula'),   -- id_sala = 2  -> código AA2
    (1, 'B', 3, 40, 'sala de aula'),   -- id_sala = 3  -> código AB3
    (2, 'A', 4, 45, 'sala de aula'),   -- id_sala = 4  -> código IA4 (o exemplo do enunciado)
    (2, 'B', 1, 35, 'laboratorio'),    -- id_sala = 5  -> código IB1
    (2, 'B', 2, 35, 'laboratorio');    -- id_sala = 6  -> código IB2

-- Um feriado nacional, só para exercitar a tabela e o CHECK dela.
INSERT INTO tb_feriado (pais_id, feriado_data, feriado_descricao)
VALUES (1, '2026-11-15', 'Proclamação da República');

-- ---------------------------------------------------------------------
-- Curso e currículo
-- ---------------------------------------------------------------------
INSERT INTO tb_curso (campus_id, curso_codigo, curso_nome, curso_grau, curso_ch_total)
VALUES (1, 'CCOMP', 'Ciência da Computação', 'Bacharelado', 3600);                         -- id_curso = 1

INSERT INTO tb_curriculo (curso_id, curriculo_nome, curriculo_descricao, ano_inicio, ano_previsto, curriculo_status)
VALUES (1, 'Currículo CCOMP 2023', 'Grade curricular vigente a partir de 2023.', 2023, 2027, 'ativo'); -- id_curriculo = 1

-- ---------------------------------------------------------------------
-- Disciplinas (12), formando uma árvore de pré-requisitos de até
-- 4 níveis (ex.: BD2 -> BD1 -> AED -> Lógica de Programação).
-- ---------------------------------------------------------------------
INSERT INTO tb_disciplina (disciplina_codigo, disciplina_nome, ch_teorica, ch_pratica, disciplina_ementa) VALUES
    ('ICOMP', 'Introdução à Computação',               60, 0,  'Fundamentos de computação e lógica.'),         -- 1
    ('LP',    'Lógica de Programação',                 40, 40, 'Algoritmos e lógica de programação.'),         -- 2
    ('CALC1', 'Cálculo I',                              80, 0,  'Limites, derivadas e aplicações.'),            -- 3
    ('AED',   'Algoritmos e Estruturas de Dados',       40, 40, 'Listas, pilhas, filas, árvores.'),             -- 4
    ('CALC2', 'Cálculo II',                              80, 0,  'Integrais e séries.'),                        -- 5
    ('POO',   'Programação Orientada a Objetos',         40, 40, 'Classes, herança, polimorfismo.'),             -- 6
    ('BD1',   'Banco de Dados I',                        40, 40, 'Modelagem conceitual e lógica, SQL básico.'), -- 7
    ('ES',    'Engenharia de Software',                  60, 20, 'Processos e metodologias de desenvolvimento.'),-- 8
    ('SO',    'Sistemas Operacionais',                   60, 20, 'Processos, memória, concorrência.'),          -- 9
    ('REDES', 'Redes de Computadores',                   60, 20, 'Modelo OSI, TCP/IP.'),                        -- 10
    ('CALC3', 'Cálculo III',                              80, 0,  'Cálculo vetorial e EDOs.'),                   -- 11
    ('BD2',   'Banco de Dados II',                       40, 40, 'Integridade, índices, transações, administração.'); -- 12

-- Disciplina -> currículo, organizadas por período sugerido
INSERT INTO tb_curriculo_disciplina (curriculo_id, disciplina_id, periodo, tipo) VALUES
    (1, 1, 1, 'obrigatoria'), (1, 2, 1, 'obrigatoria'), (1, 3, 1, 'obrigatoria'),
    (1, 4, 2, 'obrigatoria'), (1, 5, 2, 'obrigatoria'), (1, 6, 2, 'obrigatoria'),
    (1, 7, 3, 'obrigatoria'), (1, 8, 3, 'obrigatoria'), (1, 9, 3, 'obrigatoria'),
    (1, 10, 4, 'obrigatoria'), (1, 11, 4, 'obrigatoria'), (1, 12, 4, 'obrigatoria');

-- Pré-requisitos (disciplina_id EXIGE requisito_id)
INSERT INTO tb_prerequisito (disciplina_id, requisito_id, vinculo) VALUES
    (4, 2, 'obrigatorio'),   -- AED exige Lógica de Programação
    (7, 4, 'obrigatorio'),   -- BD1 exige AED
    (12, 7, 'obrigatorio'),  -- BD2 exige BD1
    (5, 3, 'obrigatorio'),   -- Cálculo II exige Cálculo I
    (11, 5, 'obrigatorio'),  -- Cálculo III exige Cálculo II
    (8, 4, 'obrigatorio'),   -- Engenharia de Software exige AED
    (9, 4, 'obrigatorio'),   -- Sistemas Operacionais exige AED
    (10, 1, 'obrigatorio'),  -- Redes exige Introdução à Computação
    (6, 2, 'obrigatorio');   -- POO exige Lógica de Programação

-- ---------------------------------------------------------------------
-- Professores (8)
-- ---------------------------------------------------------------------
INSERT INTO tb_professor (professor_matricula, professor_nome, professor_email, professor_titulacao)
SELECT
    'PROF' || lpad(i::text, 4, '0'),
    (ARRAY['Rodrigo','Camila','Marcelo','Patrícia','André','Fernanda','Luciano','Juliana'])[i] || ' ' ||
    (ARRAY['Gonçalves','Ramos','Teixeira','Vieira','Barros','Castro','Pinto','Azevedo'])[i],
    'professor' || i || '@iesb.edu.br',
    (ARRAY['Doutor','Mestre','Doutor','Mestre','Especialista','Doutor','Mestre','Doutor'])[i]
FROM generate_series(1, 8) AS i;

-- ---------------------------------------------------------------------
-- Períodos letivos: 2026/1 (já concluído) e 2026/2 (em andamento, o
-- período "atual" da disciplina)
-- ---------------------------------------------------------------------
INSERT INTO tb_periodo_letivo (ano, semestre, data_inicio, data_fim) VALUES
    (2026, 1, '2026-03-02', '2026-07-17'),  -- id_periodo_letivo = 1 (concluído)
    (2026, 2, '2026-08-03', '2026-12-18');  -- id_periodo_letivo = 2 (em andamento)

-- ---------------------------------------------------------------------
-- Turmas
-- 2026/1 (ids 1-7): disciplinas de início de curso, já encerradas.
-- 2026/2 (ids 8-16): disciplinas em andamento neste semestre.
-- ---------------------------------------------------------------------
INSERT INTO tb_turma (professor_id, disciplina_id, periodo_letivo_id, turma_codigo, turno, vagas) VALUES
    (1, 1, 1, 'ICOMP-2026.1-A', 'matutino',   45),  -- 1
    (2, 2, 1, 'LP-2026.1-A',    'matutino',   45),  -- 2
    (3, 3, 1, 'CALC1-2026.1-A','matutino',    50),  -- 3
    (4, 4, 1, 'AED-2026.1-A',  'noturno',     40),  -- 4
    (5, 5, 1, 'CALC2-2026.1-A','noturno',     50),  -- 5
    (6, 6, 1, 'POO-2026.1-A',  'vespertino',  35),  -- 6
    (7, 7, 1, 'BD1-2026.1-A',  'noturno',     40),  -- 7
    (8, 4, 2, 'AED-2026.2-B',  'noturno',     40),  -- 8
    (1, 5, 2, 'CALC2-2026.2-A','matutino',    50),  -- 9
    (2, 6, 2, 'POO-2026.2-A',  'noturno',     35),  -- 10
    (3, 7, 2, 'BD1-2026.2-A',  'matutino',    40),  -- 11
    (4, 8, 2, 'ES-2026.2-A',   'noturno',     40),  -- 12
    (5, 9, 2, 'SO-2026.2-A',   'noturno',     40),  -- 13
    (6, 10, 2, 'REDES-2026.2-A','vespertino', 40),  -- 14
    (7, 11, 2, 'CALC3-2026.2-A','matutino',   45),  -- 15
    (8, 12, 2, 'BD2-2026.2-A', 'noturno',     4);   -- 16: proposital com poucas vagas
                                                     --     (3 já preenchidas abaixo, sobra
                                                     --      EXATAMENTE 1 vaga -> vamos
                                                     --      "disputar a última vaga" na
                                                     --      seção de transações)

-- Um horário semanal por turma (sala e faixa variando ciclicamente)
INSERT INTO tb_turma_horario (turma_id, sala_id, dia_semana, faixa)
SELECT
    t.id_turma,
    1 + ((t.id_turma - 1) % 6),
    2 + ((t.id_turma - 1) % 5),                    -- segunda a sexta
    (ARRAY['[08:00,09:40)','[09:40,11:20)','[19:00,20:40)','[20:40,22:20)'])
        [1 + ((t.id_turma - 1) % 4)]::timerange
FROM tb_turma t;

-- ---------------------------------------------------------------------
-- Alunos (150), todos no mesmo curso/currículo para simplificar.
-- Nomes combinados por fórmula só para parecerem variados; CPF e
-- matrícula são sequenciais fictícios (não são CPFs reais).
-- ---------------------------------------------------------------------
INSERT INTO tb_aluno (curso_id, curriculo_id, aluno_matricula, aluno_nome, aluno_cpf,
                      aluno_nascimento, aluno_data_ingresso, aluno_ativo)
SELECT
    1,
    1,
    'IESB' || lpad(i::text, 6, '0'),
    (ARRAY['Ana','Bruno','Carla','Daniel','Eduarda','Felipe','Gabriela','Hugo','Isabela','João',
           'Karina','Lucas','Mariana','Natan','Olívia','Pedro','Queila','Rafael','Sabrina','Tiago'])[1 + (i % 20)]
    || ' ' ||
    (ARRAY['Silva','Santos','Oliveira','Souza','Pereira','Costa','Rodrigues','Almeida','Nascimento','Lima',
           'Araújo','Fernandes','Carvalho','Gomes','Martins','Rocha','Ribeiro','Alves','Monteiro','Cardoso'])[1 + ((i * 7) % 20)],
    lpad(i::text, 11, '0'),
    DATE '2002-01-01' + ((i * 37) % 3285),
    CASE WHEN i % 2 = 0 THEN DATE '2023-02-01' ELSE DATE '2023-08-01' END,
    true
FROM generate_series(1, 150) AS i;

-- ---------------------------------------------------------------------
-- Matrículas 2026/1 (encerrado): cada aluno cursou 2 turmas daquele
-- período (turmas de id 1 a 7). Seleção "pseudo-aleatória" mas
-- determinística via módulo, só para distribuir os alunos nas turmas.
-- ---------------------------------------------------------------------
INSERT INTO tb_matricula (aluno_id, turma_id, data_matricula, matricula_status)
SELECT a.id_aluno, tu.id_turma, TIMESTAMPTZ '2026-02-20', 'concluida'
FROM tb_aluno a
CROSS JOIN LATERAL (
    SELECT t.id_turma
    FROM tb_turma t
    WHERE t.periodo_letivo_id = 1
    ORDER BY (a.id_aluno * 11 + t.id_turma * 5) % 97
    LIMIT 2
) AS tu
ON CONFLICT (aluno_id, turma_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- Matrículas 2026/2 (em andamento): cada aluno cursando 2 turmas deste
-- período (turmas de id 8 a 15 — a turma 16, BD2, fica de fora da
-- carga em massa de propósito, para sobrarem vagas reais e usarmos
-- ela na demonstração da disputa pela última vaga).
-- ---------------------------------------------------------------------
INSERT INTO tb_matricula (aluno_id, turma_id, data_matricula, matricula_status)
SELECT a.id_aluno, tu.id_turma, TIMESTAMPTZ '2026-07-28', 'ativa'
FROM tb_aluno a
CROSS JOIN LATERAL (
    SELECT t.id_turma
    FROM tb_turma t
    WHERE t.periodo_letivo_id = 2 AND t.id_turma <> 16
    ORDER BY (a.id_aluno * 13 + t.id_turma * 3) % 97
    LIMIT 2
) AS tu
ON CONFLICT (aluno_id, turma_id) DO NOTHING;

-- Três alunos já matriculados antecipadamente na turma de BD2 (id 16,
-- vagas = 4) — ou seja, sobra EXATAMENTE 1 vaga. É essa turma que
-- vamos usar depois para reproduzir a disputa pela "última vaga".
INSERT INTO tb_matricula (aluno_id, turma_id, data_matricula, matricula_status)
VALUES (1, 16, TIMESTAMPTZ '2026-07-20', 'ativa'),
       (2, 16, TIMESTAMPTZ '2026-07-20', 'ativa'),
       (3, 16, TIMESTAMPTZ '2026-07-20', 'ativa');

-- ---------------------------------------------------------------------
-- Histórico de 2026/1: notas e frequência "pseudo-aleatórias" (fórmula
-- com módulo, só para gerar variedade de aprovados/reprovados).
-- ---------------------------------------------------------------------
INSERT INTO tb_historico (matricula_id, nota_a1, nota_a2, frequencia, situacao)
SELECT
    m.id_matricula,
    round((40 + ((m.aluno_id * 13 + m.turma_id * 7) % 55)) / 10.0, 2),
    round((40 + ((m.aluno_id * 17 + m.turma_id * 11) % 58)) / 10.0, 2),
    round((60 + ((m.aluno_id * 5 + m.turma_id * 3) % 41))::numeric, 2),
    'cursando'   -- valor temporário; corrigido pelo UPDATE logo abaixo
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE t.periodo_letivo_id = 1
ON CONFLICT (matricula_id) DO NOTHING;

-- A situação final depende da média gerada automaticamente (coluna
-- gerada media_final_gerado) e da frequência mínima de 75%.
UPDATE tb_historico h
SET situacao = CASE
    WHEN h.media_final_gerado >= 5.0 AND h.frequencia >= 75 THEN 'aprovado'::situacao_t
    ELSE 'reprovado'::situacao_t
END
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE h.matricula_id = m.id_matricula AND t.periodo_letivo_id = 1;

-- ---------------------------------------------------------------------
-- Histórico de 2026/2: período em andamento, ainda sem notas.
-- ---------------------------------------------------------------------
INSERT INTO tb_historico (matricula_id, situacao)
SELECT m.id_matricula, 'cursando'
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE t.periodo_letivo_id = 2
ON CONFLICT (matricula_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- Conferência rápida dos volumes (deve aparecer >= 100 / 6 / 300)
-- ---------------------------------------------------------------------
SELECT
    (SELECT count(*) FROM tb_aluno)     AS total_alunos,
    (SELECT count(*) FROM tb_turma)     AS total_turmas,
    (SELECT count(*) FROM tb_matricula) AS total_matriculas;
