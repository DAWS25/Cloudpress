# ☁️ CloudPress – Frontend

Este diretório contém o **frontend do projeto CloudPress**, desenvolvido como
uma **Single Page Application (SPA)** utilizando **React + Vite**.

O CloudPress é um laboratório de estudos em **AWS e Cloud Computing**, criado
durante o curso **Descomplicando AWS**, com foco em boas práticas de arquitetura,
infraestrutura como código e automação.

---

## 🧱 Tecnologias Utilizadas

- React
- Vite
- TypeScript
- Node.js
- Devbox (gerenciamento de ambiente)

---

## 📋 Pré-requisitos

### ✔ Obrigatórios
- Git
- **Devbox instalado**
- Node.js (será fornecido pelo Devbox)

### ✔ No Windows
- WSL2 (Ubuntu recomendado)
- VS Code (opcional, mas recomendado)

> ⚠️ **Não é necessário Docker** para trabalhar neste frontend.

---

## 🚀 Setup do Ambiente (recomendado)

### 1️⃣ Clone o repositório

```
git clone <url-do-repositorio>
cd Cloudpress
```

## 2️⃣ Inicie o ambiente com Devbox

Na raiz do projeto *mesmo local onde se encontra o arquivo devbox.json*:
```
devbox install
devbox shell
```

Isso irá:

- Instalar Node.js

- Configurar o ambiente de desenvolvimento

- Evitar dependências no seu sistema operacional

## 3️⃣ Execute o servidor de desenvolvimento
```
cd cloudpress_frontend/
npm run dev
```
**Caso esteja utilizando o wsl do Windows execute o comando abaixo**
```
cd cloudpress_frontend/
npm run dev -- --host
```

Você verá algo como:

```
Local: http://localhost:5173/
Network: http://172.21.198.71:5173
```

## 3️⃣ Realizar build da aplicação front
```
cd cloudpress_frontend/
npm run build
```

## 🔐 Variáveis de ambiente

Crie um arquivo `.env` em `cloudpress_frontend/` com base em `.env.example`:

```bash
cp .env.example .env
```

Campos necessários:

- `VITE_COGNITO_DOMAIN`
- `VITE_COGNITO_CLIENT_ID`
- `VITE_COGNITO_REDIRECT_URI`
- `VITE_UPLOAD_API_URL` (base URL da stack `upload-api`)
