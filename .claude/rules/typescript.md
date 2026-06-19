---
applyTo: "frontend/src/**/*.{ts,tsx}"
---

# TypeScript / React Rules

## TypeScript
- Strict mode enabled — no `any`, use `unknown` when type is genuinely unknown
- Prefer `interface` for object shapes, `type` for unions and primitives
- All API response types must match the OpenAPI spec — generate from spec if possible

## React
- Functional components only — no class components
- Custom hooks prefixed with `use`: `useUserData`, `useAuth`
- Co-locate component tests: `MyComponent.tsx` → `MyComponent.test.tsx`
- No business logic in components — extract to hooks or services

## Data Fetching
- React Query (`useQuery`, `useMutation`) for all server state — no raw `useEffect` for fetching
- Handle loading, error, and empty states explicitly in every data-fetching component
- API functions in `/services/` — never inline fetch/axios calls in components

## Forms
- React Hook Form + Zod for all forms
- Zod schemas defined in `/types/` and shared between frontend validation and TS types

## Styling
- Tailwind CSS only — no inline styles, no CSS-in-JS
- Responsive by default — mobile-first breakpoints

## Forbidden
- `any` type
- Direct DOM manipulation
- `console.log` in committed code — use structured error reporting
- `useEffect` for data fetching — use React Query
