# ADR-005 — Decisão sobre Autenticação

**Status:** Accepted  
**Data:** 2026-01-31  

## Contexto

O projeto Cloudpress está em fase de expansão de funcionalidades e necessita de um mecanismo de autenticação para permitir acesso seguro a recursos futuros da aplicação.

Como o objetivo principal do projeto é aprendizado em AWS, arquitetura e uso de serviços gerenciados, foram considerados os seguintes pontos:

- Entregar funcionalidade de login rapidamente
- Evitar desenvolvimento e manutenção de código sensível (senhas, hashing, JWT)
- Utilizar serviços nativos da AWS
- Garantir segurança e escalabilidade desde o início
- Reduzir esforço de desenvolvimento para focar em infraestrutura e arquitetura

Foram avaliadas duas abordagens:
1. Autenticação gerenciada via serviço AWS
2. Autenticação customizada com backend próprio

---

## Opções Consideradas

### Opção 1 — Autenticação com Amazon Cognito

Utilização do Amazon Cognito para gerenciamento de identidade, autenticação de usuários e emissão de tokens JWT, com infraestrutura provisionada via CloudFormation e integração direta com o frontend.

**Características:**
- Gerenciamento de usuários e senhas gerenciado pela AWS
- Emissão de tokens JWT (`id_token`, `access_token`, `refresh_token`)
- Integração nativa com serviços AWS
- Possibilidade de evolução com triggers Lambda e Authorizers no API Gateway

---

### Opção 2 — Autenticação customizada (DynamoDB + JWT)

Desenvolvimento de uma solução própria de autenticação, incluindo armazenamento de usuários em banco de dados, hashing de senhas e geração/validação de tokens JWT.

**Características:**
- Controle total do fluxo de autenticação
- Maior esforço de desenvolvimento
- Responsabilidade total sobre segurança, conformidade e manutenção

---

## Decisão

Foi decidido utilizar o Amazon Cognito como solução de autenticação do projeto Cloudpress.

---

## Justificativa

A escolha pelo Amazon Cognito foi motivada pelos seguintes fatores:

- Foco em aprendizado AWS e arquitetura cloud
- Maior velocidade de entrega da funcionalidade de login
- Redução de riscos relacionados à segurança de credenciais
- Escalabilidade automática e integração nativa com outros serviços AWS
- Menor complexidade operacional
- Aderência ao uso de infraestrutura como código via CloudFormation

Essa decisão está alinhada com o objetivo do projeto de priorizar arquitetura, automação e boas práticas de cloud, em vez do desenvolvimento de funcionalidades básicas.

---

## Consequências

### Positivas
- Autenticação segura desde o início do projeto
- Redução de código customizado
- Facilidade de integração com frontend e futuros backends
- Base sólida para evolução futura (MFA, roles, claims customizados, triggers Lambda)

### Negativas
- Dependência de um serviço gerenciado da AWS
- Customização visual limitada no fluxo de autenticação inicial
- Curva de aprendizado específica do Amazon Cognito
