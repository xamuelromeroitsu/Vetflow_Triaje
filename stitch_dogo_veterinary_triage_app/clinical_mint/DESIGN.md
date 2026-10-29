---
name: Clinical Mint
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3c4a43'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6c7a73'
  outline-variant: '#bbcac1'
  surface-tint: '#006c4f'
  primary: '#006c4f'
  on-primary: '#ffffff'
  primary-container: '#32c798'
  on-primary-container: '#004e38'
  inverse-primary: '#50ddad'
  secondary: '#545f73'
  on-secondary: '#ffffff'
  secondary-container: '#d5e0f8'
  on-secondary-container: '#586377'
  tertiary: '#b91a24'
  on-tertiary: '#ffffff'
  tertiary-container: '#ff928b'
  on-tertiary-container: '#8d0012'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#71fac8'
  primary-fixed-dim: '#50ddad'
  on-primary-fixed: '#002116'
  on-primary-fixed-variant: '#00513b'
  secondary-fixed: '#d8e3fb'
  secondary-fixed-dim: '#bcc7de'
  on-secondary-fixed: '#111c2d'
  on-secondary-fixed-variant: '#3c475a'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930013'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
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
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
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
  vital-metric:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style
The design system establishes a clinical, reassuring, and high-velocity interface tailored for veterinary professionals and anxious pet owners. Balancing the precision of critical care triage with an approachable, calming bedside manner, the design merges clinical minimalism with tactile, high-contrast feedback.

The aesthetic pairs bright, hygienic surfaces with distinct semantic triage accents. Visual clarity and immediate information hierarchy supersede decorative flourishes: every element communicates patient acuity, physiological status, or critical workflow next-steps without ambiguity under stressful operational conditions.

## Colors
The palette is engineered for rapid situational recognition under diverse lighting conditions in clinics and mobile field environments:

- **Primary (`#32C798` / `#38C194`)**: Serves as the primary brand anchor, positive verification state, and key interactive control focus.
- **Secondary / Contrast Dark (`#1E293B` / `#111827`)**: Grounds header bars, primary data points, patient names, and high-emphasis labels.
- **Surface Foundations**: Pure white (`#FFFFFF`) provides primary screen canvas, while light mint/slate (`#F4F9F6`) delivers distinct card containment and recessed surface tiers without heavy border overhead.
- **Semantic Triage Spectrum**:
  - **Emergency Level 1 (`#EF4444`)**: Immediate resuscitation and life threats. Paired with 10% opacity fills (`#FEF2F2`) for critical alert card surfaces.
  - **Urgent Level 2 (`#F59E0B`)**: High priority stabilization and rapid deterioration risks. Paired with warm amber surfaces (`#FFFBEB`).
  - **Standard Level 3 (`#10B981`)**: Stable consultations, routine re-checks, and standard scheduling. Paired with soft emerald surfaces (`#ECFDF5`).
- **Functional Neutrals**: Slate 800 (`#1E293B`) for primary typography, Slate 500 (`#64748B`) for secondary metadata, and Slate 200 (`#E2E8F0`) for structural hairpins and input outlines.

## Typography
This design system utilizes `Inter` across all typography tiers to maximize legibility of dense clinical data, numerical metrics, and rapid-scan triage queues. 

- **Numerical Legibility**: Numerical vitals (BPM, SpO2, Temperature) rely on tabular figures (`font-variant-numeric: tabular-nums`) within the `vital-metric` style to eliminate horizontal layout jitter when monitoring streaming readings.
- **Triage Headers**: Acuity levels, patient identities, and alert statuses utilize semi-bold and bold weights with tighter tracking (`-0.01em` to `-0.02em`) to guarantee quick recognition on mobile canvases.
- **Micro-Labels**: Triage classification tags, species identifiers, and timestamp indicators use `label-sm` or `label-md` with slight letter-spacing expansions to ensure immediate recognition in fast-paced operational workflows.

## Layout & Spacing
A fluid 4-column layout model is enforced on mobile viewports (breakpoint `< 600px`), transitioning to an 8-column layout on tablet viewports (`600px - 1024px`). 

- **Outer Margins**: Outer screen boundaries retain a strict `1rem` margin on mobile to maximize horizontal real estate for patient assessment workflows, stepping up to `1.5rem` on tablet screens.
- **Vertical Rhythm**: Form fields, clinical checklists, and vitals cards align to an `8px` grid cadence. Stacked card groups apply `space-sm` (`0.5rem`) internally and `space-md` (`1rem`) externally between patient items.
- **Safe Tap Bounds**: All interactive controls conform to a minimum physical boundary of `44px × 44px` (or `48px` within acute emergency workflows) regardless of underlying visual label dimensions.

## Elevation & Depth
Depth hierarchy avoids heavy skeuomorphic cast shadows in favor of ambient clinical elevation and tonal separation:

- **Level 0 (Flat/Canvas)**: Pure `#FFFFFF` app canvas or recessed panel fill (`#F4F9F6`) with no elevation.
- **Level 1 (Cards & Queue Items)**: Offset `0px 2px 8px -1px rgba(17, 24, 39, 0.05)`, framed with a crisp `1px` stroke of `#E2E8F0`. Ensures high legibility on varying screen backlights.
- **Level 2 (Active Sheets & Triage Modals)**: Offset `0px 8px 24px -4px rgba(30, 41, 59, 0.12)`, used for triage protocol overlays, quick-intake drawers, and vitals input sheets.
- **Critical Alert Elevation**: Emergency priority items (`#EF4444`) utilize a subtle directional colored shadow: `0px 4px 14px -2px rgba(239, 68, 68, 0.25)` to immediately draw ocular focus in triage queues.

## Shapes
The shape language uses balanced rounded geometry (`roundedness: 2`) to ensure patient cards, triage forms, and data inputs feel clean, approachable, and ergonomic.

- **Standard Cards & Surfaces**: Constructed with `0.75rem` to `1rem` corner radii (`rounded-lg`), softening clinical density.
- **Triage Status Badges & Category Chips**: Fully rounded pill shapes (`9999px` / `rounded-full`) to differentiate metadata tags and triage status indicators from rectangular action controls.
- **Input Containers**: Built with `0.5rem` (`8px`) radii, providing clear geometric boundaries for precision stylus or fingertip entry.

## Components

### Buttons
- **Primary Action**: Solid `#32C798` background, `#FFFFFF` text, `48px` default height, bold typography. Active state darkens to `#28A77E`.
- **Destructive / Emergency Action**: Solid `#EF4444` background with white text for critical override and immediate diversion actions.
- **Secondary Outline**: Transparent background, `1.5px` border in `#1E293B`, slate text.
- **Touch Target**: Strict `44px` minimum hit-box padding applied via pseudo-elements even when button height is compact.

### Triage Severity Status Pills
- **Emergency**: `#FEF2F2` background, `#DC2626` text, `1px` solid `#FCA5A5` border, paired with a pulsing red status dot (`8px`).
- **Urgent**: `#FFFBEB` background, `#D97706` text, `1px` solid `#FCD34D` border.
- **Consultation**: `#ECFDF5` background, `#059669` text, `1px` solid `#A7F3D0` border.
- **Dimensions**: Vertical padding `4px`, horizontal padding `12px`, fully rounded (`9999px`).

### Pet ID Badges
- Compact inline components containing a circular pet avatar (`36px` or `48px`), bold pet name (`label-lg`), species icon/breed metadata (`body-sm` in Slate 500), and an integrated sex/age micro-tag.

### Interactive Category Chips
- Filter and symptom selection tags. Default state: `#FFFFFF` fill, `#E2E8F0` border, `#1E293B` text. Selected state: `#32C798` background, `#FFFFFF` text, and borderless. Touch target padded to `44px` height with `32px` visible height.

### Emergency Alert Banners
- Top-anchored global banner featuring high-contrast `#EF4444` fill, `#FFFFFF` text, flashing warning icon, and immediate triage transfer/call-ahead action trigger. Non-dismissible while critical patient triage is unresolved.

### Vitals Inputs with Warning Thresholds
- Numerical inputs paired with trailing unit labels (e.g., `bpm`, `°C`, `kg`). Includes live threshold validation:
  - Normal range: Default `#E2E8F0` border, shifts to `#32C798` on focus.
  - Critical deviation: Border shifts to `#EF4444`, background shifts to `#FEF2F2`, displaying inline danger micro-copy (`label-sm`).

### Queue Cards
- Elevated Level 1 surface (`#FFFFFF`), `12px` internal padding, containing left-accented triage priority color stripe (`4px` width), Pet ID Badge, elapsed waiting time timer, and assigned intake station.

### Role Switcher Toggles
- Segmented control container with `#F1F5F9` background, `4px` padding, and an animated sliding pill indicating active context (`Owner` vs. `Triage Tech` vs. `Veterinarian`). Active pill features `#FFFFFF` fill with Level 1 elevation.