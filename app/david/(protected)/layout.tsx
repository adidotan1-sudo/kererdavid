import { requireProvider } from "@/lib/session";
import { Screen } from "@/components/Screen";

export default async function DavidProtectedLayout({ children }: { children: React.ReactNode }) {
  await requireProvider();
  return <Screen>{children}</Screen>;
}
