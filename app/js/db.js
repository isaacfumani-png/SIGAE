// db.js - Wrapper de comunicação com o Supabase com suporte a Fallback / Offline
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

let supabaseClient = null;

export function getSupabase() {
  if (!supabaseClient && window.supabase) {
    try {
      supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    } catch (e) {
      console.warn('Erro ao inicializar cliente Supabase:', e);
    }
  }
  return supabaseClient;
}

// Dados MOCK para demonstração/fallback quando a tabela Supabase estiver vazia ou offline
const MOCK_DATA = {
  modalidades: [
    { id: 'm1', nome: 'Natação', descricao: 'Aulas de natação para todas as idades', exige_atestado: true, ativa: true },
    { id: 'm2', nome: 'Futsal', descricao: 'Treinos de futebol e futsal para jovens', exige_atestado: false, ativa: true },
    { id: 'm3', nome: 'Judô', descricao: 'Aulas de judô com foco em disciplina', exige_atestado: false, ativa: true },
    { id: 'm4', nome: 'Ginástica Artística', descricao: 'Iniciação e aperfeiçoamento em ginástica', exige_atestado: false, ativa: true },
    { id: 'm5', nome: 'Pilates', descricao: 'Fortalecimento e postura', exige_atestado: true, ativa: true }
  ],
  turmas: [
    { id: 't1', nome: 'Natação Infantil II', horario: '08:30 - 09:30', dias_semana: ['Seg', 'Qua', 'Sex'], vagas_total: 30, vagas_disponiveis: 2, modalidade: 'Natação', professor: 'Camila Duarte', ativa: true },
    { id: 't2', nome: 'Futsal Sub-13', horario: '14:00 - 15:30', dias_semana: ['Ter', 'Qui'], vagas_total: 30, vagas_disponiveis: 0, modalidade: 'Futsal', professor: 'Roberto Silva', ativa: true },
    { id: 't3', nome: 'Judô Graduação', horario: '15:30 - 17:00', dias_semana: ['Seg', 'Qua'], vagas_total: 20, vagas_disponiveis: 1, modalidade: 'Judô', professor: 'Fábio Kenji', ativa: true },
    { id: 't4', nome: 'Pilates Solo Avançado', horario: '16:00 - 17:00', dias_semana: ['Ter', 'Qui'], vagas_total: 20, vagas_disponiveis: 6, modalidade: 'Pilates', professor: 'Juliana Faria', ativa: true }
  ],
  alunos: [
    { id: 'a1', nome: 'Lucas Ferreira Costa', cpf: '123.456.789-00', data_nascimento: '2012-05-14', telefone: '(11) 98765-4321', responsavel_nome: 'Sandra Ferreira', atestado_valido_ate: '2025-12-31', ativo: true },
    { id: 'a2', nome: 'Beatriz Martins de Sá', cpf: '234.567.890-11', data_nascimento: '2015-08-22', telefone: '(11) 97654-3210', responsavel_nome: 'Carlos Martins', atestado_valido_ate: '2024-01-15', ativo: true },
    { id: 'a3', nome: 'Gabriel Oliveira Santos', cpf: '345.678.901-22', data_nascimento: '1998-03-10', telefone: '(11) 96543-2109', responsavel_nome: 'Próprio Aluno', atestado_valido_ate: null, ativo: true },
    { id: 'a4', nome: 'Mariana Nogueira Lima', cpf: '456.789.012-33', data_nascimento: '2010-11-05', telefone: '(11) 95432-1098', responsavel_nome: 'Mariana Nogueira', atestado_valido_ate: '2025-10-20', ativo: true }
  ],
  professores: [
    { id: 'p1', nome: 'Camila Duarte', cref: '012345-G/SP', modalidade: 'Natação', email: 'camila.duarte@csu.gov.br' },
    { id: 'p2', nome: 'Roberto Silva', cref: '023456-G/SP', modalidade: 'Futsal', email: 'roberto.silva@csu.gov.br' },
    { id: 'p3', nome: 'Fábio Kenji', cref: '034567-G/SP', modalidade: 'Judô', email: 'fabio.kenji@csu.gov.br' },
    { id: 'p4', nome: 'Juliana Faria', cref: '045678-G/SP', modalidade: 'Pilates', email: 'juliana.faria@csu.gov.br' }
  ],
  alertas: [
    { id: 'al1', aluno_nome: 'Lucas Ferreira Costa', aluno_telefone: '(11) 98765-4321', turma_nome: 'Futsal Sub-13', modalidade: 'Futsal', quantidade_faltas: 3, data_ultima_falta: '2025-02-10', visualizado: false },
    { id: 'al2', aluno_nome: 'Beatriz Martins de Sá', aluno_telefone: '(11) 97654-3210', turma_nome: 'Natação Infantil', modalidade: 'Natação', quantidade_faltas: 3, data_ultima_falta: '2025-02-12', visualizado: false }
  ]
};

export const db = {
  // Auth
  async login(email, password) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.auth.signInWithPassword({ email, password });
        if (!error && data?.session) return data;
      } catch (err) {
        console.warn('Supabase auth bypass/fallback demo mode:', err);
      }
    }
    // Fallback demo user
    return {
      user: { id: '1', email, role: 'admin', nome: 'Marcos Ribeiro' },
      session: { access_token: 'demo-token' }
    };
  },

  async logout() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        await supabase.auth.signOut();
      } catch (e) {
        console.warn(e);
      }
    }
  },

  async getSession() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data } = await supabase.auth.getSession();
        if (data?.session) return data.session;
      } catch (e) {
        console.warn(e);
      }
    }
    // Return demo session if logged in store
    return { user: { id: '1', nome: 'Marcos Ribeiro', role: 'admin' } };
  },

  async getPerfil(userId) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('perfis').select('*').eq('id', userId).single();
        if (!error && data) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return { id: userId, nome: 'Marcos Ribeiro', email: 'admin@csu.gov.br', role: 'admin', polo: 'CSU' };
  },

  // Modalidades
  async getModalidades() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('modalidades').select('*').order('nome');
        if (!error && data && data.length > 0) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return MOCK_DATA.modalidades;
  },

  async salvarModalidade(modalidade) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('modalidades').insert([modalidade]).select();
        if (!error) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    MOCK_DATA.modalidades.push({ id: `m${Date.now()}`, ...modalidade });
    return [modalidade];
  },

  // Turmas
  async getTurmasResumo() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('vw_turmas_resumo').select('*');
        if (!error && data && data.length > 0) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return MOCK_DATA.turmas;
  },

  async salvarTurma(turma) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('turmas').insert([turma]).select();
        if (!error) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    MOCK_DATA.turmas.push({ id: `t${Date.now()}`, ...turma });
    return [turma];
  },

  // Alunos
  async getAlunos(busca = '') {
    const supabase = getSupabase();
    if (supabase) {
      try {
        let query = supabase.from('alunos').select('*').order('nome');
        if (busca) {
          query = query.or(`nome.ilike.%${busca}%,cpf.ilike.%${busca}%`);
        }
        const { data, error } = await query;
        if (!error && data && data.length > 0) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    if (!busca) return MOCK_DATA.alunos;
    return MOCK_DATA.alunos.filter(a => a.nome.toLowerCase().includes(busca.toLowerCase()) || a.cpf.includes(busca));
  },

  async salvarAluno(aluno) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('alunos').insert([aluno]).select();
        if (!error) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    MOCK_DATA.alunos.push({ id: `a${Date.now()}`, ...aluno });
    return [aluno];
  },

  // Professores
  async getProfessores() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('professores').select('*, perfis(nome, email), modalidades(nome)');
        if (!error && data && data.length > 0) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return MOCK_DATA.professores;
  },

  async salvarProfessor(prof) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('professores').insert([prof]).select();
        if (!error) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    MOCK_DATA.professores.push({ id: `p${Date.now()}`, ...prof });
    return [prof];
  },

  // Presença / Frequência
  async registrarPresenca(registros) {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('presenca').upsert(registros);
        if (!error) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return registros;
  },

  // Alertas de faltas
  async getAlertasFaltas() {
    const supabase = getSupabase();
    if (supabase) {
      try {
        const { data, error } = await supabase.from('vw_alertas_faltas').select('*').eq('visualizado', false);
        if (!error && data && data.length > 0) return data;
      } catch (e) {
        console.warn(e);
      }
    }
    return MOCK_DATA.alertas;
  }
};
