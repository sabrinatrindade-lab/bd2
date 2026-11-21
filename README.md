# Sistema de Matrícula Acadêmica — Projeto de Banco de Dados II (IESB, 2026/2)

Projeto acadêmico da disciplina **Banco de Dados II (CCO072)**, baseado
no modelo relacional fornecido pelo professor (sistema de matrícula de
um centro universitário: cursos, currículos, disciplinas com
pré-requisitos, turmas, alunos, matrículas e histórico).

## Estrutura do repositório

```
.
├── README.md                     <- este arquivo
├── AUTORES.md                    <- os nomes do grupo
├── sql/
│   ├── 00_tipos_dominios.sql     <- ENUM, DOMAIN, RANGE
│   ├── 01_ddl.sql                <- todas as tabelas e restrições
│   ├── 02_carga_dados.sql        <- dados de exemplo (150 alunos, 16 turmas, 600+ matrículas)
│   └── 03_consultas_marco1.sql   <- as 10 consultas exigidas no Marco 1
