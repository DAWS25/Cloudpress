# ADR 004 – Ambiente de Desenvolvimento com Devbox + WSL

## Status
Aceito

## Contexto
O projeto **CloudPress** é um laboratório de estudos em AWS e Cloud Computing,
desenvolvido de forma colaborativa durante o curso **Descomplicando AWS**.

O projeto possui colaboradores utilizando diferentes sistemas operacionais,
principalmente **Windows**, o que pode gerar inconsistências de ambiente,
versões de ferramentas e dependências locais.

Para evitar problemas de "funciona na minha máquina" e reduzir o tempo de
onboarding de novos colaboradores, tornou-se necessário definir uma estratégia
padronizada para o ambiente de desenvolvimento.

## Decisão
Foi decidido adotar **Devbox** como ferramenta principal para gerenciamento do
ambiente de desenvolvimento, executando sobre **WSL (Windows Subsystem for
Linux)** nos sistemas Windows.

O ambiente de desenvolvimento será executado diretamente no WSL, **sem uso de
containers Docker ou Dev Containers**, priorizando simplicidade, desempenho e
menor consumo de recursos.

## Alternativas Consideradas
- **Instalação manual de dependências no sistema operacional**
  - Gera inconsistências de versão
  - Alto custo de manutenção
- **VS Code Dev Containers (Docker)**
  - Exige Docker Desktop
  - Maior consumo de recursos
  - Complexidade desnecessária para o escopo atual
- **Ambientes virtuais específicos por linguagem**
  - Não resolvem dependências de ferramentas cloud (AWS CLI, etc.)

## Consequências

### Positivas
- Ambiente reprodutível e versionado como código
- Onboarding rápido para novos colaboradores
- Isolamento de dependências do sistema operacional
- Melhor desempenho em comparação com containers
- Alinhamento com práticas modernas de desenvolvimento
- Facilidade para uso em ambientes Linux e WSL

### Negativas
- Dependência do WSL para usuários Windows
- Curva de aprendizado inicial para Devbox
- Não suportado nativamente no Windows sem WSL

## Considerações Técnicas
- O arquivo `devbox.json` é a fonte de verdade do ambiente
- Node.js, AWS CLI e outras ferramentas são instaladas via Devbox
- O ambiente deve ser iniciado com:
  ```bash
  devbox install
  devbox shell
