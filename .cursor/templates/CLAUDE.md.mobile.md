<!--
  MOBILE-READY CLAUDE.md TEMPLATE for Expo + React Native projects.

  HOW TO USE:
  1. When bootstrapping a new mobile project (or onboarding an existing Expo app):
     cp .cursor/templates/CLAUDE.md.mobile.md ./CLAUDE.md
     # Or append the relevant sections to your existing CLAUDE.md.
  2. Fill in the [BRACKETED] values. Delete sections that don't apply.
  3. Commit.

  These guidelines mirror `.cursor/rules/08-design-system.mdc §Mobile track` so
  Claude Code / Cursor generate mobile-correct code from the first interaction,
  without re-discovering conventions each session.
-->

# CLAUDE.md — [PROJECT NAME] (mobile)

## Project Overview

Cross-platform mobile app built with **Expo SDK [52+] + React Native [0.76+] + TypeScript strict**.
Targets: **iOS [16+] + Android [API 26+]**.
Primary audience: [BRIEF — e.g. "daily users 25–45, trust-first, minimal steps"].
Category: [productivity / lifestyle / ecommerce / etc.].

## Tech Stack

- **Framework:** Expo SDK [52+] (React Native [0.76+])
- **Language:** TypeScript strict mode (`"strict": true`, `"noUncheckedIndexedAccess": true`)
- **Navigation:** Expo Router [v4+] (file-system-based routing, type-safe)
- **Styling:** NativeWind v4 (Tailwind for React Native). StyleSheet API only when NativeWind can't express it.
- **Components:** react-native-reusables (RNR) — copy-paste, same mental model as shadcn/ui on web
- **State management:** [Zustand / Jotai / Redux Toolkit]
- **Data fetching:** TanStack Query v5
- **Animations:** React Native Reanimated 3 (never the legacy Animated API)
- **Gestures:** React Native Gesture Handler
- **Safe-area:** react-native-safe-area-context
- **Secure storage:** expo-secure-store (tokens, credentials, PII)
- **Notifications:** [Expo Notifications / OneSignal / Firebase]
- **Build & submit:** EAS Build + EAS Submit

## Coding Conventions

### Language
- TypeScript strict everywhere. No `any`. `unknown` + narrowing when needed.
- `const` and `let` only — never `var`.
- Prefer type inference; annotate only public APIs and exported types.

### Components
- Functional components + hooks. No class components.
- **Named exports only.** Exception: Expo Router's `app/` files (layout + route) that require default exports.
- Co-locate: `src/components/ui/` (RNR copy-paste), `src/components/custom/` (yours), `src/components/shared/` (cross-feature reusables).

### Styling
- **NativeWind className first.** Use Tailwind classes (`className="flex-1 items-center bg-background"`).
- **StyleSheet fallback only** when a specific RN style can't be expressed in NativeWind (rare).
- **No inline styles** (`style={{…}}`) except for dynamic values you can't express as classes.
- Tokens live in `tailwind.config.js` + `global.css` (CSS variables for light/dark). Driven by `memory/14-design-system.md`.

### File & folder naming
- Folders: `kebab-case/`
- React components: `PascalCase.tsx`
- Hooks: `useCamelCase.ts`
- Utilities, types, constants: `kebab-case.ts`
- Expo Router files: stay in `app/`, follow Expo's convention (`_layout.tsx`, `index.tsx`, `[param].tsx`).

### Imports
Order (blank line between groups):
1. React / React Native / Expo primitives
2. Third-party packages
3. Internal absolute imports (`@/…`)
4. Relative imports

Alphabetical within each group. Use `@/` path alias, not `../../../` chains.

## Important Rules (Non-Negotiables)

### Navigation
- **Use Expo Router.** `router.replace('/(auth)/login')`, never `navigation.navigate(...)`.
- Routes are file-based. Grouping via `(tabs)`, `(auth)`, etc.
- All routes type-safe. If TS complains about a route, the route is wrong — don't `@ts-ignore`.

### Platform differences
- **Minimize `Platform.OS` branches.** Prefer shared components that adapt via props or the safe-area context.
- If you have > 2 `Platform.OS === 'ios'` checks in one file, refactor.
- iOS + Android UX differences (e.g. swipe-back gesture on iOS only, system back button on Android) are expressed via Expo Router's native stack, not conditionals.

### Safe-area
- **Every screen wraps in `SafeAreaView`** from `react-native-safe-area-context`.
- No raw top/bottom padding on screens. Let the safe-area context tell you.

### Animations
- **Reanimated 3 only.** `useSharedValue`, `useAnimatedStyle`, worklets.
- Legacy `Animated` API is forbidden in new code.
- Always respect `AccessibilityInfo.isReduceMotionEnabled()` and shorten / skip animations accordingly.

### Storage
- **Sensitive data → `expo-secure-store`** (auth tokens, refresh tokens, PII).
- **Non-sensitive persistent data → AsyncStorage** is fine (onboarding flags, last-visited tab, etc.).
- **Never** commit keys. `.env` via `expo-constants`. `.env.local` is gitignored; `.env.example` documents required vars.

### Accessibility
- Every touchable has `accessibilityLabel`, `accessibilityRole`, `accessibilityHint` (when behavior isn't obvious).
- Touch targets ≥ 44pt iOS / 48dp Android.
- Text color contrast ≥ 4.5:1 (WCAG AA).
- Test with VoiceOver (iOS) and TalkBack (Android) before shipping.

### Packages
- **Prefer `expo-*`** over React Native community packages when Expo ships an equivalent (`expo-image` over `react-native-fast-image`, `expo-secure-store` over `react-native-keychain`, etc.).
- Before adding a new dependency, check if an existing one covers the need.
- Every new dep → document in `memory/03-architecture.md §External Deps` with reason + alternatives considered.

## Orientation & Layout

- **Supported orientations:** [portrait / portrait+landscape].
- All screens handle both [if both] or degrade gracefully [if portrait-only].
- Responsive breakpoints via Tailwind (`sm:`, `md:`) work in NativeWind the same as on web — useful for tablets.

## Testing

- **Unit:** Jest + React Native Testing Library. Focus: business logic + hooks.
- **Integration:** React Native Testing Library with rendered screens.
- **e2e:** Maestro flows (recommended) or Detox. One happy path + 2 error paths per critical journey.
- **Device testing:** before every PR merge — iOS real device + Android real device. Simulators miss > 20% of issues.

## Build & Deploy

- **Dev:** `npx expo start` (Expo Go if no custom native modules; dev client otherwise).
- **Preview builds:** `eas build --profile preview --platform all` → generates shareable URLs via QR.
- **Production:** `eas build --profile production --platform all` + `eas submit`.
- **OTA updates:** EAS Update on channels `preview` → `production`. Never ship a JS-only change that breaks native compatibility.

## Claude Code behavior in this project

Before making changes to this project:

1. Read `memory/00-project-brief.md`, `memory/02-current-state.md`, `memory/07-decisions-log.md`, `memory/14-design-system.md`.
2. For any non-trivial change: produce a plan (no direct implementation).
3. For design changes: honor `memory/14-design-system.md §Mobile-specific` sections (safe-area policy, platform differences, orientation, touch targets).
4. Never bypass the non-negotiables above. If the user asks for something that violates them (e.g. "add a quick Platform.OS check here"), push back with the cost.

## Common pitfalls to avoid

1. **`Platform.OS` proliferation.** If you catch yourself adding a 3rd branch in one file, stop and refactor.
2. **Modal / dialog stacking.** Max 2 deep. If you need 3, the UX is wrong.
3. **Animated API.** Forbidden in new code. Reanimated 3 only.
4. **AsyncStorage for tokens.** Security risk. Use expo-secure-store.
5. **Inline styles.** NativeWind className everywhere possible.
6. **Forgetting SafeAreaView.** Screen looks fine on iPhone 15 Pro simulator, broken on iPhone SE or notched devices.
7. **Native modules + Expo Go.** If you add a custom native module, Expo Go stops working — you need the dev client. Communicate this clearly.
8. **Hardcoded strings.** Use `react-i18next` or similar even if the app is currently single-language; it's 10× cheaper to add i18n upfront than retrofit.

---

_This file derives from `.cursor/rules/08-design-system.mdc §Mobile track` and `.cursor/rules/02-tech-stack.mdc §Mobile-specific`. Keep them in sync: when you refine a rule here, update those files too (or delete the divergence here — the rule files win in conflicts)._
