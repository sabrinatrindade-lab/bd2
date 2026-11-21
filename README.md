# Sistema de Matrícula Acadêmica — Projeto de Banco de Dados II (IESB, 2026/2)

Projeto acadêmico da disciplina **Banco de Dados II (CCO072)**, baseado
no modelo relacional fornecido pelo professor (sistema de matrícula de
um centro universitário: cursos, currículos, disciplinas com
pré-requisitos, turmas, alunos, matrículas e histórico).

> **Nota de contexto:** o professor sinalizou em aula que, por a turma
> estar atrasada no conteúdo de BD2, a **arguição individual** vai
> cobrar principalmente conteúdo de **Banco de Dados I** (modelagem,
> formas normais, tipos de dado, joins), e que os tópicos
> exclusivamente de BD2 — **índices, transações/concorrência,
> segurança (roles/RLS) e backup/restauração** — não precisam ser
> implementados neste momento. Por isso este repositório contém **só**
> o "banco de dados normal": modelagem (DDL), carga de dados e as
> consultas exigidas no Marco 1. Veja `docs/guia_apresentacao.md`, que
> foi montado em cima das perguntas que o professor anotou em aula.
> Confirmem com ele se algo mudar de novo.
>
> Uso de IA: o edital original autoriza expressamente o uso de
> ferramentas de IA para escrever/revisar o código. O que **precisa**
> ser individual é a defesa na arguição — por isso todo o conteúdo
> teórico necessário para responder às perguntas do professor **sem
> depender de IA no dia** está consolidado em
> `docs/guia_apresentacao.md`. Estudem esse arquivo até conseguirem
> explicar cada ponto com as próprias palavras.

## Estrutura do repositório

```
.
├── README.md                     <- este arquivo
├── AUTORES.md                    <- preencham com os nomes do grupo
├── sql/
│   ├── 00_tipos_dominios.sql     <- ENUM, DOMAIN, RANGE
│   ├── 01_ddl.sql                <- todas as tabelas e restrições
│   ├── 02_carga_dados.sql        <- dados de exemplo (150 alunos, 16 turmas, 600+ matrículas)
│   └── 03_consultas_marco1.sql   <- as 10 consultas exigidas no Marco 1
└── docs/
    └── guia_apresentacao.md      <- respostas às perguntas da arguição (ler antes da apresentação!)
```

## Pré-requisitos

- O ambiente **oficial** da disciplina: o contêiner Docker com
  **PostgreSQL 17** fornecido pelo professor na primeira aula.
- Acesso a `psql` (já vem dentro do contêiner) e a `docker` instalado
  na máquina de quem for apresentar.
- Git instalado, e uma conta no GitHub.

Se preferir testar localmente antes de usar o contêiner do curso, o
`docker-compose` mais simples possível seria:

```yaml
services:
  bd2-postgres:
    image: postgres:17
    container_name: bd2-postgres
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
```

## Como subir o banco do zero (ordem de execução)

Os arquivos em `sql/` são numerados **na ordem exata** em que devem
ser executados — cada um depende do anterior.

```bash
# 1) Suba o contêiner do curso (ou o docker-compose acima) e crie o banco:
docker exec -it bd2-postgres psql -U postgres -c "CREATE DATABASE matricula_academica;"

# 2) Rode cada script, na ordem, DENTRO do banco criado:
for arquivo in sql/00_tipos_dominios.sql \
               sql/01_ddl.sql \
               sql/02_carga_dados.sql; do
    echo ">> Executando $arquivo"
    docker exec -i bd2-postgres psql -U postgres -d matricula_academica < "$arquivo"
done

# 3) Rode as consultas do Marco 1 (saída fica no terminal):
docker exec -i bd2-postgres psql -U postgres -d matricula_academica < sql/03_consultas_marco1.sql
```

## Conferindo que deu tudo certo

Depois do passo 2 acima, rode:

```sql
SELECT
    (SELECT count(*) FROM tb_aluno)     AS total_alunos,
    (SELECT count(*) FROM tb_turma)     AS total_turmas,
    (SELECT count(*) FROM tb_matricula) AS total_matriculas;
```

Esperado: `total_alunos >= 100`, `total_turmas >= 6`,
`total_matriculas >= 300` (o script de carga gera bem mais que o
mínimo, de propósito, para a amostra ficar mais rica).

## Como publicar este projeto no GitHub

Passo a passo para quem nunca fez isso:

1. **Crie o repositório no GitHub** (pelo site, github.com → botão
   "New repository"). Dê um nome (ex.: `bd2-projeto-matricula`),
   marque como **público** (ou privado, dando acesso ao professor nas
   configurações do repositório → *Settings → Collaborators*) e
   **não** marque a opção de criar `README` automaticamente (já
   temos um).

2. **No seu computador**, dentro da pasta deste projeto:
   ```bash
   git init
   git add .
   git commit -m "Estrutura inicial do projeto: DDL, tipos e carga de dados"
   ```

3. **Ligue sua pasta local ao repositório do GitHub** (troque
   `SEU-USUARIO` e o nome do repositório pelos seus):
   ```bash
   git branch -M main
   git remote add origin https://github.com/SEU-USUARIO/bd2-projeto-matricula.git
   git push -u origin main
   ```

4. **Commits seguintes, um por entrega/frente** (não deixe tudo para
   o commit único da véspera — o edital penaliza isso):
   ```bash
   git add sql/03_consultas_marco1.sql
   git commit -m "Adiciona as 10 consultas do Marco 1"
   git push

   git add docs/guia_apresentacao.md
   git commit -m "Adiciona guia de preparação para a arguição"
   git push
   ```

5. **Cada integrante deve commitar com o próprio usuário**, não todo
   mundo usando a mesma conta. Configure uma vez por máquina:
   ```bash
   git config --global user.name  "Seu Nome"
   git config --global user.email "seu-email@exemplo.com"
   ```

6. **Dê acesso ao professor**, se o repositório for privado: no
   GitHub, vá em *Settings → Collaborators → Add people* e adicione o
   usuário/e-mail dele.

7. Antes da apresentação, **clone o repositório do zero** numa pasta
   vazia e rode o passo "Como subir o banco do zero" acima, para
   confirmar que o `README.md` realmente sobe o banco sem depender de
   nada que só existisse na sua máquina.

## Checklist final antes de apresentar

- [ ] `AUTORES.md` preenchido com os nomes reais e a frente de cada um.
- [ ] Clonou o repositório numa pasta vazia e refez todo o processo do
      zero, para garantir que não falta nada.
- [ ] Todos os integrantes leram `docs/guia_apresentacao.md` e
      conseguem explicar qualquer um dos pontos, não só o que
      estudaram primeiro (a arguição é individual e pode perguntar
      qualquer coisa da lista).
