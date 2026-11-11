# Design

## Context

See `proposal.md` and the four delta specs. The backend is complete and the API already provides same-origin cookie sessions, an `X-CSRF-TOKEN` antiforgery check on unsafe `/api` verbs, ProblemDetails with stable `type` URIs, an `Idempotency-Key` header on financial routes, and a committed OpenAPI document with a generated client (`api-contract/generated/xopti-client.ts`, checked by `scripts/contract-check.sh`). The container topology is fixed: `nginx` serves the SPA and proxies `/api` to `api:8080` on one origin (`docker/nginx.conf`). The `web` service currently mounts a placeholder `docker/web-root`.

Facts from the code that shape this design:

- The sign-in response carries only `username` and `displayName`. Permissions are claims of type `xopti:permission`, so a new read endpoint is required for the shell.
- `GET /api/v1/auth/csrf-token` is excluded from the OpenAPI document, so the generated client does not include it.
- The antiforgery token is bound to the antiforgery cookie. Tokens fetched before sign-in must be refreshed after sign-in and sign-out.
- The session idle timeout defaults to 20 minutes and is enforced by the cookie, not by the client.

## Goals / Non-Goals

**Goals:**
- One shell and one API access path that every later module reuses without copying code.
- Client-side permission gating for usability only; the API remains the authority.
- The WebPivotTable integration is validated, self-hosted, and gated, so it can be enabled once licensed without code changes.
- Build and deployment are reproducible: the same image runs in any environment with different runtime configuration.

**Non-Goals:**
- Module screens beyond sign-in, the shell, and the analytics prototype.
- Analytics endpoints, server-side saved views, and OLAP data shaping.
- Offline support, service workers, or device integration.
- Server-side rendering.

## Decisions

### Decision: Project at `web/xOpti.Web`, npm, Vite, Vue 3 + TypeScript
Matches the solution layout in `MIGRATION_NOTES.md`. npm with a committed lockfile is chosen because `scripts/` already uses `npx`. Vue Router for routes, Pinia for session and UI state, Vuetify 3 with per-component auto-import (`vite-plugin-vuetify`) so unused Vuetify components stay out of the bundle. Vue template compiler options declare `isCustomElement: (tag) => tag === 'web-pivot-table'` so custom elements do not fail compilation or tests. `@mdi/font` is installed as a local npm dependency and bundled statically to guarantee offline, air-gapped on-prem icon rendering with zero external CDN dependencies. Locale is `en-CA`.

### Decision: Consume the committed client types; use a fetch middleware for cross-cutting behavior
The app imports `paths` and `components` from `api-contract/generated/xopti-client.ts` through a path alias, so there is one source of truth and CI already guards it. The runtime uses `openapi-fetch` with middleware for: attaching `X-CSRF-TOKEN` on unsafe verbs, attaching `x-correlation-id`, and converting ProblemDetails into a typed `AppError` keyed by `type`. The CSRF token call uses a small hand-written typed function because the endpoint is excluded from the contract.

Alternative considered: hand-written fetch functions per endpoint. Rejected because the typed paths would be duplicated and drift from the contract.

### Decision: CSRF token is cached in memory and refreshed on sign-in/out and on rejection
Token storage is in memory only (not localStorage). To prevent race conditions where concurrent unsafe requests trigger parallel token fetches that overwrite `.AspNetCore.Antiforgery` cookies, token retrieval is deduplicated via a singleton in-flight promise. The token is refreshed after every successful sign-in and sign-out, and once on a rejected unsafe request before a single retry. Retry is safe because the CSRF middleware and the authorization filter both reject before any handler runs, so the command has not executed.

Alternative considered: fetching a token before every unsafe request. Rejected as an extra round trip for every save.

### Decision: Permission-driven navigation uses route metadata mirrored from the server's permission names
Each route declares `meta.permission` using the same string constants as the backend (`cost:view`, `customer:pii`, and so on). The shell builds the menu and guards routes from the session's permission list. The server enforces every permission again, so a client bypass cannot expose data.

Permission names are duplicated in TypeScript. To keep them in step, a small generated or checked list is produced from the Application `PermissionNames` source during the contract step; if that is not practical, a unit test asserts the list equals the names in the committed contract's documentation. (Open question below.)

### Decision: Sign-in is an overlay over the current route, not a navigation
When the session expires, a modal sign-in dialog opens on top of the current route. The route component stays mounted. If re-authenticated as the same user (`newUsername.toLowerCase() === previousUsername.toLowerCase()`), the dialog closes and unsaved form input is preserved. If re-authenticated as a different user (e.g. staff handoff on an idle terminal), all Pinia draft stores are purged and navigation redirects to the home route (`/`) to prevent leaking or cross-submitting patient PII, prescriptions, or financial transactions. Anonymous first visits navigate to `/sign-in` and remember the return path.

Alternative considered: redirect to a full sign-in page on expiry. Rejected because it discards in-memory input for legitimate same-user re-auth.

### Decision: Idempotency keys are generated per submission in the client
A submission generates one UUID when the user starts the submit action and reuses it for retries of the same submission. The key is stored only in memory for that submission. This is a contract of the financial screens built later; this change provides the helper and tests it.

### Decision: WebPivotTable is dynamically imported, self-hosted, and runtime-gated
- The component is in its own chunk loaded by the analytics route via `import()`. The route guard checks the runtime flag before the import, so disabled deployments never request the chunk.
- The package's locale JSON and any runtime assets are copied into `public/vendor/webpivottable/` by a prebuild script from the installed package, so the runtime never reaches a third-party CDN.
- The licence key and enablement flag are runtime configuration, not build-time environment variables, so one image serves all deployments. The web container writes `/config.json` at start from environment variables. The key is visible to any signed-in browser by design (the vendor's model); it is treated as confidential in repository and CI logs.
- Development and test builds use a fixture dataset module. The production build excludes it through a build-time flag and asserts absence in the output.
- The wrapper subscribes to events inside `onMounted`, keeps the unsubscribe functions, and calls them plus the instance teardown in `onBeforeUnmount`. It waits for the component's ready signal before loading data.

### Decision: Runtime configuration served as a static JSON file
`/config.json` is generated by the nginx container entrypoint from `XOPTI_ANALYTICS_ENABLED` and `XOPTI_WPT_LICENSE_KEY`. It is served with `Cache-Control: no-store`. The SPA fetches it before mounting. Missing values mean disabled.

Alternative considered: build-time `VITE_` variables. Rejected because a licence key would be baked into an image and a per-customer rebuild would be needed.

### Decision: Security headers and a strict content security policy, validated against WebPivotTable
nginx adds `Content-Security-Policy` (`default-src 'self'`; `script-src 'self'`; `style-src 'self' 'unsafe-inline'`; `worker-src 'self' blob:`; `object-src 'none'`; `frame-ancestors 'none'`), `X-Content-Type-Options: nosniff`, `Referrer-Policy: same-origin`, and `Cache-Control` rules (immutable hashed assets, `no-store` for `index.html` and `config.json`). WebPivotTable bundles Highcharts 11 which requires inline SVG styles and dynamic worker blobs; allowing inline styles and blob workers in Nginx satisfies Highcharts while keeping script execution strictly self-hosted.

### Decision: Container build as a multi-stage Dockerfile
`docker/web.Dockerfile`: a Node LTS build stage runs `npm ci`, the contract check, type-check, tests, and the production build; the final stage is `nginx:1.27-alpine` with `nginx.conf` and the entrypoint script. The `web` service in `docker/compose.yml` switches from the placeholder volume to this image; the public port mapping is unchanged.

### Decision: Tests
- Unit (Vitest): fetch middleware (CSRF deduplication, correlation id, ProblemDetails mapping), idempotency key lifecycle, permission filtering, error mapping.
- Component (Vue Test Utils): sign-in form messages (uniform failure, lockout, reset-required), expiry overlay with same-user resume vs different-user reset, analytics wrapper lifecycle (single handler per event after re-mount). Vitest config mocks `webpivottable` in jsdom to avoid Node environment crashes on browser-only globals.
- End-to-end (Playwright): sign-in, direct-URL forbidden check, expiry overlay, sign-out, run against `docker/compose.smoke.yml`.
- Build gates: type-check, contract check, production build with secret/fixture scan.

## Risks / Trade-offs

- [WebPivotTable licence is unresolved, and the Community licence forbids use in a for-profit company] → Analytics stays off by default; enabling it requires a licence key and a written licence. The Developer tier is the expected minimum, pending vendor confirmation about self-hosting.
- [Highcharts is bundled by WebPivotTable and is licensed separately] → Procurement item; tracked in the proposal and open items.
- [CSP may conflict with WebPivotTable's inline styles or workers] → Relax only the directive the route verifiably needs; keep the rest strict.
- [Client permission names drift from the server] → Server enforces; a unit test compares the client list against the backend source list.
- [Bundle size of the analytics chunk (about 15 MB unpacked)] → Lazy-loaded; a build check reports the initial bundle size and fails over a threshold.
- [Antiforgery token invalidated by sign-in] → Refreshed on sign-in and sign-out; covered by an e2e test.

## Open Questions

- Which WebPivotTable licence tier is purchased (Developer vs Team), and does the vendor confirm in writing that the npm bundle may be self-hosted in an on-prem deployment? The analytics route stays disabled until this is answered.
- Is a Highcharts commercial licence required, and who procures it?
- Permission-name sync: generate the TypeScript list from the backend source during the contract step, or keep a checked-in list with a test? Default: checked-in list with a test.
- CI platform: the repository currently has no workflow files. Default: provide an `npm run ci` script that runs every gate; wire it into the team's CI platform once chosen.
- Session warning: the client currently reacts only to the expired session. A proactive idle warning before the 20-minute timeout is deferred unless the operators request it.
