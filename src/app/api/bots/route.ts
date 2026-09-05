import { NextResponse } from "next/server";
import { z } from "zod";
import { db, ensureSchema } from "@/lib/db";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const botSchema = z.object({
  name: z.string().trim().min(1).max(120),
  description: z.string().trim().max(500).default(""),
  enabled: z.boolean().default(true),
  config: z.record(z.string(), z.unknown()).default({}),
});

export async function GET() {
  try {
    await ensureSchema();
    const rows = await db()`
      select id, name, description, enabled, config, created_at, updated_at
      from autobot_bots order by created_at desc limit 100
    `;
    return NextResponse.json({ bots: rows });
  } catch (error) {
    console.error("GET /api/bots", error);
    return NextResponse.json({ error: "Database unavailable" }, { status: 503 });
  }
}

export async function POST(request: Request) {
  try {
    const body = botSchema.parse(await request.json());
    await ensureSchema();
    const [bot] = await db()`
      insert into autobot_bots (name, description, enabled, config)
      values (${body.name}, ${body.description}, ${body.enabled}, ${JSON.stringify(body.config)}::jsonb)
      returning id, name, description, enabled, config, created_at, updated_at
    `;
    return NextResponse.json({ bot }, { status: 201 });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: "Invalid bot payload", details: error.issues }, { status: 400 });
    }
    console.error("POST /api/bots", error);
    return NextResponse.json({ error: "Database unavailable" }, { status: 503 });
  }
}
