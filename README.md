# AutoBot Pro

Vercel-native Next.js application for the AutoBot Pro control plane.

## Architecture

- Next.js App Router for the web UI.
- Vercel Node.js Serverless Functions for `/api/*` routes.
- PostgreSQL via `DATABASE_URL` using the `postgres` driver.
- Zod for API input validation.
- No Docker or VPS is required for the Next.js application.

## Vercel deployment

Import `nguyenxuandat20091985-rgb/AutoBot-Pro` as a Next.js project and leave **Root Directory** empty. Vercel should detect `package.json` and run `npm run build`.

Required environment variable:

```text
DATABASE_URL=postgresql://...
```

Endpoints:

- `GET /api/health` — runtime/configuration health check.
- `GET /api/bots` — list bot definitions.
- `POST /api/bots` — create a bot definition.

The API creates the small control-plane schema lazily on first database access. For production, use managed PostgreSQL and keep credentials in Vercel Environment Variables.

## Important scope note

The previous repository contained infrastructure scripts that clone Typebot v2.28.2 and run Docker services. Shell/Docker operations cannot execute inside Vercel Serverless Functions. This repository now contains a Vercel-native control-plane implementation of the bot configuration logic; it is **not** a byte-for-byte port of the complete Typebot Builder/Viewer runtime.

Full Typebot functionality requires porting each upstream application subsystem or running its supported server architecture separately. The existing Docker scripts are retained as an infrastructure option and are not used by the Next.js deployment.

Any redistribution of upstream Typebot-derived source must preserve its applicable AGPLv3 license and copyright notices.
