import { writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || '';
const companyWhatsapp = process.env.COMPANY_WHATSAPP || '971500000000';

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing env vars: SUPABASE_URL and SUPABASE_ANON_KEY are required.');
  process.exit(1);
}

const filePath = resolve('js/deploy-config.js');
mkdirSync(dirname(filePath), { recursive: true });

const content = `window.__BD_CONFIG__ = {
  SUPABASE_URL: ${JSON.stringify(supabaseUrl)},
  SUPABASE_ANON_KEY: ${JSON.stringify(supabaseAnonKey)},
  COMPANY_WHATSAPP: ${JSON.stringify(companyWhatsapp)}
};
`;

writeFileSync(filePath, content, 'utf8');
console.log('Generated js/deploy-config.js');
