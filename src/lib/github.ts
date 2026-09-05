const API = "https://api.github.com";
export type GitHubRepo = { name:string; full_name:string; description:string|null; html_url:string; default_branch:string; pushed_at:string|null; private:boolean };
function token(){return process.env.GITHUB_TOKEN || ""}
async function gh(path:string){const t=token(); if(!t) throw new Error("GITHUB_TOKEN chưa được cấu hình"); const r=await fetch(`${API}${path}`,{headers:{Authorization:`Bearer ${t}`,Accept:"application/vnd.github+json"},next:{revalidate:60}}); if(!r.ok) throw new Error(`GitHub API ${r.status}`); return r.json()}
export async function listRepos(){return gh("/user/repos?per_page=100&sort=updated") as Promise<GitHubRepo[]>}
export async function repoStatus(owner:string,repo:string){const [commits,runs]=await Promise.all([gh(`/repos/${owner}/${repo}/commits?per_page=1`),gh(`/repos/${owner}/${repo}/actions/runs?per_page=1`)]); return {commit:commits?.[0]??null, run:runs?.workflow_runs?.[0]??null}}
export function githubConfigured(){return Boolean(token())}
