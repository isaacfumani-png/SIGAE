# SIGAE POLO CSU — Sistema de Gestão de Esportes e Lazer

Sistema Integrado de Gestão de Esportes e Lazer para o Polo CSU (Centro Social Urbano), desenvolvido com arquitetura **Single Page Application (SPA)** leve e moderna (vanilla JavaScript, ES Modules, Alpine.js, Tailwind CSS e Supabase).

---

## 🔑 Credenciais de Acesso ao Sistema

- **Usuário**: `isaac` (ou `isaac@csu.gov.br`)
- **Senha**: `123`

---

## 📋 Sumário Executivo & Plano de Desenvolvimento

### 1. Visão Geral do Sistema
O **SIGAE Polo CSU** é uma plataforma corporativa web desenvolvida para otimizar o atendimento, controle de vagas, chamadas diárias por QR Code e acompanhamento preventivo de evasão esportiva em equipamentos públicos municipais.

### 2. Mapeamento do Banco de Dados Supabase (PostgreSQL 15+)
O esquema SQL do banco de dados encontra-se em `SPECS/schema_supabase_polo_csu.sql`. As tabelas e estruturas principais são:
- **`perfis`**: Perfis de usuário estendendo `auth.users` (`admin`, `gestor`, `professor`, `recepcao`).
- **`modalidades`**: Catálogo desportivo (`exige_atestado`, `ativa`).
- **`professores`**: Dados docentes e registros profissionais (CREF).
- **`alunos`**: Cadastro de praticantes com validação de atestado e consentimento LGPD.
- **`turmas`**: Grade horária, vagas totais e remanescentes com triggers de atualização.
- **`matriculas`**: Vínculo aluno-turma com verificação de idade e validação sanitária.
- **`presenca`**: Registro de chamadas diárias via QR Code, manual ou lista.
- **`alertas_faltas`**: Triggers para detecção automática de evasão (3+ faltas consecutivas).
- **`vw_turmas_resumo`, `vw_frequencia_diaria`, `vw_alertas_faltas`**: Views analíticas utilizadas nos painéis de gestão.

---

## ⚙️ Controle de Service Worker (`sw.js`)

O carregamento e registro do **Service Worker (`sw.js`)** é configurado em `app/js/config.js`:

```javascript
export const ENABLE_SERVICE_WORKER = false; // Alterne para true caso deseje ativar o cache PWA offline
```

Por padrão, a variável está definida como `false` para evitar interferência de cache durante o desenvolvimento e uso diário.

---

## 🎨 Design System & Interfaces Google Stitch (`THEME/`)

As interfaces foram criadas seguindo rigorosamente o Design System do projeto (`SPECS/Design MD.md`):
- **Cores Oficiais**:
  - Primary / Container: `#191B62`
  - Secondary / Accent: `#B32E5E`
  - Tertiary / Olive: `#646953`
  - Background / Low Surface: `#F9ECE5`
  - Neutral / Muted: `#D7CCC8`
- **Tipografia**:
  - Títulos & Headers: **Poppins**
  - Textos & Tabelas: **Open Sans** (com suporte a `font-data-tabular`)
- **Ícones**: Google Material Symbols Outlined (sem uso de emojis).

### Módulos e Páginas Mapeadas
1. **`/#/dashboard`** (`app/pages/dashboard.html`): Painel operacional com ocupação por modalidade, turmas do turno e alertas de evasão.
2. **`/#/turmas`** (`app/pages/turmas.html`): Grade horária, alternância entre visualização em cards e visão tabular.
3. **`/#/matriculas`** (`app/pages/matriculas.html`): Gestão de vagas, triagem de laudos médicos e emissão de crachás/QR Code.
4. **`/#/frequencia`** (`app/pages/frequencia.html`): Terminal de check-in com leitor QR Code, simulação de leitura e registro de ausências.
5. **`/#/alunos`** (`app/pages/alunos.html`): Cadastro de alunos, prontuário individual e conformidade LGPD.
6. **`/#/professores`** (`app/pages/professores.html`): Cadastro e gestão de instrutores e turmas sob responsabilidade.
7. **`/#/modalidades`** (`app/pages/modalidades.html`): Configuração de modalidades esportivas e exigência de atestados.
8. **`/#/relatorios`** (`app/pages/relatorios.html`): Geração e exportação de relatórios em planilha Excel (`.xlsx`) e PDF.
9. **`/#/login`** (`app/pages/login.html`): Autenticação de usuários (`isaac` / `123`).

---

## 🔑 Credenciais & Conectividade Supabase

- **REST Endpoint**: `https://fadvfvevitqcvyazzrtt.supabase.co/rest/v1/`
- **Chave Pública (Publishable)**: `sb_publishable_Mmicx17voeM8ZLOkTCdiLQ_RM9AGQUX`

---

## 🚀 Como Executar Localmente

Como a aplicação é construída com **ES Modules** nativos, basta servir a pasta raiz com qualquer servidor HTTP estático:

```bash
# Utilizando Python 3
python3 -m http.server 8080

# Ou utilizando npx serve
npx serve .
```

Acesse em seu navegador: `http://localhost:8080/#/login`
