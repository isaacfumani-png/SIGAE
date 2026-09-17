---
name: SIGAE Polo CSU
colors:
  surface: '#fff8f6'
  surface-dim: '#e3d8d4'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fdf1ed'
  surface-container: '#f7ebe7'
  surface-container-high: '#f1e6e2'
  surface-container-highest: '#ece0dc'
  on-surface: '#201a18'
  on-surface-variant: '#464650'
  inverse-surface: '#352f2d'
  inverse-on-surface: '#faeeea'
  outline: '#777682'
  outline-variant: '#c7c5d2'
  surface-tint: '#54579f'
  primary: '#02004c'
  on-primary: '#ffffff'
  primary-container: '#191b62'
  on-primary-container: '#8286d1'
  inverse-primary: '#c0c1ff'
  secondary: '#ad295a'
  on-secondary: '#ffffff'
  secondary-container: '#fd6796'
  on-secondary-container: '#6a002f'
  tertiary: '#0e1204'
  on-tertiary: '#ffffff'
  tertiary-container: '#232715'
  on-tertiary-container: '#8a8f77'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#0e0e59'
  on-primary-fixed-variant: '#3c3f85'
  secondary-fixed: '#ffd9e0'
  secondary-fixed-dim: '#ffb1c3'
  on-secondary-fixed: '#3f0019'
  on-secondary-fixed-variant: '#8d0942'
  tertiary-fixed: '#e0e5ca'
  tertiary-fixed-dim: '#c4c9af'
  on-tertiary-fixed: '#191d0c'
  on-tertiary-fixed-variant: '#444935'
  background: '#fff8f6'
  on-background: '#201a18'
  surface-variant: '#ece0dc'
typography:
  display-lg:
    fontFamily: Poppins
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Poppins
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-lg:
    fontFamily: Poppins
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Poppins
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Poppins
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Open Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Open Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Open Sans
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Open Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Open Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
  label-sm:
    fontFamily: Open Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
  data-tabular:
    fontFamily: Open Sans
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  sidebar-width: 16rem
  sidebar-collapsed: 4.5rem
  header-height: 4rem
  gutter-xs: 0.25rem
  gutter-sm: 0.5rem
  gutter-md: 1rem
  gutter-lg: 1.5rem
  gutter-xl: 2rem
  margin-screen: 1.5rem
---

## Brand & Style
The design system establishes a balance between institutional reliability and active athletic operational clarity. Built for the sports and leisure administrative management of municipal and community centers (CSU), the interface balances civic credibility with dynamic operational velocity.

The style follows **Corporate / Modern Minimalist** principles adapted for high-density administrative workflows:
- Structured layout with zero visual clutter or gratuitous decoration.
- Clear structural hierarchy conveying order, authority, and public service accountability.
- High functional clarity: fast data entry, instant scanning of class occupancy, participant attendance records, and resource schedules.
- Professional tone without emojis, relying entirely on clean, standardized iconography (Material Symbols / Phosphor style) and rigorous typographic distinction.

## Colors
The palette leverages high-contrast functional color assignments rooted in civic duty and energetic operational signals:

- **Primary (`#191B62` - Navy Profundo):** Anchors the institutional framework. Applied to the persistent vertical sidebar navigation, primary structural headers, high-level metric summaries, and authoritative text headings.
- **Secondary / Action Accent (`#B32E5E` - Magenta Berry Vibrante):** Dedicated exclusively to primary calls-to-action (e.g., "Nova Matrícula", "Registrar Frequência", "Confirmar Turma"), active states, badges requiring urgent administrative attention, and dynamic progress indicators.
- **Tertiary / Earth Neutral (`#646953` - Verde Oliva Acinzentado):** Utilized for secondary categorizations, sports modality filters, passive status indicators (e.g., "Turma Concluída", "Equipamento Devolvido"), and supportive badges.
- **Surface Background (`#F9ECE5` - Off-white Creme Suave):** Replaces harsh standard white canvases with a warm, low-fatigue backdrop across deep data tables and long management sessions.
- **Support Neutral & Border (`#D7CCC8` - Bege Acinzentado Claro):** Defines subtle structural grid lines, data table row dividers, card borders, and input field boundaries.
- **Operational Data Tones:** Pure white (`#FFFFFF`) is reserved strictly for interactive elevation surfaces (cards, modal panels, table wrappers) to maintain contrast against the `#F9ECE5` app background.

## Typography
Typographic discipline pairs the clear, geometric personality of **Poppins** for page titles and summary stat values with the functional legibility of **Open Sans** for administrative data, lists, forms, and tables.

- Headings use tight letter spacing to project modern administrative authority.
- All numbers within tables, metrics, occupancy percentages, and CPF/ID fields must use `font-variant-numeric: tabular-nums` to ensure vertical column alignment across rows.
- Data labels (e.g., status badges, table headers, breadcrumbs) use uppercase styling via `label-sm` with slight positive tracking for scannability.

## Layout & Spacing
The layout follows a high-density, fixed-sidebar desktop management pattern built on an 8px modular baseline (0.5rem increments):

- **Sidebar (Persistent Left):** Fixed width of `16rem` (256px) on desktop, collapsing to `4.5rem` (72px) icon-only mode when toggled or on small laptops (1024px-1280px).
- **Global Header (Top Sticky):** Height of `4rem` (64px). Houses global contextual search, CSU unit switcher, quick status notifications, and user role credential chip.
- **Content Canvas:** Fluid grid contained within standard padding of `1.5rem` (24px).
  - Primary metric grid: 4-column layout on standard desktop (1280px+), adapting to 2 columns on compact displays (768px-1024px).
  - Core views: 12-column grid splitting operational tables (8 columns) alongside secondary quick-entry sidebars or scheduled events (4 columns).
- Data density maintains compact padding: standard table cells use 10px vertical and 16px horizontal spacing to maximize visible rows per screen.

## Elevation & Depth
This design system relies on **Low-Contrast Outlines paired with Tonal Surface Separation** rather than heavy drop shadows:

- **Base Layer:** The overarching window surface sits at `#F9ECE5`.
- **Card and Data Surfaces:** Raised to pure `#FFFFFF` bounded by a 1px solid `#D7CCC8` border.
- **Shadow Tokens:**
  - Ambient base: `0 1px 2px 0 rgba(25, 27, 98, 0.04)`
  - Hover / Interactive: `0 4px 12px 0 rgba(25, 27, 98, 0.08)`
  - Floating Modals & Flyouts: `0 12px 24px -4px rgba(25, 27, 98, 0.12), 0 0 0 1px #D7CCC8`
- The dark primary sidebar (`#191B62`) stands as an anchor with zero elevation blur, using a clean border-right of `#282A75` to demarcate the administrative shell from the workspace.

## Shapes
A conservative, structural roundedness level (`1` - Soft) is enforced:

- Form fields, action buttons, table wrappers, and dashboard cards maintain a crisp `0.25rem` (4px) to `0.375rem` (6px) corner radius.
- System status pills, category badges, and user avatars utilize standard circular/pill radiuses (`9999px`) to create clear differentiation between actionable containers and status markers.
- Table headers and column dividers retain sharp, architectural borders to maintain structured tabular integrity.

## Components

### Buttons
- **Primary:** Background `#B32E5E`, text `#FFFFFF`, font Poppins SemiBold. Hover: `#9B2450`. Focus: 2px offset outline `#B32E5E`.
- **Secondary / Institutional:** Background `#191B62`, text `#FFFFFF`. Hover: `#282A75`. Focus: 2px offset outline `#191B62`.
- **Ghost / Neutral:** Background transparent, border 1px solid `#D7CCC8`, text `#191B62`. Hover: `#F9ECE5`.
- **Destructive:** Background `#FFF0F0`, border 1px solid `#FFC1C1`, text `#C5221F`.

### Inputs & Filters
- Background `#FFFFFF`, border 1px solid `#D7CCC8`, border-radius 4px, height 38px, font Open Sans 14px.
- Focus state: border color `#191B62` with a subtle box-shadow ring: `0 0 0 2px rgba(25, 27, 98, 0.12)`.
- Label placed above the field in `label-sm` style with `#646953`.

### Data Tables
- Header: background `#FFFFFF`, bottom border 2px solid `#191B62`, text `#646953` uppercase `label-sm`.
- Rows: background `#FFFFFF`, alternating hover state `#FAF3F0`, bottom border 1px solid `#D7CCC8`.
- Action cell: aligned right with inline icon-buttons (edit, attendance checklist, view dossier).

### Chips & Status Badges
- **Vagas Esgotadas / Lotado:** Background `#FDE8E8`, text `#9B1C1C`.
- **Matrículas Abertas / Vagas:** Background `#EDF7ED`, text `#1E4620`.
- **Frequência Regular:** Background `#EBF5FF`, text `#1E429F`.
- **Em Espera / Análise:** Background `#FEF3C7`, text `#92400E`.
- Modality Chips (Futebol, Natação, Ginástica): background `#FFFFFF`, border 1px solid `#D7CCC8`, text `#191B62`, icon-prefix.

### Metric KPI Cards
- White background container with 1px solid border `#D7CCC8`.
- Upper label: `label-sm` `#646953`.
- Central number: `display-lg` `#191B62` in Poppins.
- Footer indicator: micro progress bar or occupancy badge in `#B32E5E` or `#646953`.