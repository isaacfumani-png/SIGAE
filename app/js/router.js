// router.js - Gerenciador de Roteamento SPA baseado em hash
import { db } from './db.js';

const routes = {
  '#/dashboard': 'app/pages/dashboard.html',
  '#/turmas': 'app/pages/turmas.html',
  '#/matriculas': 'app/pages/matriculas.html',
  '#/frequencia': 'app/pages/frequencia.html',
  '#/alunos': 'app/pages/alunos.html',
  '#/professores': 'app/pages/professores.html',
  '#/modalidades': 'app/pages/modalidades.html',
  '#/relatorios': 'app/pages/relatorios.html',
  '#/login': 'app/pages/login.html'
};

export async function navigateTo(hash) {
  window.location.hash = hash;
}

export async function handleRouting() {
  const hash = window.location.hash || '#/login';
  const isLoginPage = (hash === '#/login');

  // Ajusta visibilidade do layout no body para isolar a tela de login
  if (isLoginPage) {
    document.body.classList.add('is-login-page');
  } else {
    document.body.classList.remove('is-login-page');
  }

  // Verificar autenticação se não for tela de login
  if (!isLoginPage) {
    const user = Alpine.store('app')?.user;
    if (!user) {
      window.location.hash = '#/login';
      return;
    }
  } else {
    // Se estiver no login e já estiver autenticado, vai para o dashboard
    const user = Alpine.store('app')?.user;
    if (user) {
      window.location.hash = '#/dashboard';
      return;
    }
  }

  const pagePath = routes[hash] || (Alpine.store('app')?.user ? routes['#/dashboard'] : routes['#/login']);
  const appContainer = document.getElementById('main-content');

  try {
    const response = await fetch(pagePath);
    if (!response.ok) throw new Error(`Página não encontrada: ${pagePath}`);
    const html = await response.text();
    if (appContainer) {
      appContainer.innerHTML = html;
    }
    updateActiveNav(hash);
  } catch (error) {
    console.error('Erro ao carregar rota:', error);
    if (appContainer) {
      appContainer.innerHTML = `<div class="p-6 text-red-600 font-bold">Erro ao carregar a página. Verifique o console.</div>`;
    }
  }
}

function updateActiveNav(currentHash) {
  const navLinks = document.querySelectorAll('aside nav a');
  navLinks.forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentHash) {
      link.className = 'flex items-center gap-gutter-sm px-gutter-sm py-2.5 transition-colors bg-secondary text-on-secondary font-label-lg rounded-lg shadow-sm';
    } else {
      link.className = 'flex items-center gap-gutter-sm px-gutter-sm py-2.5 rounded-lg font-body-md text-body-md text-surface-variant hover:bg-surface-variant/10 hover:text-on-primary transition-colors';
    }
  });
}

export function initRouter() {
  window.addEventListener('hashchange', handleRouting);
  window.addEventListener('DOMContentLoaded', handleRouting);
}
