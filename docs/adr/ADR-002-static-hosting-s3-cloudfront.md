# ADR 002 – Hospedagem Estática com Amazon S3 e CloudFront

## Status
Aceito

## Contexto
O projeto **CloudPress** possui como objetivo principal servir como um laboratório
de estudos em AWS, permitindo a implementação prática de arquiteturas cloud
simples, seguras, escaláveis e de baixo custo.

Com a decisão definida no **ADR 001** de utilizar um frontend no formato
**Single Page Application (SPA)**, surgiu a necessidade de escolher uma solução
de hospedagem compatível com conteúdo estático, que permitisse fácil integração
com automação, CI/CD e boas práticas de segurança.

## Decisão
Foi decidido utilizar:

- **Amazon S3** para armazenamento e hospedagem dos arquivos estáticos da SPA
- **Amazon CloudFront** como CDN, responsável pela distribuição global,
  cache, HTTPS e controle de acesso ao conteúdo

O acesso direto ao bucket S3 será restrito, permitindo apenas acesso via
CloudFront.

## Alternativas Consideradas
- **Servidor web em EC2**
  - Maior custo operacional
  - Necessidade de gerenciamento de sistema operacional
- **ECS/Fargate**
  - Overhead de containers para conteúdo estático
- **Elastic Beanstalk**
  - Solução voltada para aplicações dinâmicas
- **Plataformas gerenciadas externas (ex: Vercel, Netlify)**
  - Menor controle sobre infraestrutura AWS
  - Foco reduzido em aprendizado de arquitetura cloud nativa

## Consequências

### Positivas
- Arquitetura simples e altamente escalável
- Baixo custo operacional
- Alta disponibilidade global via CDN
- HTTPS nativo com ACM
- Fácil automação via Infraestrutura como Código
- Integração natural com pipelines CI/CD
- Base sólida para futuras evoluções do projeto

### Negativas
- Necessidade de configuração específica para suportar rotas de SPA
- Dependência de invalidações de cache no CloudFront durante deploys
- Menor flexibilidade para conteúdo dinâmico sem backend adicional

## Considerações Técnicas
- O bucket S3 não deverá ser público
- Será utilizado **CloudFront Origin Access Control (OAC)** para acesso seguro
- Configuração de fallback para `/index.html` em casos de erro 403/404,
  garantindo funcionamento correto da SPA
- Headers de cache configurados de forma apropriada para conteúdo estático

## Observações
Esta arquitetura permite evolução futura sem impacto significativo, incluindo:
- Integração com APIs backend
- Uso de WAF no CloudFront
- Custom domain via Route 53
- Monitoramento e logs com CloudWatch

## Referências
- Documentação Amazon S3 – Static Website Hosting
- Documentação Amazon CloudFront
- Documentação AWS Well-Architected Framework
