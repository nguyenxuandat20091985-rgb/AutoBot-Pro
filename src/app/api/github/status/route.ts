import { NextRequest, NextResponse } from "next/server";
import { repoStatus } from "@/lib/github";
export async function GET(req:NextRequest){const {searchParams}=new URL(req.url);const owner=searchParams.get("owner");const repo=searchParams.get("repo");if(!owner||!repo)return NextResponse.json({error:"Thiếu owner/repo"},{status:400});try{return NextResponse.json(await repoStatus(owner,repo))}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"GitHub API error"},{status:502})}}
