// config.js - Constantes e Configuração do Supabase

export const SUPABASE_URL = window.ENV?.SUPABASE_URL || 'https://sua-instancia.supabase.co';
export const SUPABASE_ANON_KEY = window.ENV?.SUPABASE_ANON_KEY || 'sua-anon-key-aqui';

export const ROLES = {
  ADMIN: 'admin',
  GESTOR: 'gestor',
  PROFESSOR: 'professor',
  RECEPCAO: 'recepcao'
};

export const LIMITE_FALTAS_ALERTA = 3;
