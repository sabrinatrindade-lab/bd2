-- =====================================================================
-- 03_consultas_marco1.sql
-- As 10 consultas de complexidade crescente exigidas no Marco 1.
-- Cada uma comentada: o que faz, por que é desse jeito, e o que
-- observar no resultado. Execute depois de 02_carga_dados.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Consulta 1 — a mais simples: 10 registros da tabela de alunos.
-- (É literalmente uma das perguntas que o professor faz na arguição.)
-- ---------------------------------------------------------------------
SELECT id_aluno, aluno_matricula, aluno_nome, aluno_ativo
FROM tb_aluno
ORDER BY id_aluno
LIMIT 10;


-- ---------------------------------------------------------------------
-- Consulta 2 — INNER JOIN simples: disciplina de cada turma do
-- período 2026/2, com nome do professor.
-- ---------------------------------------------------------------------
SELECT t.turma_codigo, d.disciplina_nome, p.professor_nome, t.turno, t.vagas
FROM tb_turma t
INNER JOIN tb_disciplina d ON d.id_disciplina = t.disciplina_id
INNER JOIN tb_professor p  ON p.id_professor = t.professor_id
INNER JOIN tb_periodo_letivo pl ON pl.id_periodo_letivo = t.periodo_letivo_id
WHERE pl.ano = 2026 AND pl.semestre = 2
ORDER BY t.turma_codigo;


-- ---------------------------------------------------------------------
-- Consulta 3 — GROUP BY + HAVING: turmas com mais de 50 matrículas
-- acumuladas (mostra concentração de demanda por disciplina).
-- ---------------------------------------------------------------------
SELECT d.disciplina_nome, count(m.id_matricula) AS total_matriculados
FROM tb_matricula m
JOIN tb_turma t      ON t.id_turma = m.turma_id
JOIN tb_disciplina d ON d.id_disciplina = t.disciplina_id
GROUP BY d.disciplina_nome
HAVING count(m.id_matricula) > 50
ORDER BY total_matriculados DESC;


-- ---------------------------------------------------------------------
-- Consulta 4 (OBRIGATÓRIA) — JUNÇÃO EXTERNA (LEFT JOIN) COM
-- AGREGAÇÃO: quantas vagas cada turma do período atual já ocupou,
-- incluindo turmas que eventualmente não tenham NENHUMA matrícula
-- (por isso é LEFT JOIN e não INNER JOIN — uma turma sem matrícula
-- ainda precisa aparecer no relatório, com zero).
-- ---------------------------------------------------------------------
SELECT
    t.turma_codigo,
    t.vagas,
    count(m.id_matricula) AS ocupadas,
    t.vagas - count(m.id_matricula) AS vagas_restantes
FROM tb_turma t
LEFT JOIN tb_matricula m
       ON m.turma_id = t.id_turma AND m.matricula_status = 'ativa'
JOIN tb_periodo_letivo pl ON pl.id_periodo_letivo = t.periodo_letivo_id
WHERE pl.ano = 2026 AND pl.semestre = 2
GROUP BY t.id_turma, t.turma_codigo, t.vagas
ORDER BY vagas_restantes ASC;


-- ---------------------------------------------------------------------
-- Consulta 5 (OBRIGATÓRIA) — CONSULTA RECURSIVA: árvore completa de
-- pré-requisitos de uma disciplina (aqui, Banco de Dados II).
--
-- Como funciona uma CTE recursiva (WITH RECURSIVE):
--   1) "Âncora": a primeira parte do UNION ALL busca o ponto de
--      partida (a própria disciplina, nível 0).
--   2) "Passo recursivo": a segunda parte busca os pré-requisitos
--      DAQUILO que já foi encontrado, incrementando o nível. O
--      PostgreSQL repete esse passo até não encontrar mais nada novo.
--   3) O resultado final é a UNIÃO de tudo que foi encontrado nas
--      repetições.
-- ---------------------------------------------------------------------
WITH RECURSIVE arvore_prerequisitos AS (
    -- Âncora: a disciplina de interesse, nível 0
    SELECT d.id_disciplina, d.disciplina_nome, 0 AS nivel
    FROM tb_disciplina d
    WHERE d.disciplina_codigo = 'BD2'

    UNION ALL

    -- Passo recursivo: sobe um nível na árvore de pré-requisitos
    SELECT req.id_disciplina, req.disciplina_nome, ap.nivel + 1
    FROM arvore_prerequisitos ap
    JOIN tb_prerequisito pr ON pr.disciplina_id = ap.id_disciplina
    JOIN tb_disciplina req  ON req.id_disciplina = pr.requisito_id
)
SELECT DISTINCT nivel, disciplina_nome
FROM arvore_prerequisitos
ORDER BY nivel, disciplina_nome;


-- ---------------------------------------------------------------------
-- Consulta 6 (OBRIGATÓRIA) — CONSULTA RECURSIVA: quais disciplinas um
-- aluno específico JÁ PODE CURSAR, ou seja, disciplinas do currículo
-- em que ele ainda não está matriculado/aprovado e cujos
-- pré-requisitos (direta e transitivamente) ele já cumpriu.
--
-- Estratégia: primeiro montamos, com uma CTE recursiva, a lista de
-- TODOS os pré-requisitos (diretos e indiretos) de cada disciplina.
-- Depois comparamos essa lista com o que o aluno já foi aprovado.
-- ---------------------------------------------------------------------
WITH RECURSIVE todos_prerequisitos AS (
    -- Âncora: pré-requisitos diretos de cada disciplina
    SELECT disciplina_id, requisito_id
    FROM tb_prerequisito

    UNION

    -- Passo recursivo: "pré-requisito do pré-requisito" também conta
    SELECT tp.disciplina_id, pr.requisito_id
    FROM todos_prerequisitos tp
    JOIN tb_prerequisito pr ON pr.disciplina_id = tp.requisito_id
),
aprovadas_do_aluno AS (
    SELECT DISTINCT t.disciplina_id
    FROM tb_matricula m
    JOIN tb_historico h ON h.matricula_id = m.id_matricula
    JOIN tb_turma t     ON t.id_turma = m.turma_id
    WHERE m.aluno_id = 1 AND h.situacao = 'aprovado'
)
SELECT d.disciplina_codigo, d.disciplina_nome
FROM tb_disciplina d
JOIN tb_curriculo_disciplina cd ON cd.disciplina_id = d.id_disciplina AND cd.curriculo_id = 1
WHERE d.id_disciplina NOT IN (SELECT disciplina_id FROM aprovadas_do_aluno)
  AND NOT EXISTS (
        -- não pode faltar NENHUM pré-requisito (direto ou indireto)
        SELECT 1
        FROM todos_prerequisitos tp
        WHERE tp.disciplina_id = d.id_disciplina
          AND tp.requisito_id NOT IN (SELECT disciplina_id FROM aprovadas_do_aluno)
  )
ORDER BY d.disciplina_codigo;


-- ---------------------------------------------------------------------
-- Consulta 7 (OBRIGATÓRIA) — FUNÇÃO DE JANELA com RANKING e
-- PERCENTIL: ranking dos alunos de uma turma pela média final, do
-- maior para o menor, mais o percentil de cada um.
--
-- RANK()         -> posição no ranking (empates recebem a mesma
--                   posição, e a próxima posição "pula", ex.: 1,2,2,4).
-- PERCENT_RANK() -> em que percentual da turma aquele aluno está
--                   (0 = o pior, próximo de 1 = os melhores).
-- ---------------------------------------------------------------------
SELECT
    a.aluno_nome,
    h.media_final_gerado,
    RANK()         OVER (ORDER BY h.media_final_gerado DESC) AS posicao_ranking,
    round(
        PERCENT_RANK() OVER (ORDER BY h.media_final_gerado DESC)::numeric, 2
    ) AS percentil
FROM tb_historico h
JOIN tb_matricula m ON m.id_matricula = h.matricula_id
JOIN tb_aluno a     ON a.id_aluno = m.aluno_id
WHERE m.turma_id = 7   -- turma de Banco de Dados I em 2026/1
  AND h.media_final_gerado IS NOT NULL
ORDER BY posicao_ranking;


-- ---------------------------------------------------------------------
-- Consulta 8 (OBRIGATÓRIA) — FUNÇÃO DE JANELA com LAG: evolução do
-- rendimento de cada aluno entre o período anterior e o período atual
-- (compara a média final mais recente com a média final do período
-- passado, usando LAG para "olhar para a linha anterior" sem
-- precisar de sub-consulta ou de self-join).
-- ---------------------------------------------------------------------
SELECT
    a.aluno_nome,
    pl.ano, pl.semestre,
    h.media_final_gerado AS media_do_periodo,
    LAG(h.media_final_gerado) OVER (
        PARTITION BY a.id_aluno ORDER BY pl.ano, pl.semestre
    ) AS media_periodo_anterior,
    h.media_final_gerado - LAG(h.media_final_gerado) OVER (
        PARTITION BY a.id_aluno ORDER BY pl.ano, pl.semestre
    ) AS variacao
FROM tb_historico h
JOIN tb_matricula m      ON m.id_matricula = h.matricula_id
JOIN tb_aluno a          ON a.id_aluno = m.aluno_id
JOIN tb_turma t          ON t.id_turma = m.turma_id
JOIN tb_periodo_letivo pl ON pl.id_periodo_letivo = t.periodo_letivo_id
WHERE h.media_final_gerado IS NOT NULL
ORDER BY a.aluno_nome, pl.ano, pl.semestre
LIMIT 20;


-- ---------------------------------------------------------------------
-- Consulta 9 — RIGHT JOIN: lista todas as salas, mostrando também as
-- que não têm NENHUM horário de turma marcado (sala ociosa). Poderia
-- ser escrita como LEFT JOIN invertendo a ordem das tabelas — está
-- aqui como RIGHT JOIN só para exercitar a sintaxe, já que é um dos
-- tipos de JOIN que o professor pode pedir exemplo na arguição
-- (ver docs/guia_apresentacao.md, pergunta 14).
--
-- Esta consulta também mostra por que o "código da sala" (ex.: IA4)
-- NÃO é uma coluna guardada em tb_sala: ele depende de uma coluna de
-- OUTRA tabela (bloco_letra, que mora em tb_bloco), e uma coluna
-- gerada (GENERATED ALWAYS AS) só pode usar colunas da PRÓPRIA linha.
-- Quando o dado derivado depende de mais de uma tabela, a forma
-- correta é montar ele numa consulta (um JOIN), como abaixo — e não
-- duplicar a letra do bloco dentro de tb_sala só para simplificar o
-- cálculo (isso quebraria a 3ª Forma Normal: ver
-- docs/guia_apresentacao.md, pergunta 1).
-- ---------------------------------------------------------------------
SELECT
    b.bloco_letra || s.andar_letra || s.sala_numero AS codigo_sala,
    s.sala_tipo,
    th.dia_semana,
    th.faixa
FROM tb_turma_horario th
RIGHT JOIN tb_sala s ON s.id_sala = th.sala_id
JOIN tb_bloco b       ON b.id_bloco = s.bloco_id
ORDER BY codigo_sala;


-- ---------------------------------------------------------------------
-- Consulta 10 — subconsulta correlacionada + agregação: alunos cuja
-- média, no período mais recente em que têm nota, está ACIMA da
-- média geral da turma correspondente (acima da própria turma).
-- ---------------------------------------------------------------------
SELECT a.aluno_nome, t.turma_codigo, h.media_final_gerado, media_turma.media
FROM tb_historico h
JOIN tb_matricula m ON m.id_matricula = h.matricula_id
JOIN tb_aluno a     ON a.id_aluno = m.aluno_id
JOIN tb_turma t     ON t.id_turma = m.turma_id
JOIN (
    SELECT m2.turma_id, round(avg(h2.media_final_gerado), 2) AS media
    FROM tb_historico h2
    JOIN tb_matricula m2 ON m2.id_matricula = h2.matricula_id
    WHERE h2.media_final_gerado IS NOT NULL
    GROUP BY m2.turma_id
) AS media_turma ON media_turma.turma_id = t.id_turma
WHERE h.media_final_gerado > media_turma.media
ORDER BY t.turma_codigo, h.media_final_gerado DESC;
