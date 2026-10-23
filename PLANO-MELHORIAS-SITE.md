# Plano de melhorias estéticas e funcionais

**Site:** Biodiversity Synthesis Lab — <https://provetelab.org/>  
**Status:** proposta de trabalho; este documento não implementa as mudanças.  
**Contexto:** continuidade da auditoria e das correções técnicas P1, P2 e P3.

O objetivo é apresentar a pesquisa do laboratório com mais clareza e facilitar
o acesso a publicações, disciplinas e materiais. A prioridade editorial é
**tornar previsível a escolha do idioma em cada parte do site**.

Preservar a identidade existente: fundo creme, azul-petróleo, logotipo e
fotografias de campo. As mudanças devem melhorar hierarquia, legibilidade e
navegação, mantendo a estrutura estática em Quarto.

## 1. Prioridade transversal: ajustar os idiomas

> **O ajuste de idiomas deve orientar a primeira entrega.** Corrigir o atributo
> `lang` foi uma etapa técnica já realizada; ainda é necessário alinhar o idioma
> dos textos, da interface, dos metadados e dos caminhos de navegação.
>
> **Direção proposta:** inglês para a comunicação institucional internacional;
> português brasileiro para ensino e materiais destinados aos alunos.

### 1.1. Situação atual e distinções importantes

- O projeto declara `lang: en` como padrão.
- As disciplinas em `teaching/` herdam `lang: pt-BR` de `_metadata.yml`.
- Na validação da P2, foram verificadas 77 páginas em português e 30 em inglês.
- A página principal de Teaching ainda apresenta o catálogo em inglês.
- Declarar `lang: pt-BR` não traduz textos escritos explicitamente no menu,
  nos botões ou nas páginas. Esses componentes precisam de revisão editorial.

### 1.2. Política editorial proposta

| Área | Idioma principal | Tratamento proposto |
|---|---|---|
| Home, Research, Projects, Software, People e Publications | Inglês | Manter a comunicação internacional e padronizar os rótulos. |
| Catálogo de disciplinas | Português brasileiro | Apresentar cursos e materiais em português, com um resumo curto em inglês para visitantes internacionais. |
| Páginas de cursos e aulas | Português brasileiro | Revisar navegação, instruções, botões e mensagens no mesmo idioma do conteúdo. |
| Apresentação institucional resumida e contato | Português brasileiro, em páginas próprias | Criar uma entrada acessível ao público brasileiro sem exigir, inicialmente, a tradução integral do site. |
| Join us | Inglês | Oferecer instruções em português para estudantes brasileiros, organizadas em uma seção identificada ou na entrada em português. |
| Referências bibliográficas e nomes oficiais | Idioma original | Preservar títulos de trabalhos, periódicos, organizações e softwares. |

O resumo em inglês do catálogo deve ser separado do texto em português e
identificado semanticamente com `lang="en"`. Trechos em outro idioma nas demais
páginas devem receber tratamento equivalente quando necessário.

### 1.3. Navegação entre idiomas

1. Preservar as URLs atuais de cursos e aulas; mudar o idioma editorial não
   exige alterar os endereços.
2. Identificar o idioma dos materiais no catálogo e nos acessos institucionais
   que levam às disciplinas.
3. Usar rótulos claros, como **Português** e **English**, em vez de bandeiras.
4. Mostrar um seletor entre idiomas apenas quando existirem versões
   correspondentes da mesma página.
5. Se houver somente uma apresentação resumida em português, identificá-la
   como tal. Ela não deve aparentar ser uma tradução integral da página inglesa.
6. Localizar os controles de ensino: **Aula anterior**, **Próxima aula**,
   **Índice do curso**, **Slides**, **Exercícios**, **Dados** e **Leituras**.
7. Revisar os rótulos da navegação compartilhada. Se um link levar a uma página
   disponível apenas em inglês, deixar essa transição compreensível.
8. Não redirecionar automaticamente por idioma do navegador nem usar tradução
   automática como versão editorial publicada.

### 1.4. Metadados, busca e manutenção

- Revisar título da página, descrição, texto alternativo das imagens e mensagens
  de interface no idioma apropriado.
- Incluir as novas páginas no índice de busca e no mapa do site.
- Configurar `hreflang` apenas para versões de conteúdo efetivamente equivalentes;
  um resumo não deve ser declarado como tradução completa.
- Manter um endereço canônico adequado para cada página publicada.
- Definir uma fonte comum para informações repetidas, como contato e situação
  das oportunidades, evitando divergências entre idiomas.
- Ajustar o validador do site para reconhecer as futuras páginas institucionais
  em português: hoje ele espera português em `teaching/` e inglês fora dessa pasta.

### 1.5. Critérios de conclusão do ajuste de idiomas

- [ ] Catálogo de disciplinas revisado em português, com resumo identificado em inglês.
- [ ] Cursos e aulas com controles e instruções coerentes em português.
- [ ] Entrada institucional resumida em português e informações de contato disponíveis.
- [ ] Idioma dos destinos indicado nos pontos de transição relevantes.
- [ ] Seletores de idioma levam somente a versões existentes e correspondentes.
- [ ] `lang`, títulos e descrições conferidos nas páginas alteradas.
- [ ] URLs antigas preservadas e validador atualizado para a política adotada.
- [ ] Informações sobre contato e oportunidades consistentes entre as versões.

## 2. Melhorias por ordem de implementação

O esforço abaixo é relativo; não representa prazo fechado. O ajuste de idiomas
da seção anterior é transversal a todas as entregas.

| Ordem | Frente | Mudança concreta | Benefício | Esforço |
|---|---|---|---|---|
| 1 | Abertura da home | Reduzir a área do logotipo, apresentar uma frase curta sobre a pesquisa e destacar os acessos à pesquisa e aos materiais de ensino. | Explicar rapidamente o laboratório e orientar a primeira visita. | Pequeno |
| 2 | Publicações | Busca por título e autor; filtros por ano e tipo; ações textuais para PDF, DOI, dados e código; opção de copiar a referência. | Encontrar e utilizar a produção científica com menos esforço. | Médio |
| 3 | Catálogo de disciplinas | Cards com nível, idioma, carga horária, última oferta e tipos de material; filtros por graduação, pós-graduação e minicursos. | Facilitar a escolha do curso e o acesso aos materiais. | Médio |
| 4 | Pesquisa e projetos | Apresentar três linhas de pesquisa na home; conectar projetos às perguntas científicas, equipes, publicações e ferramentas relacionadas. | Mostrar a contribuição científica e a relação entre as páginas. | Médio |
| 5 | Padrão visual | Padronizar títulos, espaçamento, botões, cards, estados de interação e rótulos junto aos ícones. | Melhorar legibilidade e consistência. | Pequeno a médio |
| 6 | Navegação nas disciplinas | Caminho de navegação, aula anterior/próxima, retorno ao índice e identificação dos materiais disponíveis. | Ajudar o aluno a se orientar durante o estudo. | Médio |
| 7 | Equipe | Padronizar fotos, função, tema de pesquisa e links; criar perfis individuais quando houver conteúdo suficiente. | Apresentar melhor as pessoas e suas contribuições. | Pequeno a médio |
| 8 | Celular e acessibilidade | Verificar menu, tabelas, áreas de toque, foco de teclado, contraste e imagens em telas pequenas. | Garantir acesso confortável em diferentes dispositivos. | Médio |

### 2.1. Home e padrão visual

- Manter o logotipo, com menor predominância na primeira tela.
- Escrever uma apresentação breve, em inglês, que comunique a pergunta central
  do laboratório em linguagem acessível.
- Destacar dois caminhos: **Explore our research** e **Courses & materials**.
- Organizar três linhas de pesquisa com imagem e descrição curta, usando
  conteúdo já existente e fotografias com direitos de uso conhecidos.
- Integrar notícias e fotografias à hierarquia da página sem competir com a
  apresentação e os principais acessos.
- Padronizar largura de leitura, escala de títulos, espaçamentos e componentes.

### 2.2. Publicações

- Manter a lista completa acessível mesmo quando houver filtros.
- Acrescentar campos estruturados ao YAML para permitir busca e filtros
  confiáveis, evitando depender da interpretação de citações formatadas.
- Definir tipos editoriais consistentes e distinguir publicação, manuscrito
  aceito, preprint e trabalho em preparação.
- Exibir ações com texto, além de ícones, apenas quando o recurso existir.
- Oferecer cópia da referência; considerar exportação BibTeX como etapa posterior.
- Preservar os destaques, as notas de autoria e a fonte compartilhada com o CV.

### 2.3. Ensino e materiais

- Implementar o catálogo conforme a política de idiomas da seção 1.
- Mostrar nível, idioma, carga horária e última oferta quando essas informações
  estiverem disponíveis, sem preencher valores presumidos.
- Distinguir materiais de ofertas anteriores de informações sobre futuras ofertas.
- Padronizar os acessos a slides, exercícios, dados e leituras.
- Implementar navegação anterior/próxima somente quando houver uma sequência
  definida de aulas; evitar becos sem saída nos limites do curso.

### 2.4. Pesquisa, equipe e oportunidades

- Relacionar projetos, pessoas, resultados e ferramentas com links contextuais.
- Padronizar enquadramento das fotografias e informações dos membros da equipe.
- Separar graduação, pós-graduação e colaboração na apresentação de oportunidades.
- Exibir disponibilidade atual e instruções específicas de contato para cada grupo.
- Preservar a mensagem vigente sobre recrutamento; mudar a apresentação não
  autoriza alterar a disponibilidade de orientação.

## 3. Sequência de entregas

### Etapa A — idiomas, identidade e acesso ao ensino

**Primeira entrega recomendada.**

- Consolidar a política de idiomas e preparar os textos necessários.
- Implementar os ajustes de idioma do catálogo e da navegação das disciplinas.
- Criar a entrada institucional resumida em português e o acesso ao contato.
- Reorganizar a abertura da home e aplicar o padrão visual compartilhado.
- Transformar Teaching em um catálogo de disciplinas.
- Verificar celular e acessibilidade nas páginas desta etapa.

**Aceite:** os critérios de idioma da seção 1 estão atendidos; os principais
caminhos da home e do catálogo são claros e funcionam em computador e celular.

### Etapa B — consulta às publicações

- Estruturar os metadados necessários na bibliografia compartilhada.
- Implementar busca, filtros, ações textuais e cópia de referência.
- Verificar navegação por teclado, ausência de resultados e retorno à lista completa.

**Aceite:** uma publicação pode ser encontrada por título ou autor, os filtros
podem ser combinados e removidos, e a referência pode ser copiada corretamente.

### Etapa C — integração do conteúdo

- Conectar linhas de pesquisa, projetos, pessoas, publicações e ferramentas.
- Aprimorar a apresentação da equipe e das oportunidades.
- Completar a navegação entre aulas e a revisão das páginas secundárias.

**Aceite:** as relações entre conteúdos podem ser percorridas por links úteis,
com idioma e contexto compreensíveis em cada destino.

## 4. Verificação e manutenção

- Renderizar o site e executar os testes e validadores existentes.
- Ampliar as verificações quando surgirem novos caminhos de idioma e componentes
  funcionais, preservando as checagens de links, arquivos e atualização do CV.
- Conferir visualmente as páginas alteradas em computador e celular.
- Testar os fluxos principais com teclado e verificar foco visível e contraste.
- Verificar filtros, mensagens sem resultados e controles anterior/próxima.
- Otimizar imagens quando a medição ou o uso em celular indicar necessidade.
- Revisar o PDF do CV quando houver mudanças na bibliografia ou nos estilos que
  afetem sua apresentação.
- Manter o README atualizado com os procedimentos de manutenção do conteúdo.

## 5. Decisões a resolver durante a execução

- Texto final da apresentação curta da home.
- Conteúdo e endereço da entrada institucional em português, preservando as URLs atuais.
- Relação de páginas que futuramente justificam tradução integral.
- Campos e tipos editoriais usados nos filtros de publicações.
- Informações disponíveis para cada curso e autorização de uso das fotografias.

Essas decisões devem ser resolvidas na etapa correspondente. A proposta inicial
prioriza idiomas, home e catálogo de disciplinas; em seguida, busca e filtros
de publicações, aproveitando a estrutura estática e os dados já existentes.
