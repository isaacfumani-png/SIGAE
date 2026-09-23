// db.js - Wrapper de comunicação com o Supabase
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

let supabaseClient = null;

export function getSupabase() {
  if (!supabaseClient && window.supabase) {
    try {
      supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    } catch (e) {
      console.error('Erro ao inicializar cliente Supabase:', e);
    }
  }
  return supabaseClient;
}

export const db = {
  // Auth
  async login(email, password) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase não inicializado.');
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },

  async logout() {
    const supabase = getSupabase();
    if (supabase) {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
    }
  },

  async getSession() {
    const supabase = getSupabase();
    if (!supabase) return null;
    const { data, error } = await supabase.auth.getSession();
    if (error) throw error;
    return data?.session || null;
  },

  async getPerfil(userId) {
    const supabase = getSupabase();
    if (!supabase) return null;
    const { data, error } = await supabase.from('perfis').select('*').eq('id', userId).single();
    if (error) throw error;
    return data;
  },

  // Modalidades
  async getModalidades() {
    const supabase = getSupabase();
    if (!supabase) return [];
    const { data, error } = await supabase.from('modalidades').select('*').order('nome');
    if (error) throw error;
    return data || [];
  },

  async salvarModalidade(modalidade) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase indisponível');
    const { data, error } = await supabase.from('modalidades').insert([modalidade]).select();
    if (error) throw error;
    return data;
  },

  // Turmas
  async getTurmasResumo() {
    const supabase = getSupabase();
    if (!supabase) return [];
    const { data, error } = await supabase.from('vw_turmas_resumo').select('*');
    if (error) throw error;
    return data || [];
  },

  async salvarTurma(turma) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase indisponível');
    const { data, error } = await supabase.from('turmas').insert([turma]).select();
    if (error) throw error;
    return data;
  },

  // Alunos
  async getAlunos(busca = '') {
    const supabase = getSupabase();
    if (!supabase) return [];
    let query = supabase.from('alunos').select('*').order('nome');
    if (busca) {
      query = query.or(`nome.ilike.%${busca}%,cpf.ilike.%${busca}%`);
    }
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  },

  async salvarAluno(aluno) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase indisponível');
    const { data, error } = await supabase.from('alunos').insert([aluno]).select();
    if (error) throw error;
    return data;
  },

  // Professores
  async getProfessores() {
    const supabase = getSupabase();
    if (!supabase) return [];
    const { data, error } = await supabase.from('professores').select('*, perfis(nome, email), modalidades(nome)');
    if (error) throw error;
    return data || [];
  },

  async salvarProfessor(prof) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase indisponível');
    const { data, error } = await supabase.from('professores').insert([prof]).select();
    if (error) throw error;
    return data;
  },

  // Presença / Frequência
  async registrarPresenca(registros) {
    const supabase = getSupabase();
    if (!supabase) throw new Error('Cliente Supabase indisponível');
    const { data, error } = await supabase.from('presenca').upsert(registros);
    if (error) throw error;
    return data;
  },

  // Alertas de faltas
  async getAlertasFaltas() {
    const supabase = getSupabase();
    if (!supabase) return [];
    const { data, error } = await supabase.from('vw_alertas_faltas').select('*').eq('visualizado', false);
    if (error) throw error;
    return data || [];
  }
};
