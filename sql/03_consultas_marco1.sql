SELECT id_aluno, aluno_matricula, aluno_nome, aluno_ativo
FROM tb_aluno
ORDER BY id_aluno
LIMIT 10;


SELECT t.turma_codigo, d.disciplina_nome, p.professor_nome, t.turno, t.vagas
FROM tb_turma t
INNER JOIN tb_disciplina d ON d.id_disciplina = t.disciplina_id
INNER JOIN tb_professor p  ON p.id_professor = t.professor_id
INNER JOIN tb_periodo_letivo pl ON pl.id_periodo_letivo = t.periodo_letivo_id
WHERE pl.ano = 2026 AND pl.semestre = 2
ORDER BY t.turma_codigo;


SELECT d.disciplina_nome, count(m.id_matricula) AS total_matriculados
FROM tb_matricula m
JOIN tb_turma t      ON t.id_turma = m.turma_id
JOIN tb_disciplina d ON d.id_disciplina = t.disciplina_id
GROUP BY d.disciplina_nome
HAVING count(m.id_matricula) > 50
ORDER BY total_matriculados DESC;


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


WITH RECURSIVE arvore_prerequisitos AS (
    SELECT d.id_disciplina, d.disciplina_nome, 0 AS nivel
    FROM tb_disciplina d
    WHERE d.disciplina_codigo = 'BD2'

    UNION ALL

    SELECT req.id_disciplina, req.disciplina_nome, ap.nivel + 1
    FROM arvore_prerequisitos ap
    JOIN tb_prerequisito pr ON pr.disciplina_id = ap.id_disciplina
    JOIN tb_disciplina req  ON req.id_disciplina = pr.requisito_id
)
SELECT DISTINCT nivel, disciplina_nome
FROM arvore_prerequisitos
ORDER BY nivel, disciplina_nome;


WITH RECURSIVE todos_prerequisitos AS (
    SELECT disciplina_id, requisito_id
    FROM tb_prerequisito

    UNION

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
        SELECT 1
        FROM todos_prerequisitos tp
        WHERE tp.disciplina_id = d.id_disciplina
          AND tp.requisito_id NOT IN (SELECT disciplina_id FROM aprovadas_do_aluno)
  )
ORDER BY d.disciplina_codigo;


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
WHERE m.turma_id = 7
  AND h.media_final_gerado IS NOT NULL
ORDER BY posicao_ranking;


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


SELECT
    b.bloco_letra || s.andar_letra || s.sala_numero AS codigo_sala,
    s.sala_tipo,
    th.dia_semana,
    th.faixa
FROM tb_turma_horario th
RIGHT JOIN tb_sala s ON s.id_sala = th.sala_id
JOIN tb_bloco b       ON b.id_bloco = s.bloco_id
ORDER BY codigo_sala;


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
