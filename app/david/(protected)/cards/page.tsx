import Link from "next/link";
import { db } from "@/lib/db";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { SearchBox } from "@/components/SearchBox";
import { PunchDots } from "@/components/PunchDots";
import { StatusPill } from "@/components/StatusPill";

export const dynamic = "force-dynamic";

export default async function CardsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();

  const clients = await db.client.findMany({
    include: { card: true },
    orderBy: { name: "asc" },
  });
  const filtered = query ? clients.filter((c) => c.name.includes(query)) : clients;
  const withCards = filtered.filter((c) => c.card);

  const completedCount = clients.filter((c) => c.card && c.card.used >= c.card.total).length;

  return (
    <>
      <div style={{ padding: "22px 20px 8px" }}>
        <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)" }}>כרטיסיות</div>
        <div style={{ font: "13px var(--sans)", color: "var(--text-65)", marginTop: 4 }}>
          {completedCount} כרטיסיות הסתיימו מתוך {clients.length}
        </div>
      </div>
      <div style={{ padding: "12px 20px 0" }}>
        <SearchBox />
      </div>
      <ScreenBody padding="12px 20px 84px">
        {withCards.map((c) => {
          const card = c.card!;
          const completed = card.used >= card.total;
          return (
            <Link
              key={c.id}
              href={`/david/clients/${c.id}`}
              style={{
                display: "block",
                background: "var(--panel)",
                border: "1px solid var(--panel-border)",
                borderRadius: 14,
                padding: "14px 16px",
                marginBottom: 10,
                color: "inherit",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 8 }}>
                <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{c.name}</div>
                <StatusPill label={completed ? "הסתיימה" : "פעילה"} variant={completed ? "neutral" : "active"} />
              </div>
              <div style={{ marginBottom: 6 }}>
                <PunchDots total={card.total} used={card.used} size={10} />
              </div>
              <div style={{ font: "12px var(--sans)", color: "var(--text-65)" }}>
                {card.used} מתוך {card.total} ניקובים נוצלו
              </div>
            </Link>
          );
        })}
        {withCards.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)", textAlign: "center", padding: "24px 0" }}>
            אין כרטיסיות להצגה
          </div>
        )}
      </ScreenBody>
      <TabBar
        items={[
          { label: "פניות", href: "/david", active: false },
          { label: "כרטיסיות", href: "/david/cards", active: true },
        ]}
      />
    </>
  );
}
