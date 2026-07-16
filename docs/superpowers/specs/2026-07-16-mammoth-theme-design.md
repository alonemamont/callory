# Mammoth theme reskin (dark, amber accent)

Source: brand guide "Мамонт" (personal dev brand, imported via claude_design). Visual language only — Callory name/logo unchanged.

## Colors (hex)
- graphiteDark `#13161A` — scaffold/bg
- graphite `#212428` — surface/cards
- graphiteLight `#3E4348` — borders/dividers
- ivory `#EBE8DF` — text on dark
- amberLamp `#D58042` — accent (buttons/active/links)
- lampGlow `#A65C20` — pressed/secondary accent, glow
- error `#E5484D` — not in brand guide, added for Material error slot

## Type
JetBrains Mono only, weights 400/500/600/700/800. Bundle as local ttf assets under `assets/fonts/` (offline-first app, no google_fonts). Scale: hero 40/700, title 20-28/700, body 15/400, label 11-13/600 uppercase +1-3px tracking.

## Spacing/radius
Base unit 8 (4/8/12/16/24/32/40). Radius: 4 small (chips/inputs), 6 medium (cards), 22 large (icon tiles).

## Signature
Radial amber glow (from brand hero) reused behind DayScreen calorie ring/hero number.

## Components
- Dark-only theme, `ThemeMode.dark`
- AppBar: graphite bg, ivory text, flat, hairline bottom border
- Card: graphite surface, 6px radius, 1px graphiteLight border, no shadow
- Bottom NavigationBar: graphiteDark bg, amberLamp selected, dim ivory unselected
- Buttons: amberLamp bg, graphiteDark text
- TextField: graphite fill, graphiteLight border, amberLamp on focus
- Divider: graphiteLight hairline

## Scope
New files: `lib/ui/theme/app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `theme.dart`. Wire into `MaterialApp` in `lib/main.dart:28`. No per-screen rewrites — Material widgets inherit theme. Add 5 JetBrains Mono ttf files + `pubspec.yaml` font registration.

## Out of scope
Light theme, mammoth logo/name, per-screen custom widgets beyond theme inheritance.
