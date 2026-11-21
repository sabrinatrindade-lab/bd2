-- =====================================================================
-- 00_tipos_dominios.sql
-- Tipos criados pelo grupo antes das tabelas: ENUM, DOMAIN e RANGE.
--
-- Por que isso existe (para a arguição):
--   - ENUM: usamos quando o conjunto de valores possíveis é FIXO e
--     conhecido de antemão (ex.: um turno só pode ser matutino,
--     vespertino ou noturno). Isso é mais seguro que um varchar livre,
--     porque o próprio banco rejeita um valor fora da lista.
--   - DOMAIN: usamos quando a MESMA regra de validação (CHECK) se
--     repete em várias colunas/tabelas. Em vez de reescrever o CHECK
--     em cada tabela, criamos um tipo com nome (ex.: nota_t) que já
--     carrega a regra "entre 0 e 10".
--   - RANGE: o modelo pede uma única coluna "faixa" guardando início e
--     fim de um horário de aula. O PostgreSQL não tem um range de
--     "time" pronto (só tem int4range, numrange, tsrange, daterange,
--     etc.), então criamos o nosso: timerange.
--
-- Execute este arquivo primeiro: 01_ddl.sql depende destes tipos.
-- =====================================================================

-- ---------------------------------------------------------------------
-- ENUMs
-- ---------------------------------------------------------------------
CREATE TYPE tipo_sala_t AS ENUM ('sala de aula', 'laboratorio', 'auditorio', 'outro');
CREATE TYPE status_curriculo_t AS ENUM ('ativo', 'inativo');
CREATE TYPE turno_t AS ENUM ('matutino', 'vespertino', 'noturno');
CREATE TYPE status_mat_t AS ENUM ('ativa', 'cancelada', 'trancada', 'concluida');
CREATE TYPE situacao_t AS ENUM ('cursando', 'aprovado', 'reprovado');
CREATE TYPE vinculo_t AS ENUM ('obrigatorio', 'recomendado', 'co-requisito');
CREATE TYPE tipo_disc_t AS ENUM ('obrigatoria', 'optativa', 'eletiva');

-- ---------------------------------------------------------------------
-- RANGE (tipo de intervalo) para o horário de uma aula.
-- Guarda, em UMA coluna, o horário de início (inclusivo) e de término
-- (exclusivo) de uma aula. Ex.: '[08:00, 09:40)'.
-- ---------------------------------------------------------------------
CREATE TYPE timerange AS RANGE (subtype = time);

-- ---------------------------------------------------------------------
-- DOMAINs (apelidos de tipo + regra de validação embutida)
-- ---------------------------------------------------------------------

-- nota_t: qualquer nota do projeto (A1, A2 ou P3) tem que estar entre
-- 0 e 10, com até duas casas decimais.
CREATE DOMAIN nota_t AS numeric(4,2)
    CHECK (VALUE >= 0 AND VALUE <= 10);

-- pct_t: percentuais (hoje usado só para frequência) entre 0 e 100.
CREATE DOMAIN pct_t AS numeric(5,2)
    CHECK (VALUE >= 0 AND VALUE <= 100);

COMMENT ON DOMAIN nota_t IS 'Nota de avaliação (A1/A2/P3): numeric(4,2) restrito a [0,10].';
COMMENT ON DOMAIN pct_t  IS 'Percentual (ex.: frequência): numeric(5,2) restrito a [0,100].';
