// ====================================
// BrasilDubai Portal — Config & i18n
// ====================================

// ⚠️  CONFIGURE THESE VALUES before deploying
const SUPABASE_URL     = 'https://SEU_PROJETO.supabase.co';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';

// WhatsApp da empresa (formato: 55 + DDD + número, sem + nem espaços)
const COMPANY_WHATSAPP = '971500000000';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ====================================
// SERVICES & CHECKLISTS (static data)
// ====================================

const SERVICES_DATA = {
  freezone: {
    id: 1,
    slug: 'freezone',
    icon: '🏢',
    name: { pt: 'Abertura de Empresa (Freezone)', en: 'Company Setup (Freezone)' },
    desc: {
      pt: 'Abra sua empresa em Dubai de forma rápida e segura. Processo 100% online com suporte completo da nossa equipe.',
      en: 'Open your company in Dubai quickly and safely. 100% online process with full support from our team.'
    }
  },
  visa: {
    id: 2,
    slug: 'visa',
    icon: '🛂',
    name: { pt: 'Visto de Independente', en: 'Independent Residency Visa' },
    desc: {
      pt: 'Obtenha seu visto de residência independente em Dubai. Acompanhamos todo o processo do início ao fim.',
      en: 'Get your independent residency visa in Dubai. We handle the entire process from start to finish.'
    }
  },
  cnh: {
    id: 3,
    slug: 'cnh',
    icon: '🚗',
    name: { pt: 'CNH em Dubai', en: "Driver's License in Dubai" },
    desc: {
      pt: 'Converta ou tire sua CNH em Dubai com total suporte. Agendamos tudo para você.',
      en: "Convert or get your driver's license in Dubai with full support. We schedule everything for you."
    }
  }
};

// ====================================
// TRANSLATIONS
// ====================================

const translations = {
  pt: {
    // Auth
    login_title: 'Bem-vindo de volta',
    email: 'Email',
    password: 'Senha',
    enter: 'Entrar',
    no_account: 'Não tem conta?',
    register_link: 'Criar conta',
    register_title: 'Criar conta',
    full_name: 'Nome completo',
    whatsapp_label: 'WhatsApp',
    whatsapp_ph: '+971 50 000 0000',
    already_account: 'Já tem conta?',
    login_link: 'Fazer login',
    registering: 'Criando conta...',
    logging_in: 'Entrando...',

    // Navigation
    my_process: 'Meu Processo',
    checklist: 'Checklist',
    invoice: 'Fatura',
    services: 'Serviços',
    documents: 'Documentos',
    clients: 'Clientes',
    add_client: 'Novo Cliente',
    add_invoice: 'Fatura',
    manage_users: 'Usuários',
    reports: 'Relatórios',

    // Client
    open_invoice: 'Fatura em Aberto',
    talk_team: 'Falar com a equipe',
    pay_whatsapp: 'Pagar via WhatsApp',
    due_date: 'Vencimento',
    no_invoice: 'Nenhuma fatura em aberto ✅',
    hire: 'Quero Contratar',
    upload_doc: 'Enviar Documento',
    download: 'Baixar',
    no_documents: 'Nenhum documento enviado ainda.',
    process_label: 'Processo:',
    progress_label: 'Progresso:',

    // Status
    done: 'Concluído ✅',
    in_progress: 'Em andamento ⏳',
    pending: 'Pendente 🔴',
    status_done: '✅ Feito',
    status_in_progress: '⏳ Em andamento',
    status_pending: '🔴 Pendente',

    // Employee
    search_client: 'Buscar cliente...',
    service_col: 'Serviço',
    progress_col: 'Progresso',
    select_client: 'Selecione um cliente ao lado para ver o checklist',
    no_clients: 'Nenhum cliente encontrado',
    update_checklist: 'Atualizar Checklist',

    // Admin
    client_name: 'Nome do Cliente',
    client_email: 'Email',
    client_password: 'Senha Inicial',
    client_whatsapp: 'WhatsApp do Cliente',
    select_service: 'Serviço Contratado',
    select_service_ph: 'Selecione o serviço...',
    wa_preview_title: '📱 Mensagem WhatsApp gerada:',
    send_whatsapp: 'Enviar via WhatsApp',
    copy_msg: 'Copiar mensagem',
    create_client: 'Cadastrar Cliente',
    creating: 'Cadastrando...',
    jotform_link_label: 'Link JotForm do serviço',
    invoice_desc: 'Descrição da Fatura',
    invoice_amount: 'Valor',
    invoice_currency: 'Moeda',
    invoice_due: 'Vencimento',
    invoice_client: 'Cliente',
    add_invoice_btn: 'Adicionar Fatura',
    mark_paid: 'Marcar como pago',
    paid_label: 'Pago',
    unpaid_label: 'Em aberto',

    // Stats
    total_clients: 'Clientes',
    active_processes: 'Em Andamento',
    completed_label: 'Concluídos',

    // Toast / alerts
    status_updated: 'Status atualizado!',
    client_created: 'Cliente cadastrado com sucesso!',
    error_occurred: 'Ocorreu um erro. Tente novamente.',
    file_uploaded: 'Arquivo enviado com sucesso!',
    copied: 'Mensagem copiada!',
    invoice_added: 'Fatura adicionada!',

    // Misc
    loading: 'Carregando...',
    logout: 'Sair',
    export_csv: 'Exportar CSV',
    close: 'Fechar',
    save: 'Salvar',
    cancel: 'Cancelar',
    name_col: 'Nome',
    email_col: 'Email',
    role_col: 'Perfil',
    service_label: 'Serviço',
    actions_col: 'Ações',
    amount_col: 'Valor',
    status_col: 'Status',
    view_col: 'Ver',
    role_admin: 'Admin',
    role_employee: 'Funcionário',
    role_client: 'Cliente',
    all_clients: 'Todos os Clientes',
    delete: 'Excluir',
    confirm_delete: 'Tem certeza que deseja excluir este item?',
    no_invoices: 'Nenhuma fatura cadastrada',
  },

  en: {
    // Auth
    login_title: 'Welcome back',
    email: 'Email',
    password: 'Password',
    enter: 'Sign In',
    no_account: "Don't have an account?",
    register_link: 'Create account',
    register_title: 'Create account',
    full_name: 'Full name',
    whatsapp_label: 'WhatsApp',
    whatsapp_ph: '+971 50 000 0000',
    already_account: 'Already have an account?',
    login_link: 'Sign in',
    registering: 'Creating account...',
    logging_in: 'Signing in...',

    // Navigation
    my_process: 'My Process',
    checklist: 'Checklist',
    invoice: 'Invoice',
    services: 'Services',
    documents: 'Documents',
    clients: 'Clients',
    add_client: 'New Client',
    add_invoice: 'Invoice',
    manage_users: 'Users',
    reports: 'Reports',

    // Client
    open_invoice: 'Open Invoice',
    talk_team: 'Talk to our team',
    pay_whatsapp: 'Pay via WhatsApp',
    due_date: 'Due date',
    no_invoice: 'No open invoices ✅',
    hire: 'I Want This',
    upload_doc: 'Upload Document',
    download: 'Download',
    no_documents: 'No documents uploaded yet.',
    process_label: 'Process:',
    progress_label: 'Progress:',

    // Status
    done: 'Done ✅',
    in_progress: 'In progress ⏳',
    pending: 'Pending 🔴',
    status_done: '✅ Done',
    status_in_progress: '⏳ In progress',
    status_pending: '🔴 Pending',

    // Employee
    search_client: 'Search client...',
    service_col: 'Service',
    progress_col: 'Progress',
    select_client: 'Select a client on the left to view their checklist',
    no_clients: 'No clients found',
    update_checklist: 'Update Checklist',

    // Admin
    client_name: 'Client Name',
    client_email: 'Email',
    client_password: 'Initial Password',
    client_whatsapp: "Client's WhatsApp",
    select_service: 'Contracted Service',
    select_service_ph: 'Select service...',
    wa_preview_title: '📱 Generated WhatsApp message:',
    send_whatsapp: 'Send via WhatsApp',
    copy_msg: 'Copy message',
    create_client: 'Register Client',
    creating: 'Registering...',
    jotform_link_label: 'Service JotForm link',
    invoice_desc: 'Invoice Description',
    invoice_amount: 'Amount',
    invoice_currency: 'Currency',
    invoice_due: 'Due Date',
    invoice_client: 'Client',
    add_invoice_btn: 'Add Invoice',
    mark_paid: 'Mark as paid',
    paid_label: 'Paid',
    unpaid_label: 'Open',

    // Stats
    total_clients: 'Clients',
    active_processes: 'In Progress',
    completed_label: 'Completed',

    // Toast / alerts
    status_updated: 'Status updated!',
    client_created: 'Client registered successfully!',
    error_occurred: 'An error occurred. Please try again.',
    file_uploaded: 'File uploaded successfully!',
    copied: 'Message copied!',
    invoice_added: 'Invoice added!',

    // Misc
    loading: 'Loading...',
    logout: 'Logout',
    export_csv: 'Export CSV',
    close: 'Close',
    save: 'Save',
    cancel: 'Cancel',
    name_col: 'Name',
    email_col: 'Email',
    role_col: 'Role',
    service_label: 'Service',
    actions_col: 'Actions',
    amount_col: 'Amount',
    status_col: 'Status',
    view_col: 'View',
    role_admin: 'Admin',
    role_employee: 'Employee',
    role_client: 'Client',
    all_clients: 'All Clients',
    delete: 'Delete',
    confirm_delete: 'Are you sure you want to delete this item?',
    no_invoices: 'No invoices found',
  }
};

// ====================================
// i18n HELPERS
// ====================================

let currentLang = localStorage.getItem('bd_lang') || 'pt';

function t(key) {
  return translations[currentLang][key] || key;
}

function setLang(lang) {
  currentLang = lang;
  localStorage.setItem('bd_lang', lang);
  applyTranslations();
}

function toggleLang() {
  setLang(currentLang === 'pt' ? 'en' : 'pt');
}

function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
      el.placeholder = t(key);
    } else {
      el.textContent = t(key);
    }
  });
  document.querySelectorAll('[data-i18n-ph]').forEach(el => {
    el.placeholder = t(el.getAttribute('data-i18n-ph'));
  });
  document.querySelectorAll('.lang-toggle, .lang-btn-header').forEach(btn => {
    btn.textContent = currentLang === 'pt' ? '🇺🇸 EN' : '🇧🇷 PT';
  });
}

// ====================================
// UTILITY HELPERS
// ====================================

function showToast(message, type = '') {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = message;
  toast.className = `toast show ${type}`;
  setTimeout(() => { toast.className = 'toast'; }, 3500);
}

function formatCurrency(amount, currency = 'AED') {
  const n = parseFloat(amount);
  return `${currency} ${n.toLocaleString('en-AE', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function formatDate(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr + 'T00:00:00');
  return d.toLocaleDateString(currentLang === 'pt' ? 'pt-BR' : 'en-AE', {
    day: '2-digit', month: '2-digit', year: 'numeric'
  });
}

function formatDateTime(dateStr) {
  if (!dateStr) return '—';
  const d = new Date(dateStr);
  return d.toLocaleDateString(currentLang === 'pt' ? 'pt-BR' : 'en-AE', {
    day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit'
  });
}

function waLink(phone, message) {
  return `https://wa.me/${phone.replace(/\D/g, '')}?text=${encodeURIComponent(message)}`;
}

function getServiceName(slug) {
  const svc = SERVICES_DATA[slug];
  if (!svc) return slug;
  return svc.name[currentLang] || svc.name.pt;
}

function getServiceSlugById(id) {
  for (const [slug, data] of Object.entries(SERVICES_DATA)) {
    if (data.id === id) return slug;
  }
  return null;
}

function calcProgress(steps) {
  if (!steps || steps.length === 0) return 0;
  const done = steps.filter(s => s.status === 'done').length;
  return Math.round((done / steps.length) * 100);
}

function showLoading(containerId) {
  const el = document.getElementById(containerId);
  if (el) el.innerHTML = `<div class="loading"><div class="spinner"></div><p>${t('loading')}</p></div>`;
}
