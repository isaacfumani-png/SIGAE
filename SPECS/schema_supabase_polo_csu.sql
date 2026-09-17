-- ============================================================
-- SCHEMA: Sistema de Gestão de Esportes e Lazer — Polo CSU
-- Plataforma: Supabase (PostgreSQL 15+)
-- Instruções: Copie e cole no SQL Editor do Supabase
-- Ordem: Execute do início ao fim (dependências respeitadas)
-- ============================================================

-- ------------------------------------------------------------
-- 1. EXTENSÕES
-- ------------------------------------------------------------
extension if not exists "uuid-ossp";
extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- 2. TABELAS PRINCIPAIS
-- ------------------------------------------------------------

-- 2.1 Perfis (estende auth.users do Supabase Auth)
-- Cada usuário do sistema tem um perfil vinculado ao auth.users
create table if not exists public.perfis (
    id uuid references auth.users on delete cascade primary key,
    nome text not null,
    email text not null,
    telefone text,
    role text not null check (role in ('admin', 'gestor', 'professor', 'recepcao')),
    polo text default 'CSU',
    ativo boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.perfis is 'Perfis de usuários do sistema vinculados ao Supabase Auth';
comment on column public.perfis.role is 'admin=total; gestor=turmas/matriculas/relatorios; professor=frequencia; recepcao=cadastro/matricula';

-- 2.2 Modalidades esportivas
create table if not exists public.modalidades (
    id uuid default gen_random_uuid() primary key,
    nome text not null unique,
    descricao text,
    exige_atestado boolean default false,
    ativa boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.modalidades is 'Modalidades esportivas gerenciadas pela secretaria';
comment on column public.modalidades.exige_atestado is 'Se true, matrícula exige atestado médico válido';

-- 2.3 Professores
create table if not exists public.professores (
    id uuid default gen_random_uuid() primary key,
    perfil_id uuid references public.perfis(id) on delete set null,
    modalidade_id uuid references public.modalidades(id) on delete set null,
    cref text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.professores is 'Professores vinculados a perfis e modalidades';

-- 2.4 Alunos
create table if not exists public.alunos (
    id uuid default gen_random_uuid() primary key,
    nome text not null,
    cpf text unique,
    data_nascimento date,
    telefone text,
    email text,
    responsavel_nome text,
    responsavel_telefone text,
    endereco text,
    atestado_medico_url text,
    atestado_valido_ate date,
    observacoes text,
    lgpd_consentimento boolean default false,
    ativo boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.alunos is 'Cadastro de alunos das modalidades esportivas';
comment on column public.alunos.lgpd_consentimento is 'Consentimento para uso dos dados conforme LGPD';

-- 2.5 Turmas
create table if not exists public.turmas (
    id uuid default gen_random_uuid() primary key,
    modalidade_id uuid not null references public.modalidades(id) on delete restrict,
    professor_id uuid references public.professores(id) on delete set null,
    nome text not null,
    horario text not null,
    dias_semana text[] not null default '{}',
    vagas_total int not null default 0 check (vagas_total >= 0),
    vagas_disponiveis int not null default 0 check (vagas_disponiveis >= 0),
    idade_min int check (idade_min >= 0),
    idade_max int check (idade_max >= 0),
    ativa boolean default true,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.turmas is 'Turmas de cada modalidade com controle de vagas';

-- 2.6 Matrículas
create table if not exists public.matriculas (
    id uuid default gen_random_uuid() primary key,
    aluno_id uuid not null references public.alunos(id) on delete restrict,
    turma_id uuid not null references public.turmas(id) on delete restrict,
    status text not null check (status in ('ativa', 'cancelada', 'lista_espera', 'concluida')),
    data_matricula date not null default current_date,
    data_cancelamento date,
    motivo_cancelamento text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    unique(aluno_id, turma_id)
);

comment on table public.matriculas is 'Vínculo entre aluno e turma com controle de status';

-- 2.7 Presença
create table if not exists public.presenca (
    id uuid default gen_random_uuid() primary key,
    matricula_id uuid not null references public.matriculas(id) on delete cascade,
    data_aula date not null,
    presente boolean not null default false,
    checkin_por uuid references public.perfis(id) on delete set null,
    checkin_metodo text check (checkin_metodo in ('manual', 'qr', 'lista')),
    observacao text,
    created_at timestamptz default now(),
    updated_at timestamptz default now(),
    unique(matricula_id, data_aula)
);

comment on table public.presenca is 'Registro de frequência dos alunos por aula';

-- 2.8 Configurações do sistema
create table if not exists public.configuracoes (
    id uuid default gen_random_uuid() primary key,
    chave text not null unique,
    valor text not null,
    descricao text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

comment on table public.configuracoes is 'Configurações parametrizáveis do sistema';

-- 2.9 Alertas de faltas
create table if not exists public.alertas_faltas (
    id uuid default gen_random_uuid() primary key,
    matricula_id uuid not null references public.matriculas(id) on delete cascade,
    aluno_id uuid not null references public.alunos(id) on delete cascade,
    turma_id uuid not null references public.turmas(id) on delete cascade,
    quantidade_faltas int not null default 3,
    data_ultima_falta date not null,
    visualizado boolean default false,
    created_at timestamptz default now()
);

comment on table public.alertas_faltas is 'Alertas gerados automaticamente quando aluno atinge limite de faltas';

-- 2.10 Auditoria (opcional, mas recomendada para LGPD)
create table if not exists public.auditoria (
    id uuid default gen_random_uuid() primary key,
    tabela text not null,
    registro_id uuid,
    acao text not null check (acao in ('insert', 'update', 'delete')),
    dados_anteriores jsonb,
    dados_novos jsonb,
    executado_por uuid references public.perfis(id) on delete set null,
    created_at timestamptz default now()
);

comment on table public.auditoria is 'Log de auditoria para rastreabilidade LGPD';

-- ------------------------------------------------------------
-- 3. ÍNDICES
-- ------------------------------------------------------------
create index if not exists idx_alunos_cpf on public.alunos(cpf);
create index if not exists idx_alunos_nome on public.alunos(nome);
create index if not exists idx_matriculas_aluno on public.matriculas(aluno_id);
create index if not exists idx_matriculas_turma on public.matriculas(turma_id);
create index if not exists idx_matriculas_status on public.matriculas(status);
create index if not exists idx_presenca_matricula on public.presenca(matricula_id);
create index if not exists idx_presenca_data on public.presenca(data_aula);
create index if not exists idx_alertas_visualizado on public.alertas_faltas(visualizado);
create index if not exists idx_turmas_modalidade on public.turmas(modalidade_id);
create index if not exists idx_turmas_professor on public.turmas(professor_id);

-- ------------------------------------------------------------
-- 4. FUNÇÕES UTILITÁRIAS
-- ------------------------------------------------------------

-- 4.1 Calcular idade do aluno
CREATE OR REPLACE FUNCTION public.calcular_idade(data_nascimento date)
RETURNS int
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN date_part('year', age(data_nascimento));
END;
$$;

-- 4.2 Contar faltas consecutivas de uma matrícula
CREATE OR REPLACE FUNCTION public.contar_faltas_consecutivas(p_matricula_id uuid)
RETURNS int
LANGUAGE plpgsql
AS $$
DECLARE
    v_count int := 0;
    v_data date;
    v_presente boolean;
    cur CURSOR FOR
        SELECT data_aula, presente
        FROM public.presenca
        WHERE matricula_id = p_matricula_id
        ORDER BY data_aula DESC;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO v_data, v_presente;
        EXIT WHEN NOT FOUND;
        IF v_presente = false THEN
            v_count := v_count + 1;
        ELSE
            EXIT;
        END IF;
    END LOOP;
    CLOSE cur;
    RETURN v_count;
END;
$$;

-- 4.3 Atualizar timestamp de updated_at
CREATE OR REPLACE FUNCTION public.atualizar_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- Aplicar updated_at em todas as tabelas
CREATE TRIGGER tr_perfis_updated_at BEFORE UPDATE ON public.perfis
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_modalidades_updated_at BEFORE UPDATE ON public.modalidades
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_professores_updated_at BEFORE UPDATE ON public.professores
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_alunos_updated_at BEFORE UPDATE ON public.alunos
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_turmas_updated_at BEFORE UPDATE ON public.turmas
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_matriculas_updated_at BEFORE UPDATE ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_presenca_updated_at BEFORE UPDATE ON public.presenca
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();
CREATE TRIGGER tr_configuracoes_updated_at BEFORE UPDATE ON public.configuracoes
    FOR EACH ROW EXECUTE FUNCTION public.atualizar_updated_at();

-- 4.4 Criar perfil automaticamente ao registrar usuário no Auth
CREATE OR REPLACE FUNCTION public.criar_perfil_ao_registrar()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.perfis (id, nome, email, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome', NEW.email),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'recepcao')
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_auth_criar_perfil
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.criar_perfil_ao_registrar();

-- ------------------------------------------------------------
-- 5. TRIGGERS DE REGRAS DE NEGÓCIO
-- ------------------------------------------------------------

-- 5.1 Recalcular vagas disponíveis após INSERT/UPDATE/DELETE em matriculas
CREATE OR REPLACE FUNCTION public.recalcular_vagas()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'ativa' THEN
        UPDATE public.turmas
        SET vagas_disponiveis = vagas_disponiveis - 1
        WHERE id = NEW.turma_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status = 'ativa' AND NEW.status != 'ativa' THEN
            UPDATE public.turmas
            SET vagas_disponiveis = vagas_disponiveis + 1
            WHERE id = NEW.turma_id;
        ELSIF OLD.status != 'ativa' AND NEW.status = 'ativa' THEN
            UPDATE public.turmas
            SET vagas_disponiveis = vagas_disponiveis - 1
            WHERE id = NEW.turma_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.status = 'ativa' THEN
        UPDATE public.turmas
        SET vagas_disponiveis = vagas_disponiveis + 1
        WHERE id = OLD.turma_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER tr_matriculas_recalcular_vagas
    AFTER INSERT OR UPDATE OR DELETE ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.recalcular_vagas();

-- 5.2 Validar idade do aluno na matrícula
CREATE OR REPLACE FUNCTION public.validar_idade_matricula()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_idade int;
    v_idade_min int;
    v_idade_max int;
BEGIN
    SELECT public.calcular_idade(a.data_nascimento)
    INTO v_idade
    FROM public.alunos a
    WHERE a.id = NEW.aluno_id;

    SELECT t.idade_min, t.idade_max
    INTO v_idade_min, v_idade_max
    FROM public.turmas t
    WHERE t.id = NEW.turma_id;

    IF v_idade_min IS NOT NULL AND v_idade < v_idade_min THEN
        RAISE EXCEPTION 'Idade mínima não atingida. Idade: %, Mínima: %', v_idade, v_idade_min;
    END IF;

    IF v_idade_max IS NOT NULL AND v_idade > v_idade_max THEN
        RAISE EXCEPTION 'Idade máxima excedida. Idade: %, Máxima: %', v_idade, v_idade_max;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_matriculas_validar_idade
    BEFORE INSERT OR UPDATE ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.validar_idade_matricula();

-- 5.3 Validar atestado médico obrigatório
CREATE OR REPLACE FUNCTION public.validar_atestado_matricula()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_exige_atestado boolean;
    v_atestado_valido_ate date;
BEGIN
    SELECT m.exige_atestado
    INTO v_exige_atestado
    FROM public.modalidades m
    JOIN public.turmas t ON t.modalidade_id = m.id
    WHERE t.id = NEW.turma_id;

    IF v_exige_atestado = true THEN
        SELECT a.atestado_valido_ate
        INTO v_atestado_valido_ate
        FROM public.alunos a
        WHERE a.id = NEW.aluno_id;

        IF v_atestado_valido_ate IS NULL OR v_atestado_valido_ate < current_date THEN
            RAISE EXCEPTION 'Atestado médico obrigatório não encontrado ou vencido para esta modalidade.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_matriculas_validar_atestado
    BEFORE INSERT OR UPDATE ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.validar_atestado_matricula();

-- 5.4 Gerar alerta de faltas consecutivas
CREATE OR REPLACE FUNCTION public.gerar_alerta_faltas()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_faltas_consecutivas int;
    v_limite int;
    v_aluno_id uuid;
    v_turma_id uuid;
    v_existe_alerta boolean;
BEGIN
    -- Só processa se foi registrada uma FALTA
    IF NEW.presente = true THEN
        RETURN NEW;
    END IF;

    -- Busca limite configurado
    SELECT valor::int INTO v_limite
    FROM public.configuracoes
    WHERE chave = 'alerta_faltas_consecutivas';

    IF v_limite IS NULL THEN
        v_limite := 3;
    END IF;

    -- Conta faltas consecutivas
    SELECT public.contar_faltas_consecutivas(NEW.matricula_id)
    INTO v_faltas_consecutivas;

    IF v_faltas_consecutivas >= v_limite THEN
        -- Busca IDs relacionados
        SELECT m.aluno_id, m.turma_id
        INTO v_aluno_id, v_turma_id
        FROM public.matriculas m
        WHERE m.id = NEW.matricula_id;

        -- Verifica se já existe alerta não visualizado para esta matrícula
        SELECT EXISTS(
            SELECT 1 FROM public.alertas_faltas
            WHERE matricula_id = NEW.matricula_id AND visualizado = false
        ) INTO v_existe_alerta;

        IF NOT v_existe_alerta THEN
            INSERT INTO public.alertas_faltas (matricula_id, aluno_id, turma_id, quantidade_faltas, data_ultima_falta)
            VALUES (NEW.matricula_id, v_aluno_id, v_turma_id, v_faltas_consecutivas, NEW.data_aula);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_presenca_alerta_faltas
    AFTER INSERT ON public.presenca
    FOR EACH ROW EXECUTE FUNCTION public.gerar_alerta_faltas();

-- 5.5 Auditoria genérica (INSERT/UPDATE/DELETE)
CREATE OR REPLACE FUNCTION public.auditar_tabela()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := auth.uid();

    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.auditoria (tabela, registro_id, acao, dados_novos, executado_por)
        VALUES (TG_TABLE_NAME, NEW.id, 'insert', to_jsonb(NEW), v_user_id);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO public.auditoria (tabela, registro_id, acao, dados_anteriores, dados_novos, executado_por)
        VALUES (TG_TABLE_NAME, NEW.id, 'update', to_jsonb(OLD), to_jsonb(NEW), v_user_id);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO public.auditoria (tabela, registro_id, acao, dados_anteriores, executado_por)
        VALUES (TG_TABLE_NAME, OLD.id, 'delete', to_jsonb(OLD), v_user_id);
        RETURN OLD;
    END IF;
END;
$$;

-- Aplicar auditoria apenas em tabelas críticas (opcional, pode remover se impactar performance)
CREATE TRIGGER tr_auditoria_alunos AFTER INSERT OR UPDATE OR DELETE ON public.alunos
    FOR EACH ROW EXECUTE FUNCTION public.auditar_tabela();
CREATE TRIGGER tr_auditoria_matriculas AFTER INSERT OR UPDATE OR DELETE ON public.matriculas
    FOR EACH ROW EXECUTE FUNCTION public.auditar_tabela();

-- ------------------------------------------------------------
-- 6. ROW LEVEL SECURITY (RLS)
-- ------------------------------------------------------------

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.perfis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modalidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alunos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.turmas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matriculas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.presenca ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.alertas_faltas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auditoria ENABLE ROW LEVEL SECURITY;

-- 6.1 Políticas: perfis
CREATE POLICY "perfis_select_proprio" ON public.perfis
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "perfis_select_admin_gestor" ON public.perfis
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));
CREATE POLICY "perfis_update_proprio" ON public.perfis
    FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "perfis_all_admin" ON public.perfis
    FOR ALL USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role = 'admin'
    ));

-- 6.2 Políticas: modalidades
CREATE POLICY "modalidades_select_all" ON public.modalidades
    FOR SELECT USING (true);
CREATE POLICY "modalidades_all_admin_gestor" ON public.modalidades
    FOR ALL USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));

-- 6.3 Políticas: professores
CREATE POLICY "professores_select_all" ON public.professores
    FOR SELECT USING (true);
CREATE POLICY "professores_all_admin_gestor" ON public.professores
    FOR ALL USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));

-- 6.4 Políticas: alunos
CREATE POLICY "alunos_select_all_autenticado" ON public.alunos
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "alunos_insert_all_autenticado" ON public.alunos
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "alunos_update_admin_gestor_recepcao" ON public.alunos
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor', 'recepcao')
    ));

-- 6.5 Políticas: turmas
CREATE POLICY "turmas_select_all" ON public.turmas
    FOR SELECT USING (true);
CREATE POLICY "turmas_all_admin_gestor" ON public.turmas
    FOR ALL USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));

-- 6.6 Políticas: matriculas
CREATE POLICY "matriculas_select_professor" ON public.matriculas
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p
        JOIN public.professores pr ON pr.perfil_id = p.id
        JOIN public.turmas t ON t.professor_id = pr.id
        WHERE p.id = auth.uid() AND t.id = matriculas.turma_id
    ));
CREATE POLICY "matriculas_select_admin_gestor_recepcao" ON public.matriculas
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor', 'recepcao')
    ));
CREATE POLICY "matriculas_insert_admin_gestor_recepcao" ON public.matriculas
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor', 'recepcao')
    ));
CREATE POLICY "matriculas_update_admin_gestor_recepcao" ON public.matriculas
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor', 'recepcao')
    ));

-- 6.7 Políticas: presenca
CREATE POLICY "presenca_select_professor" ON public.presenca
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p
        JOIN public.professores pr ON pr.perfil_id = p.id
        JOIN public.turmas t ON t.professor_id = pr.id
        JOIN public.matriculas m ON m.turma_id = t.id
        WHERE p.id = auth.uid() AND m.id = presenca.matricula_id
    ));
CREATE POLICY "presenca_select_admin_gestor" ON public.presenca
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));
CREATE POLICY "presenca_insert_professor" ON public.presenca
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.perfis p
        JOIN public.professores pr ON pr.perfil_id = p.id
        JOIN public.turmas t ON t.professor_id = pr.id
        JOIN public.matriculas m ON m.turma_id = t.id
        WHERE p.id = auth.uid() AND m.id = presenca.matricula_id
    ));
CREATE POLICY "presenca_insert_admin_gestor" ON public.presenca
    FOR INSERT WITH CHECK (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));
CREATE POLICY "presenca_update_professor" ON public.presenca
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.perfis p
        JOIN public.professores pr ON pr.perfil_id = p.id
        JOIN public.turmas t ON t.professor_id = pr.id
        JOIN public.matriculas m ON m.turma_id = t.id
        WHERE p.id = auth.uid() AND m.id = presenca.matricula_id
    ));
CREATE POLICY "presenca_update_admin_gestor" ON public.presenca
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));

-- 6.8 Políticas: configuracoes
CREATE POLICY "configuracoes_select_all" ON public.configuracoes
    FOR SELECT USING (true);
CREATE POLICY "configuracoes_all_admin" ON public.configuracoes
    FOR ALL USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role = 'admin'
    ));

-- 6.9 Políticas: alertas_faltas
CREATE POLICY "alertas_select_admin_gestor" ON public.alertas_faltas
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role IN ('admin', 'gestor')
    ));
CREATE POLICY "alertas_select_professor" ON public.alertas_faltas
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p
        JOIN public.professores pr ON pr.perfil_id = p.id
        WHERE p.id = auth.uid() AND alertas_faltas.turma_id IN (
            SELECT t.id FROM public.turmas t WHERE t.professor_id = pr.id
        )
    ));
CREATE POLICY "alertas_update_visualizado" ON public.alertas_faltas
    FOR UPDATE USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid()
    ));

-- 6.10 Políticas: auditoria
CREATE POLICY "auditoria_select_admin" ON public.auditoria
    FOR SELECT USING (EXISTS (
        SELECT 1 FROM public.perfis p WHERE p.id = auth.uid() AND p.role = 'admin'
    ));

-- ------------------------------------------------------------
-- 7. STORAGE BUCKETS
-- ------------------------------------------------------------

-- Criar bucket para atestados médicos (executar via Storage API ou Dashboard)
-- Nota: buckets não podem ser criados via SQL puro no Supabase.
-- Instrução manual: vá em Storage > New Bucket > nome: "atestados" > Private > Create
-- Depois aplique a política abaixo via SQL ou Dashboard:

-- Política de acesso ao bucket 'atestados' (executar após criar o bucket)
-- CREATE POLICY "Atestados: usuários autenticados podem fazer upload"
-- ON storage.objects FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'atestados');

-- CREATE POLICY "Atestados: dono pode ler"
-- ON storage.objects FOR SELECT
-- TO authenticated
-- USING (bucket_id = 'atestados');

-- ------------------------------------------------------------
-- 8. SEEDS (DADOS INICIAIS)
-- ------------------------------------------------------------

-- Configurações
INSERT INTO public.configuracoes (chave, valor, descricao)
VALUES
    ('alerta_faltas_consecutivas', '3', 'Número de faltas consecutivas para disparar alerta'),
    ('dias_lista_espera_expiracao', '30', 'Dias máximos na lista de espera antes de cancelamento automático'),
    ('nome_sistema', 'Polo CSU - Gestão Esportiva', 'Nome exibido no cabeçalho do sistema')
ON CONFLICT (chave) DO NOTHING;

-- Modalidades
INSERT INTO public.modalidades (nome, descricao, exige_atestado, ativa)
VALUES
    ('Natação', 'Aulas de natação para todas as idades', true, true),
    ('Hidroginástica', 'Atividades aquáticas de baixo impacto', true, true),
    ('Futebol', 'Treinos de futebol de campo e society', false, true),
    ('Vôlei', 'Treinos de vôlei indoor e de praia', false, true),
    ('Basquete', 'Treinos de basquete em quadra coberta', false, true),
    ('Ginástica', 'Aulas de ginástica geral e alongamento', false, true),
    ('Judô', 'Aulas de judô para crianças e adultos', false, true),
    ('Capoeira', 'Aulas de capoeira e música', false, true)
ON CONFLICT (nome) DO NOTHING;

-- ------------------------------------------------------------
-- 9. VIEWS ÚTEIS
-- ------------------------------------------------------------

-- View: resumo de turmas com ocupação
CREATE OR REPLACE VIEW public.vw_turmas_resumo AS
SELECT
    t.id,
    t.nome,
    t.horario,
    t.dias_semana,
    t.vagas_total,
    t.vagas_disponiveis,
    t.vagas_total - t.vagas_disponiveis AS vagas_preenchidas,
    m.nome AS modalidade,
    p.nome AS professor,
    t.ativa,
    t.idade_min,
    t.idade_max
FROM public.turmas t
LEFT JOIN public.modalidades m ON m.id = t.modalidade_id
LEFT JOIN public.professores pr ON pr.id = t.professor_id
LEFT JOIN public.perfis p ON p.id = pr.perfil_id;

-- View: frequência diária por turma
CREATE OR REPLACE VIEW public.vw_frequencia_diaria AS
SELECT
    t.id AS turma_id,
    t.nome AS turma_nome,
    m.nome AS modalidade,
    pre.data_aula,
    COUNT(*) FILTER (WHERE pre.presente = true) AS presentes,
    COUNT(*) FILTER (WHERE pre.presente = false) AS faltas,
    COUNT(*) AS total_registros
FROM public.turmas t
JOIN public.modalidades m ON m.id = t.modalidade_id
LEFT JOIN public.matriculas mat ON mat.turma_id = t.id AND mat.status = 'ativa'
LEFT JOIN public.presenca pre ON pre.matricula_id = mat.id
GROUP BY t.id, t.nome, m.nome, pre.data_aula;

-- View: alertas de faltas com dados do aluno
CREATE OR REPLACE VIEW public.vw_alertas_faltas AS
SELECT
    af.id,
    af.matricula_id,
    a.nome AS aluno_nome,
    a.telefone AS aluno_telefone,
    t.nome AS turma_nome,
    m.nome AS modalidade,
    af.quantidade_faltas,
    af.data_ultima_falta,
    af.visualizado,
    af.created_at
FROM public.alertas_faltas af
JOIN public.alunos a ON a.id = af.aluno_id
JOIN public.turmas t ON t.id = af.turma_id
JOIN public.modalidades m ON m.id = t.modalidade_id;

-- ------------------------------------------------------------
-- 10. COMENTÁRIOS FINAIS
-- ------------------------------------------------------------

-- Após executar este script:
-- 1. Crie o bucket "atestados" no Storage do Supabase (Private).
-- 2. Configure as políticas de Storage manualmente ou via Dashboard.
-- 3. Crie um usuário admin inicial via Auth > Users > Add User.
-- 4. O trigger tr_auth_criar_perfil criará automaticamente o perfil vinculado.
-- 5. Ajuste a role do perfil para 'admin' diretamente na tabela perfis se necessário.

-- ============================================================
-- FIM DO SCHEMA
-- ============================================================
