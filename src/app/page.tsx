export default function Home() {
  return (
    <main>
      <header>
        <div className="brand">AutoBot Pro</div>
        <div className="badge">Vercel Serverless</div>
      </header>
      <section className="grid">
        <article className="card">
          <h2>Quản lý bot</h2>
          <p className="muted">Tạo và quản lý cấu hình bot qua API serverless tại <code>/api/bots</code>.</p>
        </article>
        <article className="card">
          <h2>Trạng thái hệ thống</h2>
          <p className="muted">Kiểm tra runtime và cấu hình database tại <code>/api/health</code>.</p>
        </article>
        <article className="card">
          <h2>Triển khai</h2>
          <p className="muted">Ứng dụng không cần Docker hoặc VPS; Vercel tự build và chạy các API route.</p>
        </article>
      </section>
    </main>
  );
}
