# Autores e responsabilidades

> Preencha os nomes reais do grupo. Como o professor reduziu o escopo
> do projeto para o conteúdo de Banco de Dados I (sem índices,
> transações, segurança ou backup), a divisão abaixo é mais simples do
> que a do edital original — mas a arguição é **individual**, então
> todos devem entender o projeto inteiro, não só a própria parte.

| Integrante | Frente (responsabilidade principal) | Arquivos principais |
|---|---|---|
| `<NOME 1>` | **Modelagem (DDL)** — tabelas, tipos, domínios, chaves e restrições de integridade | `sql/00_tipos_dominios.sql`, `sql/01_ddl.sql` |
| `<NOME 2>` | **Carga de dados** — geração da massa de dados de exemplo (alunos, turmas, matrículas, histórico) | `sql/02_carga_dados.sql` |
| `<NOME 3>` | **Consultas** — as 10 consultas de complexidade crescente exigidas no Marco 1 | `sql/03_consultas_marco1.sql` |

O guia de preparação para a arguição (`docs/guia_apresentacao.md`) é
responsabilidade **compartilhada** — todos devem revisar e conseguir
explicar qualquer um dos pontos nele, já que o professor pode
perguntar qualquer coisa da lista para qualquer integrante.

## Sobre o histórico de commits

O edital avalia o histórico de commits do Git (entrega em commit único
ou concentrada em uma só pessoa na véspera é penalizada). Então, ao
subir este projeto (veja o `README.md`), cada integrante deve:

1. Clonar o repositório para a própria máquina.
2. Fazer os commits da **própria frente** com o **próprio usuário do
   Git** (`git config user.name` / `git config user.email`), em
   momentos diferentes ao longo dos dias — não tudo de uma vez.
3. Revisar (e, se possível, comentar/ajustar) a frente de pelo menos
   um colega antes da apresentação.
