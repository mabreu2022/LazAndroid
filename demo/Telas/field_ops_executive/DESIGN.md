---
name: Field Ops Executive
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#42474f'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#727780'
  outline-variant: '#c2c7d1'
  surface-tint: '#2d6197'
  primary: '#00355f'
  on-primary: '#ffffff'
  primary-container: '#0f4c81'
  on-primary-container: '#8ebdf9'
  inverse-primary: '#a0c9ff'
  secondary: '#006c4a'
  on-secondary: '#ffffff'
  secondary-container: '#82f5c1'
  on-secondary-container: '#00714e'
  tertiary: '#522900'
  on-tertiary: '#ffffff'
  tertiary-container: '#733c00'
  on-tertiary-container: '#ffa658'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#a0c9ff'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#07497d'
  secondary-fixed: '#85f8c4'
  secondary-fixed-dim: '#68dba9'
  on-secondary-fixed: '#002114'
  on-secondary-fixed-variant: '#005137'
  tertiary-fixed: '#ffdcc3'
  tertiary-fixed-dim: '#ffb77d'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6e3900'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
  numeric-table:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-compact: 0.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
---

## Brand & Style
The design system delivers a high-velocity, mission-critical mobile experience engineered for field sales representatives and commercial agents. It blends Modern Corporate precision with high-contrast tactical utility. The interface communicates authority, operational efficiency, and rock-solid reliability. 

Every surface is calibrated for harsh field environments: bright daylight readability, single-handed operation while standing in client warehouses, and rapid thumb-driven data entry. The emotional tone avoids decorative fluff in favor of dense, legible information architecture, crisp borders, and purposeful visual signifiers for offline resilience and financial performance tracking.

## Colors
The palette balances corporate gravitas with immediate status legibility:

- **Primary (`#0F4C81`)**: Industrial Petrol Navy. Drives global actions, primary buttons, critical navigation, active states, and structural headers.
- **Secondary (`#059669`)**: Emerald Target. Dedicated exclusively to successful transmissions, positive commercial margins, achieved sales goals, and ready-to-bill statuses.
- **Tertiary (`#D97706`)**: Amber Warning. Designates credit blocks, overdue pending approvals, out-of-stock warnings, and synchronization queue backlog alerts.
- **Neutrals**:
  - `Surface Canvas`: `#F8FAFC` (Slate 50) and `#F1F5F9` (Slate 100) provide subtle separation without glare.
  - `Surface Elevated / Cards`: `#FFFFFF`.
  - `Borders & Dividers`: `#CBD5E1` (Slate 300) and `#E2E8F0` (Slate 200) ensuring visible contrast under direct sunlight.
  - `Text Hierarchy`: Primary `#0F172A` (Slate 900) delivers a strict 14:1+ contrast ratio against white cards; secondary text uses `#334155` (Slate 700) to preserve critical details like SKU codes and tax IDs.

## Typography
The system standardizes entirely on **Inter** using tabular numeric figures (`tnum`) for monetary values, inventory units, and order totals. 

- **Display & Headlines**: Tightly kerned with negative letter spacing to maximize information density on mobile screens without sacrificing hierarchy.
- **Labels**: Applied uppercase with positive tracking on small status tags, table headings, and offline indicators.
- **Body & Numerics**: Prioritizes robust weights (400 for structural text, 600 for quantitative order metrics) to resist visual degradation on glare-heavy glass devices.

## Layout & Spacing
A fluid 4-column layout governs mobile viewports (breakpoint `< 600px`), shifting to an 8-column layout on tablets (breakpoint `600px - 1024px`). 

- **Outer Margins**: Compact `1rem` on handheld devices guarantees that customer catalog items and order line items leverage the maximum horizontal viewport area.
- **Field Ergonomics**: Touch targets enforce a minimum physical height of `48px` despite tight visual spacing, achieved through vertical padding and transparent tap target expansion.
- **Split-View Behavior**: On tablet orientations, screens split into a fixed 360px navigation/client master panel and a fluid detail work pane (order composition and catalog matrix).

## Elevation & Depth
Field operations demand immediate spatial separation that does not wash out under bright sunlight. The system bypasses heavy blurry drop shadows in favor of a layered combination of structural borders and crisp, tinted ambient depth:

- **Surface Level 0 (Base)**: `#F8FAFC`. The canvas layer where grouped sections and background screens reside.
- **Surface Level 1 (Cards, Lists, Order Rows)**: `#FFFFFF` with a crisp `1px solid #E2E8F0` border and an ultra-subtle ambient shadow: `0 1px 3px rgba(15, 23, 42, 0.06), 0 1px 2px rgba(15, 23, 42, 0.04)`.
- **Surface Level 2 (Sticky Headers, Sync Bars, Bottom Action Sheets)**: Elevated using `0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.04)` bordered by `#CBD5E1`.
- **Surface Level 3 (Dialogs, Credit Override Modals)**: Backed by a high-contrast dimming scrim (`rgba(15, 23, 42, 0.65)`) with an elevated card shadow: `0 20px 25px -5px rgba(15, 23, 42, 0.15)`.

## Shapes
The visual form uses `roundedness: 2` with consistent radii:
- Standard interactive elements (buttons, inputs, status tags) feature `0.5rem` (8px).
- Structural containers, order cards, and customer profiles use `rounded-xl` (1rem / 16px) to maintain a modern, friendly yet precise demeanor.
- Floating sync badges and status indicators utilize pill-style borders to distinguish dynamic system state markers from actionable cards.

## Components

### Buttons
- **Primary**: Background `#0F4C81`, text `#FFFFFF`, height `48px`, font `label-lg`, `rounded-lg` (8px). Pressed state shifts to `#0A3256`.
- **Secondary / Actionable Border**: Background `#FFFFFF`, border `1.5px solid #0F4C81`, text `#0F4C81`.
- **Destructive / Credit Hold**: Background `#FEF2F2`, border `1px solid #FCA5A5`, text `#B91C1C`.
- **Bottom Fixed Bar**: Primary CTA spans full width with an inline order total summary for quick thumb submission.

### Badges & Sync Status
- **Online / Synced**: Pill badge with `#ECFDF5` background, `#059669` text, `1px solid #A7F3D0`, prepended by a solid green pulse indicator dot (`6px`).
- **Offline / Queued**: Pill badge with `#FFFBEB` background, `#D97706` text, `1px solid #FDE68A`, displaying the count of unpushed transactions (e.g., `3 pedidos pendentes`).
- **Sync Failure**: `#FEF2F2` background, `#DC2626` text, with an inline retry trigger.

### Status Chips
- Height `24px`, padding `0 8px`, typography `label-sm`.
- Status types: *Aprovado* (Emerald), *Em Análise* (Amber), *Bloqueio Comercial* (Red), *Rascunho* (Slate).

### Cards (Customers & Orders)
- Background `#FFFFFF`, border `1px solid #E2E8F0`, border-radius `1rem`. Internal padding `space-md` (`0.75rem` to `1rem`).
- Header displays customer corporate name and trade badge (`CNPJ` / tax ID in `body-sm`, `#334155`).
- Footer embeds inline KPI metrics: credit limit gauge bar, last purchase date, and total order margin percentage.

### Input Fields & Steppers
- Height `48px`, background `#FFFFFF`, border `1.5px solid #CBD5E1`, text `#0F172A`. Active focus state features `#0F4C81` outline with `2px` ring.
- **Quantity Stepper**: Integrated numeric keypad triggers with large tactile decrement (`-`) and increment (`+`) zones (`48x48px`) flanking tabular numerical counts.

### Data Dense Order Matrix List
- Alternating subtle row divisions with `#F1F5F9`.
- Column layout prioritizing Product Description/SKU on the left, unit price and quick-edit quantity right-aligned with fixed tabular alignment.