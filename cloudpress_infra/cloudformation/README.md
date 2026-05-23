# ☁️ CloudFormation – CloudPress

Este diretório contém todos os templates **AWS CloudFormation** utilizados para
provisionar a infraestrutura do projeto **CloudPress**.

O objetivo é estudar e aplicar conceitos nativos da AWS utilizando
**Infraestrutura como Código (IaC)**, priorizando clareza, versionamento e boas
práticas arquiteturais.

---

## 📂 Estrutura de Diretórios

cloudformation/
├── templates/
│ ├── s3.yaml
│ ├── cloudfront.yaml
│ └── acm.yaml
└── README.md


### 📁 templates/
Templates reutilizáveis que definem recursos específicos da AWS.

---

## 🚀 Deploy (manual – fase inicial)

Exemplo de criação da stack do frontend:

```bash
aws cloudformation deploy \
  --template-file stacks/frontend.yaml \
  --stack-name cloudpress-frontend-dev \
  --parameter-overrides file://parameters/frontend-dev.json \
  --capabilities CAPABILITY_NAMED_IAM
```

## 📚 Problemas Comuns
É possível que a policy do Bucket venha com um caracter \n ao final da linha
```
Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::<AWS ACCOUNT ID>:distribution/<ID CLOUDFRONT>\n"
                }
            }
 ``` 