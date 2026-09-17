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
  const hash = window.location.hash || '#/dashboard';
  const pagePath = routes[hash] || routes['#/dashboard'];
  const appContainer = document.getElementById('main-content');

  // Verificar sessão se não for tela de login
  if (hash !== '#/login') {
    const session = await db.getSession();
    if (!session) {
      window.location.hash = '#/login';
      return;
    }
  }

  try {
    const response = await fetch(pagePath);
    if (!response.ok) throw new Error(`Página não encontrada: ${pagePath}`);
    const html = await response.text();
    if (appContainer) {
      appContainer.innerHTML = html;
      // Re-inicializa componentes Alpine na nova view se necessário
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
