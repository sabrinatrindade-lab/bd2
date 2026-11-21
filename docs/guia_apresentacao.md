# Guia para a arguição — respostas às perguntas anunciadas pelo professor

> Contexto: como o professor sinalizou em aula que, por causa do atraso
> da turma, a arguição vai cobrar principalmente conteúdo de **Banco de
> Dados I** (modelagem, formas normais, tipos de dado, SQL básico e
> joins) em vez do conteúdo avançado de BD2, este guia responde
> exatamente às perguntas que ele anotou em aula, **sempre amarrando a
> resposta teórica com um exemplo real deste projeto**. Leiam isso
> junto com `sql/01_ddl.sql` aberto ao lado — é mais fácil fixar vendo
> o código correspondente.

---

## 1) Formas normais (1FN, 2FN, 3FN): o que são, para que servem, como usamos aqui

**Para que servem, em geral:** são regras para organizar as tabelas de
forma a evitar redundância de dados e as chamadas "anomalias" de
inserção, atualização e remoção (ex.: ao atualizar um dado repetido em
10 linhas, esquecer de atualizar uma e deixar o banco inconsistente).

- **1ª Forma Normal (1FN):** cada coluna guarda um valor **atômico**
  (não uma lista), e não pode haver grupos de colunas repetidas (tipo
  `horario1`, `horario2`, `horario3`).
  → **No projeto:** uma turma pode ter mais de um horário na semana.
  Em vez de colunas repetidas em `tb_turma`, criamos `tb_turma_horario`,
  uma linha por horário. Isso é 1FN na prática.

- **2ª Forma Normal (2FN):** estar na 1FN **e** todo atributo
  não-chave depender da **chave primária inteira** (relevante só em
  tabelas com chave composta).
  → **No projeto:** `tb_curriculo_disciplina` tem chave composta
  `(curriculo_id, disciplina_id)`. O atributo `periodo` depende dos
  **dois** (o período em que aquela disciplina aparece **naquele**
  currículo específico) — por isso está correto ali. Se
  colocássemos `disciplina_nome` nessa tabela, violaria a 2FN (ele
  depende só de `disciplina_id`, metade da chave) — por isso
  `disciplina_nome` mora só em `tb_disciplina`.

- **3ª Forma Normal (3FN):** estar na 2FN **e** nenhum atributo
  não-chave pode depender de **outro atributo não-chave**
  (dependência transitiva).
  → **No projeto:** `tb_aluno` guarda `curso_id`, mas **não** guarda
  `curso_nome`. Se guardássemos, `curso_nome` dependeria de
  `curso_id`, que não é chave de `tb_aluno` — uma dependência
  transitiva, violando 3FN, e abrindo brecha para inconsistência se
  o nome do curso mudar e esquecermos de atualizar em todo aluno.

---

## 2) Cardinalidade: o que é, tipos, variações gráficas

**O que é:** descreve **quantas ocorrências** de uma entidade podem se
relacionar com quantas ocorrências de outra, através de um
relacionamento.

**Tipos (notação simplificada mais comum):**
- **1:1** — uma ocorrência de A se relaciona com no máximo uma de B.
- **1:N** — uma ocorrência de A se relaciona com várias de B, mas cada
  B se relaciona com apenas um A.
- **N:N** — várias ocorrências de A se relacionam com várias de B.

Também existe a notação **completa (mín,máx)**, que separa
cardinalidade **mínima** (o relacionamento é obrigatório — `1` — ou
opcional — `0`?) da **máxima** (`1` ou `N`). Ex.: `(0,N)` do lado de
`tb_matricula` em relação a `tb_turma` significa "uma turma pode ter
zero ou várias matrículas".

**Variações gráficas mais conhecidas:**
- **Chen (clássica):** losangos para relacionamentos, elipses para
  atributos, retângulos para entidades; cardinalidade escrita como
  texto perto da linha.
- **Pé-de-galinha (crow's foot):** símbolos na ponta da linha (um
  traço = "1", um "pé de galinha" aberto = "N", um círculo = "0"
  opcional). É a notação mais usada hoje em ferramentas como o
  draw.io/MySQL Workbench.
- **IDEF1X** e **UML (diagrama de classes)**: variações mais formais,
  comuns em modelagem corporativa, com multiplicidade escrita como
  `0..1`, `1..*` etc.

O diagrama que o professor forneceu usa anotações textuais do tipo
`N : 1` ao lado das linhas, que é uma simplificação direta da ideia do
pé-de-galinha.

---

## 3) Como se faz relacionamento entre duas (ou mais) entidades

**No modelo conceitual (DER):** desenha-se uma linha (ou um losango,
na notação de Chen) ligando as entidades, nomeando o relacionamento
com um verbo (ex.: "Aluno **MATRICULA-SE EM** Turma") e anotando a
cardinalidade de cada lado.

**No modelo lógico/relacional (como viramos tabela de verdade):**
- Relacionamento **1:N** → a **chave estrangeira (FK)** vai do lado
  "N" (muitos) apontando para a chave primária do lado "1".
  Ex.: `tb_turma.professor_id` aponta para `tb_professor.id_professor`
  (1 professor pode dar N turmas).
- Relacionamento **N:N** → precisa de uma **tabela associativa** à
  parte (ver pergunta 11 abaixo).
- Relacionamento **1:1** → a FK pode ir em qualquer um dos dois lados
  (normalmente no lado que é "opcional", se um dos dois for
  opcional).

**Relacionamento entre mais de duas entidades (ternário):** é
tecnicamente possível, mas neste projeto evitamos — preferimos sempre
decompor em relacionamentos **binários** (dois a dois), porque um
relacionamento ternário geralmente esconde duas dependências binárias
e deixa a modelagem mais difícil de entender e manter.

---

## 4) Sentido de leitura das cardinalidades

A cardinalidade anotada **perto de uma entidade** descreve quantas
ocorrências **daquela entidade** participam do relacionamento — ou
seja, ela é lida "de fora para dentro": para não errar, monte sempre a
frase completa:

> "**Uma** ocorrência de **[entidade do lado oposto à anotação]** se
> relaciona com **[cardinalidade anotada]** ocorrência(s) de
> **[entidade perto da anotação]**."

**Exemplo do projeto:** entre `tb_turma` e `tb_matricula`, a anotação
"N" fica perto de `tb_matricula` e "1" perto de `tb_turma`. Lendo:
"uma turma (1) se relaciona com N matrículas" — e no sentido inverso,
"uma matrícula se relaciona com exatamente 1 turma".

> Observação honesta para a arguição: alguns professores descrevem
> essa leitura como "sentido horário" ou "anti-horário" quando o
> diagrama está desenhado em formato de losango/círculo — isso varia
> um pouco de autor para autor e de como o diagrama está disposto na
> tela. O que **não muda** é a regra acima (a cardinalidade descreve a
> entidade mais próxima dela). Se o professor usar um termo
> específico de "sentido", vale perguntar a ele qual convenção exata
> ele está usando no material da disciplina, e aplicar a regra escrita
> acima para confirmar a leitura.

---

## 5) Exemplo (cardinalidade + relacionamento, de ponta a ponta)

Veja o relacionamento **Aluno — Turma** (via `tb_matricula`):

- Conceitualmente: "Aluno **SE MATRICULA EM** Turma", cardinalidade
  N:N (um aluno cursa várias turmas ao longo do curso; uma turma tem
  vários alunos).
- Logicamente: como é N:N, vira uma tabela associativa,
  `tb_matricula`, com `aluno_id` e `turma_id` como chaves
  estrangeiras, e `UNIQUE (aluno_id, turma_id)` garantindo que o
  **mesmo** aluno não se matricule duas vezes na **mesma** turma.
- Fisicamente (PostgreSQL): é a tabela `tb_matricula` em
  `sql/01_ddl.sql`, com os tipos exatos (`integer`, `timestamptz`,
  `status_mat_t`) e a constraint nomeada `uk_matricula_aluno_turma`.

---

## 6) Modelo lógico: antes ou depois do conceitual? Diferenças

**Ordem correta:** **Conceitual → Lógico → Físico.** O lógico vem
**depois** do conceitual, porque cada etapa refina/detalha a anterior.

| Etapa | O que tem | O que NÃO tem |
|---|---|---|
| **Conceitual (DER)** | Entidades, relacionamentos, atributos, cardinalidades — a visão de negócio | Tipos de dado, FK explícita, nada de SQL |
| **Lógico** | Tabelas, chaves primárias e estrangeiras já definidas; N:N já resolvido em tabela associativa | Ainda é independente do SGBD (não é "sintaxe de Postgres") |
| **Físico** | Implementação real NUM banco específico: tipos exatos (`varchar(120)`, `smallint`...), índices, schemas, DDL executável | — |

**No nosso caso:** o professor **já forneceu o modelo lógico** (o PDF
`modelo_banco_dados_2_drawio`), e o trabalho do grupo foi transformar
esse lógico em **físico** — é exatamente `sql/01_ddl.sql`.

---

## 7) Entidade: o que é, tipos, elementos gráficos, quando usar

**O que é:** algo do mundo real (ou abstrato) sobre o qual queremos
guardar informação, com existência própria e identificável
individualmente (ex.: Aluno, Turma, Disciplina).

**Tipos:**
- **Forte:** tem existência independente e chave primária própria.
  Ex.: `tb_aluno`, `tb_professor`.
- **Fraca:** só existe se a entidade "dona" existir; não tem
  significado sozinha. Ex.: `tb_turma_horario` só faz sentido como
  parte de uma `tb_turma`.
- **Associativa:** nasce para resolver um relacionamento N:N, e
  "mora" entre duas (ou mais) outras entidades. Ex.: `tb_matricula`,
  `tb_curriculo_disciplina`, `tb_prerequisito`.

**Elementos gráficos:** na notação de Chen, entidade forte = retângulo
de linha simples; entidade fraca = retângulo de linha **dupla**. Nas
notações mais modernas (pé-de-galinha, usada no diagrama do
professor), geralmente todas as entidades aparecem como uma caixa
simples com o nome da tabela no topo e os atributos listados dentro,
sem diferenciar visualmente forte/fraca pela borda.

**Quando criar uma entidade:** sempre que um "substantivo" do domínio
precisa de atributos próprios e pode ser referenciado de forma
independente por outras partes do sistema (ex.: Professor existe mesmo
quando, num dado momento, não está dando nenhuma turma).

---

## 8) Atributos: o que são, tipos, elementos gráficos, quando usar

**O que são:** as características/propriedades de uma entidade (ex.:
`aluno_nome`, `aluno_cpf` são atributos de Aluno).

**Tipos:**
- **Simples (atômico):** não pode ser dividido. Ex.: `aluno_cpf`.
- **Composto:** pode ser dividido em partes menores. Ex.: um
  "endereço" poderia virar rua + número + cidade; aqui simplificamos
  e guardamos `campus_endereco` como um único `varchar`.
- **Monovalorado:** um único valor por ocorrência. Ex.:
  `aluno_nascimento`.
- **Multivalorado:** pode ter vários valores para a mesma ocorrência.
  No modelo relacional, isso **vira uma tabela à parte** — é
  exatamente o caso de `tb_turma_horario` (vários horários por
  turma).
- **Chave (identificador):** identifica unicamente cada ocorrência.
  Ex.: `id_aluno`.
- **Derivado:** seu valor pode ser **calculado** a partir de outros
  atributos em vez de guardado "manualmente". No PostgreSQL isso vira
  **coluna gerada** (`GENERATED ALWAYS AS ... STORED`) — usamos em
  `ch_total_gerado` (= `ch_teorica + ch_pratica`) e
  `media_final_gerado` (calculado a partir das notas). *Atenção:* um
  atributo derivado só pode virar coluna gerada quando depende **só de
  colunas da própria tabela**. O "código da sala" (ex.: `IA4`) também é
  derivado, mas depende de `bloco_letra`, que mora em **outra tabela**
  (`tb_bloco`) — por isso ele não é coluna nenhuma, e sim calculado
  numa consulta (`JOIN`) sempre que precisamos dele.

**Elementos gráficos (Chen):** atributos são elipses ligadas à
entidade; atributo **chave** tem o nome **sublinhado**; atributo
**multivalorado** usa elipse de linha dupla; atributo **composto** tem
elipses "filhas" penduradas numa elipse "mãe". Em notações modernas
(crow's foot), os atributos aparecem como uma lista simples de linhas
dentro da caixa da entidade — igual ao diagrama do professor.

**Quando vira atributo x quando vira entidade:** todo dado que
descreve diretamente **uma** entidade, sem repetir em quantidade
variável e sem se relacionar com mais nada, é atributo. Quando esse
dado começa a "ter vida própria" (repetir, se relacionar, ter seus
próprios atributos), ele deve ser promovido a entidade — foi o caso
do horário de turma.

---

## 9) Dez tipos de dado do PostgreSQL, e quando usar cada um

| # | Tipo | Quando usar | Exemplo no projeto |
|---|------|-------------|---------------------|
| 1 | `integer` / `smallint` / `bigint` | Números inteiros; escolha o tamanho pela ordem de grandeza esperada | `id_aluno integer`, `id_periodo_letivo smallint` (poucos períodos existirão), `id_log_matricula bigint` (log cresce sem parar) |
| 2 | `numeric(p,s)` | Números decimais **exatos**, sem erro de arredondamento — sempre para dinheiro e notas (nunca usar `float`/`double precision` para isso) | domínio `nota_t` = `numeric(4,2)` |
| 3 | `varchar(n)` | Texto de tamanho **variável**, até um limite | `aluno_nome varchar(120)` |
| 4 | `char(n)` | Texto de tamanho **fixo**, sempre com n caracteres | `aluno_cpf char(11)`, `estado_sigla char(2)` |
| 5 | `text` | Texto livre, sem limite de tamanho definido | `disciplina_ementa text` |
| 6 | `boolean` | Verdadeiro/falso | `aluno_ativo boolean` |
| 7 | `date` | Só data, sem hora (quando o horário não importa) | `aluno_nascimento date` |
| 8 | `timestamptz` | Data **e** hora, **com fuso horário** — evita ambiguidade sobre em qual fuso o dado foi gravado | `data_matricula timestamptz` |
| 9 | `jsonb` | Dado semiestruturado, quando a "forma" do dado varia de linha para linha e não compensa criar uma coluna fixa para cada possibilidade | `tb_log_matricula.detalhe jsonb` |
| 10 | `ENUM` (tipo criado pelo grupo) | Conjunto de valores **fixo e pequeno**, conhecido de antemão — o próprio banco rejeita valor fora da lista | `turno_t` (`matutino`/`vespertino`/`noturno`) |

*(Bônus, se perguntarem por um 11º tipo): `RANGE` — guarda um
intervalo (início + fim) em uma única coluna, com a garantia de que o
início é menor que o fim. Criamos nosso próprio range de horário,
`timerange`, usado em `tb_turma_horario.faixa`.*

---

## 10) Quais alterações o grupo fez no projeto original, e por quê

| Alteração | Por quê |
|---|---|
| Removido o bloco inteiro de **índices, transações/concorrência, segurança (RLS) e backup/restauração** (a parte de "Administração" do Marco 2) | O professor ajustou o foco da disciplina para conteúdo de Banco de Dados I, dado o atraso da turma. O grupo manteve apenas modelagem (DDL) e consultas — que seguem sendo exigidas e são o que realmente cai na arguição. |
| Estrutura física simplificada: sem tabela separada de `prédio`; `tb_bloco` guarda a **letra do bloco** (A a L) e `tb_sala` guarda **andar** (letra, A a C) e **número da sala** (1 a 20) | Reflete o padrão real de identificação de salas do IESB (ex.: "IA4" = Bloco I, Andar A, Sala 4). Um prédio separado do bloco não existe nesse padrão — manter as duas tabelas só adicionaria uma entidade sem uso real. |
| O "código da sala" (ex.: `IA4`) **não** é uma coluna guardada, nem uma coluna gerada — é montado numa consulta, juntando `tb_bloco.bloco_letra` com `tb_sala.andar_letra` e `tb_sala.sala_numero` | Uma coluna gerada só pode usar dados da **própria linha**; como a letra do bloco mora em **outra tabela**, duplicar esse dado dentro de `tb_sala` quebraria a 3ª Forma Normal (ver pergunta 1). A forma correta é calcular via `JOIN` (ver Consulta 9 em `sql/03_consultas_marco1.sql`). |
| `dia_semana` virou `smallint` + `CHECK (BETWEEN 1 AND 7)` em vez de um ENUM `dia_semana_t` | Um ENUM do Postgres é mais trabalhoso de alterar depois (remover um valor, por exemplo, não é trivial). Para algo simples como "um número de 1 a 7", um `CHECK` é mais direto e igualmente seguro. |
| `faixa` virou um tipo `RANGE` customizado (`timerange`) em vez de duas colunas (`hora_inicio`, `hora_fim`) | O tipo RANGE já embute, por construção, a regra "fim > início" — uma restrição a menos para escrever (e esquecer de escrever) manualmente. |
| `ch_total_gerado` e `media_final_gerado` viraram **colunas geradas** | Evita que a carga horária total ou a média final fiquem desatualizadas/inconsistentes caso alguém esqueça de recalcular na aplicação. |
| Domínios `nota_t` e `pct_t` | Reaproveitam a mesma regra de validação (entre 0–10, entre 0–100) em várias colunas sem repetir o `CHECK` cada vez. |

---

## 11) Relação N:N: o que deve ser feito, por quê, exemplo do projeto

**Problema:** uma chave estrangeira (FK) só consegue apontar para
**um** registro do outro lado — ela resolve naturalmente um 1:N, mas
**não** consegue representar um N:N sozinha.

**Solução:** criar uma **terceira tabela** (tabela associativa / tabela
de junção), cuja chave primária é **composta pelas duas chaves
estrangeiras** (uma para cada entidade original). Essa tabela também
pode carregar atributos que só fazem sentido quando as duas entidades
estão ligadas.

**Exemplos do projeto:**
- `tb_matricula` resolve o N:N entre **Aluno** e **Turma** (um aluno
  cursa várias turmas; uma turma tem vários alunos); carrega o
  atributo próprio `data_matricula`.
- `tb_curriculo_disciplina` resolve o N:N entre **Currículo** e
  **Disciplina**; carrega `periodo` e `tipo` como atributos do
  relacionamento.
- `tb_prerequisito` é um caso especial: um **auto-relacionamento**
  N:N da entidade Disciplina com **ela mesma** (uma disciplina pode
  exigir várias outras como pré-requisito, e também pode ser
  pré-requisito de várias outras).

---

## 12) SQL: selecionar 10 registros da tabela de alunos

Veja a **Consulta 1** em `sql/03_consultas_marco1.sql`:

```sql
SELECT id_aluno, aluno_matricula, aluno_nome, aluno_ativo
FROM tb_aluno
ORDER BY id_aluno
LIMIT 10;
```

---

## 13) Todas as consultas exigidas no projeto acadêmico

Estão **todas** em `sql/03_consultas_marco1.sql`, numeradas e
comentadas. Resumo de onde está cada exigência do edital:

| Exigência do edital | Consulta no arquivo |
|---|---|
| Junção externa com agregação | Consulta 4 |
| Recursiva: árvore de pré-requisitos | Consulta 5 |
| Recursiva: disciplinas que o aluno já pode cursar | Consulta 6 |
| Janela com ranking e percentil | Consulta 7 |
| Janela com LAG (evolução do rendimento) | Consulta 8 |

As Consultas 1, 2, 3, 9 e 10 completam as "10 consultas de
complexidade crescente" pedidas, exercitando `SELECT` simples,
`INNER JOIN`, `GROUP BY`/`HAVING`, `RIGHT JOIN` e subconsulta
correlacionada.

---

## 14) JOINs: INNER, LEFT e RIGHT — explicação e exemplos

- **INNER JOIN:** retorna só as linhas que têm correspondência **nas
  duas** tabelas. Se não casar dos dois lados, a linha não aparece.
  → Consulta 2: turma + disciplina + professor (só aparecem turmas com
  disciplina e professor vinculados — que é sempre o caso aqui, pois
  são colunas `NOT NULL`).

- **LEFT JOIN (= LEFT OUTER JOIN):** retorna **todas** as linhas da
  tabela da **esquerda**, mesmo sem correspondência na direita (os
  campos da direita vêm como `NULL` quando não há correspondência).
  → Consulta 4: `tb_turma LEFT JOIN tb_matricula` — aparecem turmas
  mesmo que ainda não tenham nenhuma matrícula (ficaria com
  `ocupadas = 0`).

- **RIGHT JOIN (= RIGHT OUTER JOIN):** o espelho do LEFT JOIN —
  retorna **todas** as linhas da tabela da **direita**, mesmo sem
  correspondência na esquerda.
  → Consulta 9: `tb_turma_horario RIGHT JOIN tb_sala` — aparecem
  **todas** as salas, inclusive as que não têm nenhum horário de
  turma marcado ainda.

- *(Bônus) **FULL JOIN:*** combina LEFT + RIGHT — traz tudo dos dois
  lados, preenchendo com `NULL` o que não tiver correspondência.

> Dica prática: `A LEFT JOIN B` é sempre equivalente a
> `B RIGHT JOIN A` — são a mesma informação, só muda qual tabela vem
> escrita primeiro.
