# BrasilDubai Portal — Guia de Setup

## Pré-requisitos
- Conta no [Supabase](https://supabase.com) (gratuito)
- Conta na [Hostinger](https://hostinger.com) (para deploy)
- Conta no [Resend](https://resend.com) (emails — fase 2)

---

## Passo 1 — Criar projeto no Supabase

1. Acesse [app.supabase.com](https://app.supabase.com) → New Project
2. Anote a **Project URL** e a **anon public key**
3. Vá em **Authentication > Settings**:
   - Desative **"Confirm email"** (para admin cadastrar clientes diretamente)
4. Vá em **SQL Editor** → cole e execute todo o conteúdo de `supabase/schema.sql`

---

## Passo 2 — Configurar js/config.js

Abra `js/config.js` e substitua:

```javascript
const SUPABASE_URL      = 'https://SEU_PROJETO.supabase.co';   // ← sua URL
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';                 // ← sua chave anon
const COMPANY_WHATSAPP  = '971500000000';                      // ← número da empresa (sem + ou espaços)
```

---

## Passo 3 — Criar bucket de Storage

1. No Supabase → **Storage** → **New Bucket**
2. Nome: `documents`
3. Deixe como **Private** (não público)
4. O schema.sql já inclui as políticas de acesso

---

## Passo 4 — Criar o primeiro Admin

1. Acesse `index.html` → clique em "Criar conta" → registre-se normalmente
2. No Supabase → **Table Editor** → tabela `profiles`
3. Encontre seu usuário e altere `role` de `client` para `admin`
4. Pronto — você tem acesso ao painel admin

---

## Passo 5 — Deploy na Hostinger

1. Comprima todos os arquivos (exceto `supabase/`, `SETUP.md`)
2. No painel Hostinger → **Gerenciador de Arquivos** → `public_html`
3. Faça upload e extraia os arquivos
4. Configure o domínio `app.brasildubai.com` apontando para o servidor

Ou use **Git deploy** se a Hostinger suportar:
```bash
git init
git add .
git commit -m "initial: BrasilDubai Portal v1.0"
git remote add origin https://github.com/SEU_USUARIO/brasildubai-portal.git
git push -u origin main
```

---

## Passo 6 — Configurar links JotForm

1. Faça login como Admin
2. Vá em **Relatórios** → seção **Links JotForm**
3. Insira os links dos seus formulários para cada serviço
4. Clique **Salvar** — a partir de agora as mensagens WhatsApp incluirão os links corretos

---

## Fluxo do Admin ao cadastrar cliente

1. Admin preenche: Nome, Email, Senha, WhatsApp, Serviço
2. Sistema cria a conta + checklist automático
3. Mensagem WhatsApp é gerada com link do JotForm
4. Admin clica **"Enviar via WhatsApp"** → abre WhatsApp com a mensagem pronta
5. Cliente recebe e faz login com email + senha fornecidos

---

## Estrutura de arquivos

```
App Brasil Dubai/
├── index.html              # Login
├── register.html           # Cadastro
├── client/
│   └── index.html          # Painel do Cliente
├── employee/
│   └── index.html          # Painel do Funcionário
├── admin/
│   └── index.html          # Painel Admin
├── css/
│   └── styles.css          # Estilos globais
├── js/
│   ├── config.js           # Config Supabase + traduções
│   └── auth.js             # Helpers de autenticação
└── supabase/
    └── schema.sql          # Schema completo do banco
```

---

## Fase 2 (próximos passos)
- [ ] Integração Resend (emails automáticos)
- [ ] Evolution API + n8n (WhatsApp automático)
- [ ] Dashboard financeiro completo
- [ ] Notificações em tempo real (Supabase Realtime)
