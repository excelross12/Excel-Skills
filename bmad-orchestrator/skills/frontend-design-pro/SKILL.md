---
name: frontend-design-pro
description: Production-grade frontend design + build skill. Consolidates ui-ux-pro-max + frontend-design with the BMAD UI/UX phase. Use for any UI work — components, pages, design systems, accessibility. Auto-activates when ui-ux-designer agent hands off a design doc.
---

# Frontend Design Pro

> Consolidates: `ui-ux-pro-max` + `frontend-design`. Wraps both with the BMAD UI/UX phase gate.

## Activation

- After `ui-ux-designer` agent produces `docs/design/<screen>.md`
- On any request mentioning UI, component, page, layout, design system, accessibility, responsive
- On `/design <screen>` command

## Step 0 — Stack Detection (always first)

Before writing a single line of code, identify the framework:

```
DETECT_STACK():
  - package.json present?
    - "next" → STACK = "next"
    - "nuxt" → STACK = "nuxt"
    - "svelte" OR "@sveltejs/kit" → STACK = "svelte"
    - "astro" → STACK = "astro"
    - "react" only (no next/nuxt) → STACK = "react-vite"
    - "vue" only → STACK = "vue-vite"
  - No package.json → ask user ONE question: "Which framework?"
  Load the matching profile below before building.
```

## Framework Profiles

### Next.js (STACK = "next")
- App Router + RSC default; `"use client"` only when interactive state/events required
- Styling: Tailwind v4 + CSS variables for tokens
- Components: shadcn/ui as base; never raw HTML buttons
- State: server state via React Query or RSC fetch; client state via Zustand
- Forms: react-hook-form + zod; server actions for mutations
- Animation: Framer Motion; always wrap in `useReducedMotion()` guard

### Vue 3 / Nuxt (STACK = "nuxt" | "vue-vite")
- Composition API only (no Options API)
- `<script setup>` single-file components
- Pinia for state; VeeValidate + zod for forms
- Tailwind v3 + CSS variables; Headless UI for accessible primitives
- Animation: `<Transition>` + GSAP; respect `prefers-reduced-motion`

### SvelteKit / Svelte 5 (STACK = "svelte")
- Runes API (`$state`, `$derived`, `$effect`) for Svelte 5
- File-based routing; form actions for mutations
- Tailwind v4 + CSS variables; bits-ui or Melt UI for accessible primitives
- Animation: svelte/transition with `reduced_motion` media query guard

### Astro (STACK = "astro")
- Islands architecture: static by default; `.client:*` directives only when needed
- Choose UI framework (React / Vue / Svelte) per island — do not mix
- Content Collections for typed Markdown/MDX
- Tailwind v4; zero-JS preference

### React + Vite (STACK = "react-vite")
- Functional components only; hooks everywhere
- TanStack Query for server state; Zustand for client state
- Radix UI / shadcn for accessible primitives
- Framer Motion + `useReducedMotion()` guard

---

## Core Workflow

```
1. DETECT stack (Step 0)
2. LOAD design doc (if not found → invoke ui-ux-designer first)
3. EXTRACT design tokens (colors, spacing, type, shadows, radii) → tokens.css / tailwind.config
4. CHECK existing system — reuse before creating
5. SCAFFOLD component tree: atoms → molecules → organisms → templates → pages
6. BUILD with all 5 states per component (see State Matrix below)
7. APPLY error boundary at page/route level
8. VALIDATE accessibility (WCAG AA, ARIA, keyboard, contrast, reduced-motion)
9. VALIDATE Core Web Vitals targets
10. RESPONSIVE check (mobile-first: 375px, 768px, 1280px, 1440px+)
11. HAND OFF to test-engineer for E2E + visual regression
```

---

## Design Token Convention

```css
/* tokens.css — single source of truth for ALL visual values */
:root {
  /* Brand palette */
  --color-brand-50:  #f0f9ff;
  --color-brand-500: #0ea5e9;
  --color-brand-900: #0c4a6e;

  /* Semantic aliases */
  --color-bg:          var(--color-brand-50);
  --color-bg-surface:  #ffffff;
  --color-text:        #0f172a;
  --color-text-muted:  #64748b;
  --color-border:      #e2e8f0;
  --color-accent:      var(--color-brand-500);

  /* Spacing scale (8px base) */
  --space-1: 0.25rem;   /* 4px */
  --space-2: 0.5rem;    /* 8px */
  --space-3: 0.75rem;   /* 12px */
  --space-4: 1rem;      /* 16px */
  --space-6: 1.5rem;    /* 24px */
  --space-8: 2rem;      /* 32px */
  --space-12: 3rem;
  --space-16: 4rem;

  /* Type scale (1.25 ratio) */
  --text-xs:   0.64rem;
  --text-sm:   0.8rem;
  --text-base: 1rem;
  --text-lg:   1.25rem;
  --text-xl:   1.563rem;
  --text-2xl:  1.953rem;
  --text-3xl:  2.441rem;

  /* Fluid headings — clamp(min, preferred, max) */
  --text-h1: clamp(1.953rem, 4vw + 1rem, 3.052rem);
  --text-h2: clamp(1.563rem, 3vw + 0.75rem, 2.441rem);

  /* Radius */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 1rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);

  /* Animation */
  --duration-fast:   150ms;
  --duration-base:   250ms;
  --duration-slow:   400ms;
  --ease-out:        cubic-bezier(0, 0, 0.2, 1);
}

/* Dark mode token overrides */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg:          #0f172a;
    --color-bg-surface:  #1e293b;
    --color-text:        #f1f5f9;
    --color-text-muted:  #94a3b8;
    --color-border:      #334155;
  }
}

/* Class-based dark mode toggle (for user preference override) */
.dark {
  --color-bg:          #0f172a;
  --color-bg-surface:  #1e293b;
  --color-text:        #f1f5f9;
  --color-text-muted:  #94a3b8;
  --color-border:      #334155;
}
```

Never hardcode hex/px/rgb in components. Always use tokens.

---

## Component Skeleton (React / Next.js)

```tsx
// components/Card.tsx
"use client"; // only if this component uses hooks/events

import { cn } from "@/lib/utils";
import type { ComponentProps } from "react";

interface CardProps extends ComponentProps<"article"> {
  variant?: "default" | "elevated" | "outline";
  loading?: boolean;
  empty?: boolean;
  error?: string | null;
}

export function Card({
  variant = "default",
  loading,
  empty,
  error,
  className,
  children,
  ...props
}: CardProps) {
  if (loading) return <CardSkeleton />;
  if (error)   return <CardError message={error} />;
  if (empty)   return <CardEmpty />;

  return (
    <article
      className={cn(
        "rounded-md bg-[var(--color-bg-surface)] p-4",
        variant === "elevated" && "shadow-[var(--shadow-md)]",
        variant === "outline" && "border border-[var(--color-border)]",
        className
      )}
      {...props}
    >
      {children}
    </article>
  );
}

function CardSkeleton() {
  return (
    <div
      className="h-32 animate-pulse rounded-md bg-[var(--color-border)]"
      aria-hidden="true"
      role="presentation"
    />
  );
}

function CardError({ message }: { message: string }) {
  return (
    <div role="alert" className="rounded-md border border-red-300 bg-red-50 p-4 text-red-700">
      <p className="text-sm">{message}</p>
    </div>
  );
}

function CardEmpty() {
  return (
    <div className="flex flex-col items-center gap-2 py-8 text-[var(--color-text-muted)]">
      <span aria-hidden="true">—</span>
      <p className="text-sm">Nothing here yet.</p>
    </div>
  );
}
```

---

## State Matrix

Every data-displaying component MUST implement all 5 states:

| State | Trigger | Implementation |
|---|---|---|
| **default** | Normal data present | Render content |
| **loading** | Data in-flight | Shape-of-content skeleton (not spinner for lists) |
| **empty** | Zero results | Helpful empty state with CTA if applicable |
| **error** | Fetch/mutation failed | `role="alert"`, human error message, retry option |
| **success** | Mutation complete | Transient toast or inline confirmation, then default |

Loading rule: use a spinner ONLY for full-page navigations. Use shape-of-content skeletons for components.

---

## Error Boundaries (required at every route/page)

```tsx
// app/error.tsx  (Next.js App Router)
"use client";

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-8">
      <h1 className="text-[var(--text-xl)] font-semibold">Something went wrong</h1>
      <p className="text-[var(--color-text-muted)] text-sm max-w-md text-center">
        {error.message || "An unexpected error occurred. Our team has been notified."}
      </p>
      <button
        onClick={reset}
        className="rounded-md bg-[var(--color-accent)] px-4 py-2 text-white"
      >
        Try again
      </button>
    </main>
  );
}
```

Every Next.js route segment needs `error.tsx` + `loading.tsx`. Every React page tree needs a `<ErrorBoundary>` wrapper.

---

## Animation — Reduced Motion (mandatory)

```tsx
// Always guard animations behind reduced-motion preference
import { useReducedMotion } from "framer-motion";

export function AnimatedCard({ children }: { children: React.ReactNode }) {
  const shouldReduce = useReducedMotion();

  return (
    <motion.div
      initial={shouldReduce ? false : { opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={shouldReduce ? { duration: 0 } : { duration: 0.25 }}
    >
      {children}
    </motion.div>
  );
}
```

CSS equivalent:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Core Web Vitals Targets

| Metric | Target | Technique |
|---|---|---|
| **LCP** | < 2.5s | Preload hero image; `priority` on `next/image`; avoid layout shift above fold |
| **INP** | < 200ms | Defer non-critical JS; avoid long tasks; use `startTransition` for heavy state |
| **CLS** | < 0.1 | `aspect-ratio` on images/video; `min-height` on skeleton containers; avoid injecting content above fold |
| **FID/TBT** | < 200ms | Code-split; lazy-load below-fold routes; no synchronous localStorage in render |
| **TTFB** | < 600ms | CDN; RSC streaming; proper cache headers |

Performance budget: JS bundle ≤ 200 KB (gzipped) for initial route. Measure with `next build` output or `npx bundlephobia`.

Font strategy:
```tsx
// app/layout.tsx
import { Inter } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",           // FOIT prevention
  preload: true,
  variable: "--font-sans",
});
```

Image strategy:
```tsx
// Always: width + height (or fill + sizes) to prevent CLS
<Image
  src="/hero.webp"
  alt="Descriptive alt text"
  width={800}
  height={400}
  priority                   // above-fold images only
  sizes="(max-width: 768px) 100vw, 800px"
/>
```

---

## Accessibility Checklist

- [ ] `aria-label` on every interactive element without visible text
- [ ] `role="alert"` on all error messages
- [ ] `aria-live="polite"` on dynamically updated regions (not errors)
- [ ] `aria-busy="true"` on loading containers
- [ ] Keyboard navigation: all interactive elements reachable via Tab; logical DOM order
- [ ] Focus visible: `:focus-visible` outline (never `outline: none` without custom ring)
- [ ] Color contrast: ≥ 4.5:1 body text; ≥ 3:1 large text (18px+) and icons
- [ ] Touch targets: ≥ 44×44px on mobile (use `min-h-[44px] min-w-[44px]`)
- [ ] No `dangerouslySetInnerHTML` from user data without DOMPurify sanitizer
- [ ] `prefers-reduced-motion` respected for ALL animations
- [ ] `prefers-color-scheme` handled via CSS tokens OR class toggle

---

## Form UX Patterns

```tsx
// Validation timing: validate on blur, not on every keystroke
const form = useForm({
  mode: "onBlur",           // field-level on blur
  reValidateMode: "onChange" // re-validate on change after first submit
});

// Inline field error (not toast)
{errors.email && (
  <p role="alert" className="mt-1 text-sm text-red-600">
    {errors.email.message}
  </p>
)}

// Loading state during submit
<button type="submit" disabled={isSubmitting} aria-busy={isSubmitting}>
  {isSubmitting ? "Saving…" : "Save"}
</button>
```

Multi-step forms: use a state machine (XState or simple enum); persist step progress to `sessionStorage` to survive accidental back-navigation.

---

## Hard Rules

- All 5 states (default, loading, empty, error, success) — no exceptions
- Error boundary at every route level (Next: `error.tsx`; React: `<ErrorBoundary>`)
- `useReducedMotion()` guard on ALL Framer Motion usage
- `prefers-color-scheme` + class-based dark toggle via CSS token overrides
- No fixed pixel widths — use rem, %, fluid clamp(), or grid/flex
- No `dangerouslySetInnerHTML` from user data without DOMPurify
- Core Web Vitals targets met before marking story done
- `aria-label` on every icon-only interactive element
- Font: `font-display: swap` always

## References

- `.claude/skills/ui-ux-pro-max/` — design taste reference
- `.claude/skills/frontend-design/` — pattern catalog
