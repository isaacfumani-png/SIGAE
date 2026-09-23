// config.js - Constantes e Configuração do Supabase

export const SUPABASE_URL = 'https://fadvfvevitqcvyazzrtt.supabase.co';
export const SUPABASE_REST_ENDPOINT = 'https://fadvfvevitqcvyazzrtt.supabase.co/rest/v1/';
export const SUPABASE_ANON_KEY = 'sb_publishable_Mmicx17voeM8ZLOkTCdiLQ_RM9AGQUX';

// Alternância de Service Worker (offline cache sw.js) - Desativado por padrão conforme solicitado
export const ENABLE_SERVICE_WORKER = false;

export const ROLES = {
  ADMIN: 'admin',
  GESTOR: 'gestor',
  PROFESSOR: 'professor',
  RECEPCAO: 'recepcao'
};

export const LIMITE_FALTAS_ALERTA = 3;
