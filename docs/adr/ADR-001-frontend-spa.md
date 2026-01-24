# ADR 001 – Frontend SPA com React + Vite

## Status
Aceito

## Contexto
O projeto **CloudPress** foi criado com o objetivo de servir como um laboratório
prático de estudos em **AWS, Cloud Computing, DevOps e SRE**, permitindo a
experimentação de arquiteturas, automação, segurança e boas práticas em nuvem.

Na fase inicial do projeto, existe a necessidade de disponibilizar uma interface
web simples, de baixo custo e fácil de operar, permitindo foco total na
infraestrutura cloud, automação e arquitetura, sem introduzir complexidade
desnecessária no frontend.

A arquitetura inicial definida para o projeto utiliza **Amazon S3** para
hospedagem de conteúdo estático e **Amazon CloudFront** como CDN.

## Decisão
Foi decidido implementar o frontend inicial do CloudPress como uma
**Single Page Application (SPA)** desenvolvida em **React utilizando Vite** como
ferramenta de build.

A aplicação será compilada em arquivos estáticos e hospedada em um bucket S3,
com distribuição via CloudFront.

## Alternativas Consideradas
- **Angular**
  - Framework completo, porém com maior curva de aprendizado e complexidade
    para um frontend inicial simples.
- **Next.js**
  - Framework full-stack com suporte a SSR e SSG, porém exigindo infraestrutura
    adicional (Lambda, Edge ou containers), aumentando o custo e a complexidade
    operacional neste estágio do projeto.
- **CMS tradicional (ex: WordPress)**
  - Solução pronta, porém com foco menor em aprendizado de arquitetura cloud
    moderna e infraestrutura como código.

## Consequências

### Positivas
- Infraestrutura simples e de baixo custo
- Deploy baseado apenas em arquivos estáticos
- Excelente compatibilidade com S3 e CloudFront
- Build rápido e pipeline de CI/CD simplificado
- Maior foco nos estudos de AWS, arquitetura e automação
- Facilidade de evolução futura com backend desacoplado

### Negativas
- SEO limitado por se tratar de uma SPA
- Ausência de Server Side Rendering (SSR)
- Dependência de APIs externas para funcionalidades dinâmicas futuras

## Observações
Esta decisão não impede a adoção futura de outras abordagens, como:
- Migração parcial ou total para Next.js
- Introdução de SSR ou SSG conforme a evolução do projeto
- Integração com APIs backend utilizando serviços AWS

## Referências
- Documentação Amazon S3 – Static Website Hosting
- Documentação Amazon CloudFront
- Documentação React
- Documentação Vite
