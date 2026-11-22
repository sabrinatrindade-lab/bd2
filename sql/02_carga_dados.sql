INSERT INTO tb_pais (pais_nome, pais_codigo_iso) VALUES ('Brasil', 'BR');
INSERT INTO tb_estado (pais_id, estado_nome, estado_sigla) VALUES (1, 'Distrito Federal', 'DF');
INSERT INTO tb_cidade (estado_id, cidade_nome) VALUES (1, 'Brasília');

INSERT INTO tb_campus (pais_id, estado_id, cidade_id, campus_nome, campus_endereco, campus_cep)
VALUES (1, 1, 1, 'IESB Asa Sul', 'SGAS 613, Brasília - DF', '70200-630');

INSERT INTO tb_bloco (campus_id, bloco_letra) VALUES
    (1, 'A'),
    (1, 'I');

INSERT INTO tb_sala (bloco_id, andar_letra, sala_numero, sala_capacidade, sala_tipo) VALUES
    (1, 'A', 1, 50, 'sala de aula'),
    (1, 'A', 2, 50, 'sala de aula'),
    (1, 'B', 3, 40, 'sala de aula'),
    (2, 'A', 4, 45, 'sala de aula'),
    (2, 'B', 1, 35, 'laboratorio'),
    (2, 'B', 2, 35, 'laboratorio');

INSERT INTO tb_feriado (pais_id, feriado_data, feriado_descricao)
VALUES (1, '2026-11-15', 'Proclamação da República');

INSERT INTO tb_curso (campus_id, curso_codigo, curso_nome, curso_grau, curso_ch_total)
VALUES (1, 'CCOMP', 'Ciência da Computação', 'Bacharelado', 3600);

INSERT INTO tb_curriculo (curso_id, curriculo_nome, curriculo_descricao, ano_inicio, ano_previsto, curriculo_status)
VALUES (1, 'Currículo CCOMP 2023', 'Grade curricular vigente a partir de 2023.', 2023, 2027, 'ativo');

INSERT INTO tb_disciplina (disciplina_codigo, disciplina_nome, ch_teorica, ch_pratica, disciplina_ementa) VALUES
    ('ICOMP', 'Introdução à Computação',               60, 0,  'Fundamentos de computação e lógica.'),
    ('LP',    'Lógica de Programação',                 40, 40, 'Algoritmos e lógica de programação.'),
    ('CALC1', 'Cálculo I',                              80, 0,  'Limites, derivadas e aplicações.'),
    ('AED',   'Algoritmos e Estruturas de Dados',       40, 40, 'Listas, pilhas, filas, árvores.'),
    ('CALC2', 'Cálculo II',                              80, 0,  'Integrais e séries.'),
    ('POO',   'Programação Orientada a Objetos',         40, 40, 'Classes, herança, polimorfismo.'),
    ('BD1',   'Banco de Dados I',                        40, 40, 'Modelagem conceitual e lógica, SQL básico.'),
    ('ES',    'Engenharia de Software',                  60, 20, 'Processos e metodologias de desenvolvimento.'),
    ('SO',    'Sistemas Operacionais',                   60, 20, 'Processos, memória, concorrência.'),
    ('REDES', 'Redes de Computadores',                   60, 20, 'Modelo OSI, TCP/IP.'),
    ('CALC3', 'Cálculo III',                              80, 0,  'Cálculo vetorial e EDOs.'),
    ('BD2',   'Banco de Dados II',                       40, 40, 'Integridade, índices, transações, administração.');

INSERT INTO tb_curriculo_disciplina (curriculo_id, disciplina_id, periodo, tipo) VALUES
    (1, 1, 1, 'obrigatoria'), (1, 2, 1, 'obrigatoria'), (1, 3, 1, 'obrigatoria'),
    (1, 4, 2, 'obrigatoria'), (1, 5, 2, 'obrigatoria'), (1, 6, 2, 'obrigatoria'),
    (1, 7, 3, 'obrigatoria'), (1, 8, 3, 'obrigatoria'), (1, 9, 3, 'obrigatoria'),
    (1, 10, 4, 'obrigatoria'), (1, 11, 4, 'obrigatoria'), (1, 12, 4, 'obrigatoria');

INSERT INTO tb_prerequisito (disciplina_id, requisito_id, vinculo) VALUES
    (4, 2, 'obrigatorio'),
    (7, 4, 'obrigatorio'),
    (12, 7, 'obrigatorio'),
    (5, 3, 'obrigatorio'),
    (11, 5, 'obrigatorio'),
    (8, 4, 'obrigatorio'),
    (9, 4, 'obrigatorio'),
    (10, 1, 'obrigatorio'),
    (6, 2, 'obrigatorio');

INSERT INTO tb_professor (professor_matricula, professor_nome, professor_email, professor_titulacao)
SELECT
    'PROF' || lpad(i::text, 4, '0'),
    (ARRAY['Rodrigo','Camila','Marcelo','Patrícia','André','Fernanda','Luciano','Juliana'])[i] || ' ' ||
    (ARRAY['Gonçalves','Ramos','Teixeira','Vieira','Barros','Castro','Pinto','Azevedo'])[i],
    'professor' || i || '@iesb.edu.br',
    (ARRAY['Doutor','Mestre','Doutor','Mestre','Especialista','Doutor','Mestre','Doutor'])[i]
FROM generate_series(1, 8) AS i;

INSERT INTO tb_periodo_letivo (ano, semestre, data_inicio, data_fim) VALUES
    (2026, 1, '2026-03-02', '2026-07-17'),
    (2026, 2, '2026-08-03', '2026-12-18');

INSERT INTO tb_turma (professor_id, disciplina_id, periodo_letivo_id, turma_codigo, turno, vagas) VALUES
    (1, 1, 1, 'ICOMP-2026.1-A', 'matutino',   45),
    (2, 2, 1, 'LP-2026.1-A',    'matutino',   45),
    (3, 3, 1, 'CALC1-2026.1-A','matutino',    50),
    (4, 4, 1, 'AED-2026.1-A',  'noturno',     40),
    (5, 5, 1, 'CALC2-2026.1-A','noturno',     50),
    (6, 6, 1, 'POO-2026.1-A',  'vespertino',  35),
    (7, 7, 1, 'BD1-2026.1-A',  'noturno',     40),
    (8, 4, 2, 'AED-2026.2-B',  'noturno',     40),
    (1, 5, 2, 'CALC2-2026.2-A','matutino',    50),
    (2, 6, 2, 'POO-2026.2-A',  'noturno',     35),
    (3, 7, 2, 'BD1-2026.2-A',  'matutino',    40),
    (4, 8, 2, 'ES-2026.2-A',   'noturno',     40),
    (5, 9, 2, 'SO-2026.2-A',   'noturno',     40),
    (6, 10, 2, 'REDES-2026.2-A','vespertino', 40),
    (7, 11, 2, 'CALC3-2026.2-A','matutino',   45),
    (8, 12, 2, 'BD2-2026.2-A', 'noturno',     4);

INSERT INTO tb_turma_horario (turma_id, sala_id, dia_semana, faixa)
SELECT
    t.id_turma,
    1 + ((t.id_turma - 1) % 6),
    2 + ((t.id_turma - 1) % 5),
    (ARRAY['[08:00,09:40)','[09:40,11:20)','[19:00,20:40)','[20:40,22:20)'])
        [1 + ((t.id_turma - 1) % 4)]::timerange
FROM tb_turma t;

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

INSERT INTO tb_matricula (aluno_id, turma_id, data_matricula, matricula_status)
VALUES (1, 16, TIMESTAMPTZ '2026-07-20', 'ativa'),
       (2, 16, TIMESTAMPTZ '2026-07-20', 'ativa'),
       (3, 16, TIMESTAMPTZ '2026-07-20', 'ativa');

INSERT INTO tb_historico (matricula_id, nota_a1, nota_a2, frequencia, situacao)
SELECT
    m.id_matricula,
    round((40 + ((m.aluno_id * 13 + m.turma_id * 7) % 55)) / 10.0, 2),
    round((40 + ((m.aluno_id * 17 + m.turma_id * 11) % 58)) / 10.0, 2),
    round((60 + ((m.aluno_id * 5 + m.turma_id * 3) % 41))::numeric, 2),
    'cursando'
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE t.periodo_letivo_id = 1
ON CONFLICT (matricula_id) DO NOTHING;

UPDATE tb_historico h
SET situacao = CASE
    WHEN h.media_final_gerado >= 5.0 AND h.frequencia >= 75 THEN 'aprovado'::situacao_t
    ELSE 'reprovado'::situacao_t
END
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE h.matricula_id = m.id_matricula AND t.periodo_letivo_id = 1;

INSERT INTO tb_historico (matricula_id, situacao)
SELECT m.id_matricula, 'cursando'
FROM tb_matricula m
JOIN tb_turma t ON t.id_turma = m.turma_id
WHERE t.periodo_letivo_id = 2
ON CONFLICT (matricula_id) DO NOTHING;

SELECT
    (SELECT count(*) FROM tb_aluno)     AS total_alunos,
    (SELECT count(*) FROM tb_turma)     AS total_turmas,
    (SELECT count(*) FROM tb_matricula) AS total_matriculas;
