# ADR 003 – Infraestrutura como Código com AWS CloudFormation

## Status
Aceito

## Contexto
O projeto **CloudPress** tem como objetivo servir como um laboratório prático de
estudos focado em **AWS e arquitetura em nuvem**, priorizando o entendimento
profundo dos serviços nativos da AWS, seus recursos, integrações e boas práticas.

Embora ferramentas multi-cloud como Terraform sejam amplamente utilizadas no
mercado, o foco principal deste projeto é aprofundar o conhecimento em serviços
AWS, seus modelos de provisionamento e padrões arquiteturais nativos.

Diante disso, tornou-se necessário definir a ferramenta de **Infraestrutura como
Código (IaC)** que melhor atenda a esse objetivo educacional.

## Decisão
Foi decidido utilizar **AWS CloudFormation** como a ferramenta oficial de
Infraestrutura como Código do projeto CloudPress.

Toda a infraestrutura AWS do projeto será provisionada, atualizada e versionada
utilizando templates CloudFormation.

## Alternativas Consideradas
- **Terraform**
  - Ferramenta madura e amplamente adotada
  - Porém abstrai detalhes específicos da AWS, reduzindo a exposição direta aos
    recursos e comportamentos nativos da plataforma
- **Provisionamento manual via console**
  - Não escalável
  - Não reproduzível
  - Não alinhado com boas práticas de DevOps e SRE
- **AWS CDK**
  - Abordagem poderosa e moderna
  - Introduz camada adicional de abstração e dependência de linguagem de
    programação, o que foge do foco inicial do projeto

## Consequências

### Positivas
- Maior aprofundamento nos serviços nativos da AWS
- Entendimento detalhado de recursos, propriedades e dependências
- Melhor compreensão do funcionamento de stacks, change sets e rollback
- Aderência total às boas práticas recomendadas pela AWS
- Facilidade de integração com outros serviços AWS
- Excelente material de estudo e documentação

### Negativas
- Templates mais verbosos
- Menor portabilidade para outros provedores de nuvem
- Curva de aprendizado maior para templates complexos

## Considerações Técnicas
- Templates CloudFormation serão versionados junto ao código do projeto
- Será priorizado o uso de YAML
- Uso de **Change Sets** para validação de alterações
- Separação de stacks por responsabilidade (ex: frontend, CDN, segurança)
- Uso de parâmetros e outputs para facilitar reutilização e evolução

## Observações
Esta decisão não impede o uso futuro de outras ferramentas, como Terraform ou
AWS CDK, caso o escopo do projeto evolua ou novos objetivos educacionais sejam
definidos.

## Referências
- Documentação AWS CloudFormation
- AWS Well-Architected Framework
- AWS Infrastructure as Code Best Practices
