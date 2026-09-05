import { NextResponse } from "next/server";
export async function GET(){return NextResponse.json({configured:Boolean(process.env.GITHUB_TOKEN)})}
export async function POST(){return NextResponse.json({error:"Không lưu token từ trình duyệt. Hãy cấu hình GITHUB_TOKEN trong Vercel Environment Variables."},{status:400})}
