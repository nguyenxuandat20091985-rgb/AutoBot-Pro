import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "AutoBot Pro",
  description: "Nền tảng quản lý và vận hành bot tự động",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="vi">
      <body>{children}</body>
    </html>
  );
}
