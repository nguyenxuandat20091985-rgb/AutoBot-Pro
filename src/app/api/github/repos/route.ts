import { NextResponse } from "next/server";
import { githubConfigured, listRepos } from "@/lib/github";
export async function GET(){if(!githubConfigured()) return NextResponse.json({configured:false,repos:[]},{status:200}); try{return NextResponse.json({configured:true,repos:await listRepos()})}catch(e){return NextResponse.json({error:e instanceof Error?e.message:"GitHub API error"},{status:502})}}
