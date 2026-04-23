-- ============================================================
-- BrasilDubai Portal — Supabase Schema + RLS + Seed Data
-- ============================================================
-- Executar no SQL Editor do Supabase (em ordem)
-- ============================================================


-- ============================================================
-- 1. TABLES
-- ============================================================

-- Services (os 3 serviços)
CREATE TABLE IF NOT EXISTS services (
  id              SERIAL PRIMARY KEY,
  slug            TEXT UNIQUE NOT NULL,
  name_pt         TEXT NOT NULL,
  name_en         TEXT NOT NULL,
  description_pt  TEXT,
  description_en  TEXT,
  jotform_link    TEXT,
  whatsapp_number TEXT DEFAULT '971500000000',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- User profiles (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name   TEXT NOT NULL,
  whatsapp    TEXT,
  role        TEXT NOT NULL DEFAULT 'client'
              CHECK (role IN ('client', 'employee', 'admin')),
  service_id  INT REFERENCES services(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Checklist templates per service
CREATE TABLE IF NOT EXISTS checklist_templates (
  id          SERIAL PRIMARY KEY,
  service_id  INT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  step_order  INT NOT NULL,
  title_pt    TEXT NOT NULL,
  title_en    TEXT NOT NULL,
  instructions_pt TEXT,
  instructions_en TEXT,
  percentage  INT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Per-client checklist (instantiated from template when client is created)
CREATE TABLE IF NOT EXISTS client_checklist (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  template_step_id INT  NOT NULL REFERENCES checklist_templates(id) ON DELETE CASCADE,
  status           TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('done', 'in_progress', 'pending')),
  notes            TEXT,
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_by       UUID REFERENCES profiles(id),
  UNIQUE(client_id, template_step_id)
);

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  amount      DECIMAL(12,2) NOT NULL,
  currency    TEXT DEFAULT 'AED',
  due_date    DATE,
  is_paid     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Documents
CREATE TABLE IF NOT EXISTS documents (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  filename     TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  uploaded_by  UUID REFERENCES profiles(id),
  uploaded_at  TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================================
-- 2. TRIGGER: auto-create profile on sign-up
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, whatsapp, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Novo Usuário'),
    NEW.raw_user_meta_data->>'whatsapp',
    'client'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();


-- ============================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE profiles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_checklist    ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices            ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents           ENABLE ROW LEVEL SECURITY;
ALTER TABLE services            ENABLE ROW LEVEL SECURITY;

-- Helper: get current user role
CREATE OR REPLACE FUNCTION current_user_role()
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$;

-- ---- SERVICES ----
CREATE POLICY "services_read_all" ON services
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "services_manage_admin" ON services
  FOR ALL USING (current_user_role() = 'admin');

-- ---- CHECKLIST_TEMPLATES ----
CREATE POLICY "templates_read_all" ON checklist_templates
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "templates_manage_admin" ON checklist_templates
  FOR ALL USING (current_user_role() = 'admin');

-- ---- PROFILES ----
-- Client: read own profile
CREATE POLICY "profiles_client_read_own" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Employee/Admin: read all profiles
CREATE POLICY "profiles_staff_read_all" ON profiles
  FOR SELECT USING (current_user_role() IN ('employee', 'admin'));

-- Admin: full access
CREATE POLICY "profiles_admin_all" ON profiles
  FOR ALL USING (current_user_role() = 'admin');

-- Allow insert for trigger (service role)
CREATE POLICY "profiles_insert_self" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow update own profile
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- ---- CLIENT_CHECKLIST ----
-- Client: read own
CREATE POLICY "checklist_client_read" ON client_checklist
  FOR SELECT USING (
    auth.uid() = client_id
    OR current_user_role() IN ('employee', 'admin')
  );

-- Employee/Admin: update any
CREATE POLICY "checklist_staff_update" ON client_checklist
  FOR UPDATE USING (current_user_role() IN ('employee', 'admin'));

-- Admin: full access (for seeding on client creation)
CREATE POLICY "checklist_admin_insert" ON client_checklist
  FOR INSERT WITH CHECK (current_user_role() IN ('employee', 'admin') OR auth.uid() = client_id);

CREATE POLICY "checklist_admin_delete" ON client_checklist
  FOR DELETE USING (current_user_role() = 'admin');

-- ---- INVOICES ----
CREATE POLICY "invoices_client_read" ON invoices
  FOR SELECT USING (
    auth.uid() = client_id
    OR current_user_role() IN ('employee', 'admin')
  );

CREATE POLICY "invoices_staff_manage" ON invoices
  FOR ALL USING (current_user_role() IN ('employee', 'admin'));

-- ---- DOCUMENTS ----
CREATE POLICY "documents_client_read" ON documents
  FOR SELECT USING (
    auth.uid() = client_id
    OR current_user_role() IN ('employee', 'admin')
  );

CREATE POLICY "documents_client_insert" ON documents
  FOR INSERT WITH CHECK (auth.uid() = client_id OR current_user_role() IN ('employee', 'admin'));

CREATE POLICY "documents_staff_manage" ON documents
  FOR ALL USING (current_user_role() IN ('employee', 'admin'));


-- ============================================================
-- 4. STORAGE BUCKET
-- ============================================================

-- Run in Supabase Dashboard > Storage > New Bucket: "documents" (private)
-- OR via SQL:
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS
CREATE POLICY "storage_client_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "storage_read_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'documents'
    AND (
      -- client reads their own folder
      (storage.foldername(name))[1] = auth.uid()::text
      -- staff reads all
      OR current_user_role() IN ('employee', 'admin')
    )
  );

CREATE POLICY "storage_staff_upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'documents'
    AND current_user_role() IN ('employee', 'admin')
  );


-- ============================================================
-- 5. SEED DATA — Services
-- ============================================================

INSERT INTO services (id, slug, name_pt, name_en, description_pt, description_en, jotform_link)
VALUES
  (1, 'freezone',
   'Abertura de Empresa (Freezone)',
   'Company Setup (Freezone)',
   'Abra sua empresa em Dubai de forma rápida e segura. Processo 100% online com suporte completo.',
   'Open your company in Dubai quickly and safely. 100% online process with full support.',
   NULL),

  (2, 'visa',
   'Visto de Independente',
   'Independent Residency Visa',
   'Obtenha seu visto de residência independente em Dubai. Acompanhamos todo o processo.',
   'Get your independent residency visa in Dubai. We handle the entire process.',
   NULL),

  (3, 'cnh',
   'CNH em Dubai',
   'Driver''s License in Dubai',
   'Converta ou tire sua CNH em Dubai com suporte total. Agendamos tudo para você.',
   'Convert or get your driver''s license in Dubai with full support. We schedule everything.',
   NULL)
ON CONFLICT (id) DO NOTHING;

-- Reset sequence
SELECT setval('services_id_seq', 3);


-- ============================================================
-- 6. SEED DATA — Checklist Templates
-- ============================================================

-- SERVICE 1: FREEZONE
INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en) VALUES
(1, 1, 'Formulario — Preencher dados iniciais',                'Form — Fill in initial information'),
(1, 2, 'Abertura da Empresa — Processo junto ao governo',     'Company Registration — Government process'),
(1, 3, 'Registro na Imigração — Regularização migratória',    'Immigration Registration — Migration process'),
(1, 4, 'Corporate Tax — Registro tributário corporativo',     'Corporate Tax — Corporate tax registration'),
(1, 5, 'Exame de Saúde',                                       'Medical Exam'),
(1, 6, 'Biometria',                                            'Biometrics'),
(1, 7, 'Impressao do ID',                                      'ID Printing'),
(1, 8, 'ID entregue 🎉 Parabéns, processo concluído!',         'ID delivered 🎉 Congratulations, process completed!')
ON CONFLICT DO NOTHING;

-- If Freezone templates already exist in production, run this block once:
-- UPDATE checklist_templates
-- SET title_pt = 'Formulario — Preencher dados iniciais',
--     title_en = 'Form — Fill in initial information'
-- WHERE service_id = 1 AND step_order = 1;
--
-- INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en)
-- SELECT 1, 5, 'Exame de Saúde', 'Medical Exam'
-- WHERE NOT EXISTS (SELECT 1 FROM checklist_templates WHERE service_id = 1 AND step_order = 5);
--
-- INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en)
-- SELECT 1, 6, 'Biometria', 'Biometrics'
-- WHERE NOT EXISTS (SELECT 1 FROM checklist_templates WHERE service_id = 1 AND step_order = 6);
--
-- INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en)
-- SELECT 1, 7, 'Impressao do ID', 'ID Printing'
-- WHERE NOT EXISTS (SELECT 1 FROM checklist_templates WHERE service_id = 1 AND step_order = 7);
--
-- INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en)
-- SELECT 1, 8, 'ID entregue 🎉 Parabéns, processo concluído!', 'ID delivered 🎉 Congratulations, process completed!'
-- WHERE NOT EXISTS (SELECT 1 FROM checklist_templates WHERE service_id = 1 AND step_order = 8);

-- SERVICE 2: VISTO DE INDEPENDENTE
INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en) VALUES
(2, 1, 'Formulário JotForm — Preencher dados iniciais',       'JotForm — Fill in initial information'),
(2, 2, 'Cancelar visto anterior',                             'Cancel previous visa'),
(2, 3, 'Autenticação de documentos',                          'Document authentication'),
(2, 4, 'Entry Permit & Change Status',                        'Entry Permit & Change Status'),
(2, 5, 'Exame Médico',                                        'Medical Exam'),
(2, 6, 'Seguro de Saúde',                                     'Health Insurance'),
(2, 7, 'Biometria',                                           'Biometrics'),
(2, 8, 'Entrega do Emirates ID',                              'Emirates ID Delivery')
ON CONFLICT DO NOTHING;

-- Manual detalhado do Visto Independente (fase por fase)
UPDATE checklist_templates
SET instructions_pt = CASE step_order
  WHEN 1 THEN 'Fase 1 - Formulario. Enviar login e senha do sistema ao cliente. Ativar fase 1 quando estiver disponivel para o cliente. Enviar formulario e aguardar preenchimento. Revisar respostas, arquivar formulario e arquivos no Drive e no sistema.'
  WHEN 2 THEN 'Fase 2 - Cancelar visto anterior. Verificar no formulario e no Drive se o cliente possui visto anterior ativo ou expirado. Se nao possuir, avancar para a proxima fase. Se possuir, solicitar cancelamento, aguardar comprovante e arquivar cancelamento na tarefa do cliente.'
  WHEN 3 THEN 'Fase 3 - Autenticacao. Criar Certificado de Salario e Contrato de Trabalho usando os templates. Enviar para autenticacao com Gabriel (prazo medio 10 dias). Depois arquivar contrato autenticado no sistema e no Drive.'
  WHEN 4 THEN 'Fase 4 - Entry Permit
60% Dar inicio ao ENTRY PERMIT.
61% ICP Smart Services: https://smartservices.icp.gov.ae/echannels/web/client/guest/index.html#/issueVisa/request/763/step1?administrativeRegionId=1&withException=false
62% Pegar Unified Number no ICP Smart Services: https://smartservices.icp.gov.ae/echannels/web/client/default.html#/fileValidity
63% Tirar print, pegar numero do protocolo com valor e anexar no Drive do cliente e na pasta de pagamentos.
64% IBS One Central Dubai / Dubai World Trade Centre - 1st floor - Sheikh Zayed Rd - Trade Center Second - District - Dubai.
65% Adicionar anexo extra marcando o selo MOFA com o Canva.
66% Conferir diariamente ate sair o ENTRY PERMIT.
Se for recusado, ir no Application Tracking, logar com o email do nomad e colocar no note o texto padrao:
Please check "Additional Annex No. 1" and "Additional Annex No. 2," where I indicate the location of all the stamps in the contract. This problem persists, and it is crucial to verify that both contracts include all the necessary stamps at the end.
68% Enviar o ENTRY PERMIT para Visa # Abu Dhabi Amer Almarkaz (WhatsApp) para Change Status (2 dias).
Se o cliente sair do pais apos o Entry Permit, nao precisa Change Status (usar o Entry Permit como Change Status). Orientar cliente a passar no portao manual e enviar o carimbo do passaporte.
70% Arquivar Change Status - servidor, Drive e avisar cliente (documento com carimbo).
72% Arquivar Change Status nesta tarefa.'
  WHEN 5 THEN 'Fase 5 - Exame Medico (3 dias). Assim que sair o Change Status, orientar cliente a realizar exame medico (Dubai, Abu Dhabi ou Ajman, sem agendamento, cliente paga taxa). Arquivar resultado fitness no sistema e no Drive. Seguro de saude pode iniciar em paralelo.'
  WHEN 6 THEN 'Fase 6 - Seguro de Saude (4 dias)
83% Assim que sair o medical, dar inicio ao seguro.
86% Preencher PDF com informacoes do cliente e usar no sistema TOB e MAF.
https://www.dubins.ae/medical-insurance
89% Anexar PDF da apolice na tarefa e no Drive e avisar o cliente apenas o E-CARD.
(se o cliente pedir a apolice, enviar a do Drive sem valor).'
  WHEN 7 THEN 'Fase 7 - Biometria (5 dias). Confirmar seguro e exame medico concluidos. Verificar se cliente ja teve visto anterior. Se sim, biometria pode ja constar no sistema. Se nao, solicitar biometria no ICP Smart Services, arquivar autorizacao no Drive/tarefa e avisar cliente. Biometria geralmente em Abu Dhabi.'
  WHEN 8 THEN 'Fase 8 - Entrega do ID (5 dias). Aguardar emissao e recebimento do Emirates ID. Preparar presente, agendar entrega e concluir processo. Se houver recusas anteriores, usar texto padrao de revisao de anexos e selos na reaplicacao.'
  ELSE instructions_pt
END
WHERE service_id = 2;

-- Execute uma vez em producao para adicionar colunas sem recriar tabela:
-- ALTER TABLE checklist_templates ADD COLUMN IF NOT EXISTS instructions_pt TEXT;
-- ALTER TABLE checklist_templates ADD COLUMN IF NOT EXISTS instructions_en TEXT;
-- ALTER TABLE client_checklist ADD COLUMN IF NOT EXISTS notes TEXT;

-- SERVICE 3: CNH EM DUBAI
INSERT INTO checklist_templates (service_id, step_order, title_pt, title_en, percentage) VALUES
(3, 1,  'Enviar formulário JotForm ao cliente',               'Send JotForm to client',                     0),
(3, 2,  'Enviar link de acesso ao sistema',                   'Send system access link',                    5),
(3, 3,  'Pagamento à autoescola Mohamed',                     'Payment to Mohamed driving school',          10),
(3, 4,  'RTA Number — enviar número ao cliente',              'RTA Number — send to client',                18),
(3, 5,  'Exame de vista — cliente escolhe local',             'Eye exam — client chooses location',         25),
(3, 6,  'Pagar exame de vista',                               'Pay eye exam',                               30),
(3, 7,  'Enviar simulado ao cliente',                         'Send practice test to client',               40),
(3, 8,  'Cliente avisa quando pronto para prova teórica',     'Client notifies when ready for theory test', 45),
(3, 9,  'Agendar prova teórica com Mohamed',                  'Schedule theory test with Mohamed',          55),
(3, 10, 'Agendar aula prática 1H',                            'Schedule 1H practical lesson',               65),
(3, 11, 'Agendar prova prática',                              'Schedule practical test',                    75),
(3, 12, 'Cliente passou? SIM = concluído / NÃO = remarcar',  'Client passed? YES = done / NO = reschedule',85),
(3, 13, 'Processo concluído 🎉',                              'Process completed 🎉',                       100)
ON CONFLICT DO NOTHING;


-- ============================================================
-- 7. FIRST ADMIN USER
-- ============================================================
-- Após criar seu usuário via registro normal, execute:
--
-- UPDATE profiles SET role = 'admin' WHERE email = 'seu@email.com';
--
-- (Ou execute direto no Supabase Table Editor)


-- ============================================================
-- CONFIGURAÇÃO SUPABASE — Checklist rápido
-- ============================================================
-- ✅ Authentication > Settings > Disable "Confirm email" (para admin criar clientes)
-- ✅ Storage > Criar bucket "documents" (private)
-- ✅ Substituir SUPABASE_URL e SUPABASE_ANON_KEY em js/config.js
-- ✅ Atualizar COMPANY_WHATSAPP em js/config.js
-- ✅ Após primeiro deploy: UPDATE profiles SET role = 'admin' WHERE id = '<seu_uuid>';
