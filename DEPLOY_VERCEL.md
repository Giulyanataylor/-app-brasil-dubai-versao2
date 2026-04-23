# Deploy seguro na Vercel

## 1) Variáveis de ambiente (Vercel Project Settings)

Cadastre estas variáveis em **Project > Settings > Environment Variables**:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `COMPANY_WHATSAPP`

> Use apenas a chave **anon/public** do Supabase no frontend.  
> Nunca use `service_role` no frontend.

## 2) Build

No deploy, a Vercel executa:

```bash
npm run build
```

Esse comando gera `js/deploy-config.js` com as variáveis do ambiente.

## 3) URLs

Após deploy, configure no Supabase:

- `Authentication > URL Configuration > Site URL` = domínio Vercel
- Adicione o mesmo domínio em `Redirect URLs`

## 4) Rodar local

Para rodar local sem Vercel:

1. Copie `js/deploy-config.example.js`
2. Renomeie para `js/deploy-config.js`
3. Preencha seus valores

O arquivo `js/deploy-config.js` está no `.gitignore` e não vai para o GitHub.
