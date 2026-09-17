// db.js - Wrapper de comunicação com o Supabase
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

let supabaseClient = null;

export function getSupabase() {
  if (!supabaseClient && window.supabase) {
    supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }
  return supabaseClient;
}

export const db = {
  // Auth
  async login(email, password) {
    const supabase = getSupabase();
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },

  async logout() {
    const supabase = getSupabase();
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  async getSession() {
    const supabase = getSupabase();
    if (!supabase) return null;
    const { data } = await supabase.auth.getSession();
    return data.session;
  },

  async getPerfil(userId) {
    const supabase = getSupabase();
    const { data, error } = await supabase
      .from('perfis')
      .select('*')
      .eq('id', userId)
      .single();
    if (error) throw error;
    return data;
  },

  // Modalidades
  async getModalidades() {
    const supabase = getSupabase();
    const { data, error } = await supabase.from('modalidades').select('*').order('nome');
    if (error) throw error;
    return data || [];
  },

  // Turmas
  async getTurmasResumo() {
    const supabase = getSupabase();
    const { data, error } = await supabase.from('vw_turmas_resumo').select('*');
    if (error) throw error;
    return data || [];
  },

  // Alunos
  async getAlunos(busca = '') {
    const supabase = getSupabase();
    let query = supabase.from('alunos').select('*').order('nome');
    if (busca) {
      query = query.or(`nome.ilike.%${busca}%,cpf.ilike.%${busca}%`);
    }
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  },

  // Salvar Frequência
  async registrarPresenca(registros) {
    const supabase = getSupabase();
    const { data, error } = await supabase.from('presenca').upsert(registros);
    if (error) throw error;
    return data;
  },

  // Alertas de faltas
  async getAlertasFaltas() {
    const supabase = getSupabase();
    const { data, error } = await supabase.from('vw_alertas_faltas').select('*').eq('visualizado', false);
    if (error) throw error;
    return data || [];
  }
};
