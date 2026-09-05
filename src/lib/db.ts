import postgres from "postgres";

let sql: ReturnType<typeof postgres> | null = null;

export function db() {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not configured");
  }
  sql ??= postgres(process.env.DATABASE_URL, {
    max: 1,
    prepare: false,
    idle_timeout: 20,
    connect_timeout: 10,
  });
  return sql;
}

export async function ensureSchema() {
  const client = db();
  await client`
    create table if not exists autobot_bots (
      id uuid primary key default gen_random_uuid(),
      name text not null,
      description text not null default '',
      enabled boolean not null default true,
      config jsonb not null default '{}'::jsonb,
      created_at timestamptz not null default now(),
      updated_at timestamptz not null default now()
    )
  `;
}
