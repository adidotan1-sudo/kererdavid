import { requireClient } from "@/lib/session";
import { Screen } from "@/components/Screen";

export default async function ClientAreaLayout({ children }: { children: React.ReactNode }) {
  await requireClient();
  return <Screen>{children}</Screen>;
}
