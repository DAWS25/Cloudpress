# ADR-006 — Decisão sobre Persistência e Processamento Assíncrono

**Status:** Accepted  
**Data:** 2026-03-21  

## Contexto

O projeto Cloudpress passará a receber uploads de conteúdo realizados por usuários autenticados via Amazon Cognito. Além do arquivo enviado, o sistema também deverá receber metadados associados ao conteúdo, como:

- Título
- Descrição
- Tipo de conteúdo identificado a partir da extensão do arquivo
- Indicação se o conteúdo é patrocinado ou não

Esse fluxo não termina no upload do arquivo. As informações do conteúdo precisam ser processadas e armazenadas para posterior consulta no site, incluindo listagens por usuário e destaque para conteúdos patrocinados.

Como o projeto tem foco em aprendizado de arquitetura cloud com AWS, era necessário definir uma estratégia para:

- Armazenar os metadados do conteúdo
- Desacoplar o recebimento do upload do processamento desses dados
- Reduzir complexidade operacional
- Permitir evolução futura sem reestruturar o fluxo principal

Foram avaliadas duas abordagens:
1. Processamento síncrono com persistência direta no momento da requisição
2. Processamento assíncrono com fila e banco NoSQL gerenciados pela AWS

---

## Opções Consideradas

### Opção 1 — Persistência direta em banco relacional durante o upload

Nessa abordagem, a API que recebe a requisição do usuário faria o processamento completo no mesmo fluxo, persistindo os dados imediatamente em um banco relacional.

**Características:**
- Fluxo simples de entender em um primeiro momento
- Forte acoplamento entre recebimento da requisição e persistência
- Maior risco de impacto no tempo de resposta da API
- Maior esforço de administração e modelagem inicial

---

### Opção 2 — Amazon SQS + Amazon DynamoDB

Nessa abordagem, a aplicação envia os metadados do upload para uma fila Amazon SQS, e um consumidor processa as mensagens em segundo plano, gravando os dados no Amazon DynamoDB.

**Características:**
- Desacoplamento entre entrada da requisição e persistência
- Uso de serviços gerenciados e nativos da AWS
- Escalabilidade automática compatível com baixa carga inicial
- Facilidade para reprocessamento e tratamento de falhas
- Baixa necessidade de administração de infraestrutura

---

## Decisão

Foi decidido utilizar Amazon SQS para recebimento assíncrono dos eventos de upload e Amazon DynamoDB para persistência dos metadados de conteúdo.

---

## Justificativa

A escolha por SQS e DynamoDB foi motivada pelos seguintes fatores:

- A fila SQS desacopla o upload do processamento, evitando que a experiência do usuário dependa da gravação imediata no banco
- O DynamoDB atende bem ao volume esperado do projeto e ao perfil simples de acesso aos dados
- O modo `PAY_PER_REQUEST` no DynamoDB é adequado para a baixa quantidade prevista de requisições mensais
- O modelo NoSQL permite armazenar metadados do conteúdo com flexibilidade, sem overhead de administração de banco relacional
- O uso de serviços gerenciados reduz esforço operacional e mantém o foco do projeto em arquitetura cloud
- A combinação de SQS com um consumidor posterior facilita retries, tratamento de falhas e evolução futura do pipeline
- A solução se integra naturalmente à estratégia de infraestrutura como código com CloudFormation

Essa decisão também apoia requisitos funcionais do projeto, como:

- Consultar conteúdos por usuário
- Destacar conteúdos patrocinados
- Registrar metadados como título, descrição, tipo do arquivo e informações de armazenamento

---

## Consequências

### Positivas

- Menor acoplamento entre upload e persistência
- Melhor resiliência em cenários de falha temporária no processamento
- Facilidade de escalar o consumidor sem alterar a experiência do usuário
- Baixo custo e baixo esforço operacional para a fase atual do projeto
- Estrutura preparada para futuras automações de enriquecimento ou moderação de conteúdo

### Negativas

- Maior complexidade arquitetural em comparação a uma gravação síncrona direta
- Necessidade de implementar e monitorar um consumidor da fila
- Consistência eventual entre o momento do upload e a disponibilidade do conteúdo no banco
- Necessidade de definir cuidadosamente o contrato da mensagem enviada para a fila
