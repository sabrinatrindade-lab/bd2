-- =====================================================================
-- BANCO DE DADOS II  ·  CCO072  ·  IESB  ·  2026/2
-- aluna : Sabrina Borges da Trindade 
--
-- Marco 1: tipos de dados, domínios, enumerações, restrições EXCLUDE
-- 
--
-- Testado em PostgreSQL 16.
-- Requer: CREATE EXTENSION btree_gist;
-- =====================================================================

DROP SCHEMA IF EXISTS academico CASCADE;
CREATE SCHEMA academico;
SET search_path TO academico, public;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TYPE turno_t       AS ENUM ('MATUTINO','VESPERTINO','NOTURNO');
CREATE TYPE tipo_disc_t   AS ENUM ('OBRIGATORIA','OPTATIVA');
CREATE TYPE vinculo_t     AS ENUM ('PRE_REQUISITO','CO_REQUISITO');
CREATE TYPE status_mat_t  AS ENUM ('MATRICULADO','TRANCADO','CANCELADO');
CREATE TYPE situacao_t    AS ENUM ('CURSANDO','APROVADO','REPROVADO_NOTA','REPROVADO_FALTA');
CREATE TYPE tipo_sala_t   AS ENUM ('TEORICA','LABORATORIO');

CREATE DOMAIN nota_t AS numeric(4,2) CHECK (VALUE >= 0 AND VALUE <= 10);
CREATE DOMAIN pct_t  AS numeric(5,2) CHECK (VALUE >= 0 AND VALUE <= 100);

-- faixa de horário: exercita tipos de intervalo e restrições EXCLUDE
CREATE TYPE timerange AS RANGE (subtype = time);