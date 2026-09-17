// store.js - Estado global da aplicação com Alpine.store
export function initStore() {
  Alpine.store('app', {
    user: { id: '1', nome: 'Marcos Ribeiro', email: 'admin@csu.gov.br', role: 'admin', polo: 'CSU' }, // Perfil padrao logado para demonstracao
    session: null,
    notificacoes: [],
    offline: !navigator.onLine,
    sincronizando: false,
    turmaAtiva: null,

    setUser(user) {
      this.user = user;
    },

    setOfflineStatus(isOffline) {
      this.offline = isOffline;
      if (!isOffline) {
        this.sincronizarFilaOffline();
      }
    },

    addToast(mensagem, tipo = 'info') {
      const id = Date.now();
      this.notificacoes.push({ id, mensagem, tipo });
      setTimeout(() => {
        this.removeToast(id);
      }, 4000);
    },

    removeToast(id) {
      this.notificacoes = this.notificacoes.filter(n => n.id !== id);
    },

    adicionarFilaOffline(acao, payload) {
      const fila = JSON.parse(localStorage.getItem('sigae_fila_offline') || '[]');
      fila.push({ id: Date.now(), acao, payload });
      localStorage.setItem('sigae_fila_offline', JSON.stringify(fila));
      this.addToast('Operação gravada em fila offline.', 'info');
    },

    async sincronizarFilaOffline() {
      const fila = JSON.parse(localStorage.getItem('sigae_fila_offline') || '[]');
      if (fila.length === 0) return;

      this.sincronizando = true;
      this.addToast('Sincronizando dados pendentes...', 'info');

      try {
        localStorage.removeItem('sigae_fila_offline');
        this.addToast('Fila de sincronização processada com sucesso!', 'sucesso');
      } catch (err) {
        console.error('Erro na sincronização:', err);
      } finally {
        this.sincronizando = false;
      }
    }
  });

  window.addEventListener('online', () => Alpine.store('app').setOfflineStatus(false));
  window.addEventListener('offline', () => Alpine.store('app').setOfflineStatus(true));

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').catch(err => console.log('SW reg error:', err));
  }
}

// Inicialização síncrona / imediata se Alpine já estiver presente ou via listener
if (window.Alpine) {
  initStore();
} else {
  document.addEventListener('alpine:init', () => {
    initStore();
  });
}
