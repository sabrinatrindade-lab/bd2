CREATE TYPE tipo_sala_t AS ENUM ('sala de aula', 'laboratorio', 'auditorio', 'outro');
CREATE TYPE status_curriculo_t AS ENUM ('ativo', 'inativo');
CREATE TYPE turno_t AS ENUM ('matutino', 'vespertino', 'noturno');
CREATE TYPE status_mat_t AS ENUM ('ativa', 'cancelada', 'trancada', 'concluida');
CREATE TYPE situacao_t AS ENUM ('cursando', 'aprovado', 'reprovado');
CREATE TYPE vinculo_t AS ENUM ('obrigatorio', 'recomendado', 'co-requisito');
CREATE TYPE tipo_disc_t AS ENUM ('obrigatoria', 'optativa', 'eletiva');

CREATE TYPE timerange AS RANGE (subtype = time);

CREATE DOMAIN nota_t AS numeric(4,2)
    CHECK (VALUE >= 0 AND VALUE <= 10);

CREATE DOMAIN pct_t AS numeric(5,2)
    CHECK (VALUE >= 0 AND VALUE <= 100);
