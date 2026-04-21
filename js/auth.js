// ====================================
// BrasilDubai Portal — Auth Helpers
// ====================================

async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser();
  return user || null;
}

async function getCurrentProfile() {
  const user = await getCurrentUser();
  if (!user) return null;

  const { data, error } = await supabase
    .from('profiles')
    .select('*, services(id, slug, name_pt, name_en, jotform_link, whatsapp_number)')
    .eq('id', user.id)
    .single();

  if (error || !data) return null;
  return { ...data, email: user.email };
}

function redirectToDashboard(role) {
  const base = getBasePath();
  switch (role) {
    case 'admin':    window.location.href = base + '/admin/index.html'; break;
    case 'employee': window.location.href = base + '/employee/index.html'; break;
    default:         window.location.href = base + '/client/index.html'; break;
  }
}

// Works both when served from root and from subdirs
function getBasePath() {
  const parts = window.location.pathname.split('/');
  // If we're inside a subdir (client/, employee/, admin/), go up one
  const subdirs = ['client', 'employee', 'admin'];
  if (subdirs.includes(parts[parts.length - 2])) {
    return '..';
  }
  return '.';
}

async function requireAuth(allowedRoles = null) {
  const profile = await getCurrentProfile();

  if (!profile) {
    window.location.href = getBasePath() + '/index.html';
    return null;
  }

  if (allowedRoles && !allowedRoles.includes(profile.role)) {
    redirectToDashboard(profile.role);
    return null;
  }

  return profile;
}

async function initPage(allowedRoles = null) {
  const profile = await requireAuth(allowedRoles);
  if (!profile) return null;

  // Populate header
  const userEl = document.getElementById('headerUser');
  if (userEl) userEl.textContent = profile.full_name;

  const roleEl = document.getElementById('headerRole');
  if (roleEl) {
    const labels = { admin: t('role_admin'), employee: t('role_employee'), client: t('role_client') };
    roleEl.textContent = labels[profile.role] || profile.role;
  }

  applyTranslations();
  return profile;
}

async function logout() {
  await supabase.auth.signOut();
  window.location.href = getBasePath() + '/index.html';
}

// Build common header HTML
function buildHeader(activePage) {
  return `
    <header class="app-header">
      <a class="header-logo" href="#">🇧🇷 BrasilDubai</a>
      <div class="header-actions">
        <span class="header-user" id="headerUser">…</span>
        <span class="header-role-badge" id="headerRole"></span>
        <button class="lang-btn-header" onclick="toggleLang()">🇺🇸 EN</button>
        <button class="btn-logout" onclick="logout()" data-i18n="logout">Sair</button>
      </div>
    </header>
  `;
}
