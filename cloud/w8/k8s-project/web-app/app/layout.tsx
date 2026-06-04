import type { Metadata } from "next";
import { NavBar } from "@/components/nav-bar";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "CloudScope — AWS Deployment Health Dashboard",
    template: "%s | CloudScope"
  },
  description:
    "Visualise and validate your AWS Kubernetes deployment stack — ALB, EC2, Minikube, and Next.js, all in one place."
};

export default function RootLayout({
  children
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="bg-navy-900">
        <NavBar />
        <div className="mx-auto max-w-6xl px-5 pb-20 pt-8">{children}</div>
      </body>
    </html>
  );
}
