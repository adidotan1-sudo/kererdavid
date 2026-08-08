import { redirect } from "next/navigation";
import Link from "next/link";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatHeDate, formatRelative } from "@/lib/format";
import { adjustCardUsed } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { Panel, SectionLabel } from "@/components/Panel";
import { PunchDots } from "@/components/PunchDots";

const GROUP_ORDER = ["new", "scheduled", "done", "cancelled"];

const PHONE_ICON = (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
    <path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1-9.4 0-17-7.6-17-17 0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.4 0 .8-.2 1L6.6 10.8z" />
  </svg>
);

export const dynamic = "force-dynamic";

export default async function ClientDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ editCard?: string }>;
}) {
  const { id } = await params;
  const { editCard } = await searchParams;
  const client = await db.client.findUnique({
    where: { id },
    include: {
      card: true,
      history: { orderBy: { date: "desc" } },
      appointments: { orderBy: { createdAt: "desc" } },
    },
  });
  if (!client || !client.card) redirect("/david/cards");
  const card = client.card;
  const completed = card.used >= card.total;
  const cardEditMode = editCard === "1";

  const byService = new Map<string, number>();
  for (const h of client.history) byService.set(h.service, (byService.get(h.service) ?? 0) + 1);
  const summary = Array.from(byService.entries());

  const requestGroups = GROUP_ORDER.map((status) => ({
    status,
    label: statusMeta[status]?.label ?? status,
    items: client.appointments.filter((a) => a.status === status),
  })).filter((g) => g.items.length > 0);

  return (
    <ScreenBody padding="60px 20px 24px">
      <BackLink href="/david/cards" />
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 16 }}>
        <div style={{ font: "700 20px var(--serif)", color: "var(--text-strong)" }}>{client.name}</div>
        <div
          style={{
            font: "600 11px var(--sans)",
            padding: "4px 10px",
            borderRadius: 20,
            background: "var(--panel-border)",
            color: "var(--accent)",
          }}
        >
          {completed ? "הסתיימה" : "פעילה"}
        </div>
      </div>

      <div style={{ display: "flex", gap: 10, marginBottom: 22 }}>
        <div
          style={{
            flex: 1,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: 8,
            background: "var(--input-bg)",
            border: "1px solid var(--input-border)",
            borderRadius: 12,
            padding: 12,
            font: "600 13px var(--sans)",
            color: "var(--text-90)",
          }}
        >
          {PHONE_ICON}
          {client.phone}
        </div>
      </div>

      <Panel style={{ padding: "14px 16px", marginBottom: 22 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
          <div style={{ font: "600 13px var(--sans)", color: "var(--text)" }}>כרטיסייה</div>
          <Link
            href={cardEditMode ? `/david/clients/${client.id}` : `/david/clients/${client.id}?editCard=1`}
            style={{ font: "600 12px var(--sans)", color: "var(--accent)" }}
          >
            {cardEditMode ? "סיום עריכה" : "תיקון ניקובים"}
          </Link>
        </div>
        <div style={{ marginBottom: 8 }}>
          <PunchDots total={card.total} used={card.used} size={10} />
        </div>
        <div style={{ font: "12px var(--sans)", color: "var(--text-65)" }}>
          {card.used} מתוך {card.total} ניקובים נוצלו
        </div>
        {cardEditMode && (
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginTop: 14 }}>
            <form action={adjustCardUsed}>
              <input type="hidden" name="clientId" value={client.id} />
              <input type="hidden" name="delta" value="-1" />
              <button
                type="submit"
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 9,
                  background: "var(--input-bg)",
                  border: "1px solid var(--input-border)",
                  color: "var(--text)",
                  font: "700 16px var(--sans)",
                  cursor: "pointer",
                }}
              >
                −
              </button>
            </form>
            <div style={{ flex: 1, textAlign: "center", font: "600 14px var(--sans)", color: "var(--text)" }}>
              {card.used} ניקובים
            </div>
            <form action={adjustCardUsed}>
              <input type="hidden" name="clientId" value={client.id} />
              <input type="hidden" name="delta" value="1" />
              <button
                type="submit"
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 9,
                  background: "var(--accent)",
                  border: "none",
                  color: "var(--accent-ink)",
                  font: "700 16px var(--sans)",
                  cursor: "pointer",
                }}
              >
                +
              </button>
            </form>
          </div>
        )}
      </Panel>

      <SectionLabel>בקשות</SectionLabel>
      {requestGroups.length === 0 && (
        <div style={{ font: "13px var(--sans)", color: "var(--text-60)", marginBottom: 22 }}>אין בקשות עדיין</div>
      )}
      {requestGroups.map((grp) => (
        <div key={grp.status} style={{ marginBottom: 14 }}>
          <div style={{ font: "600 11.5px var(--sans)", color: "var(--text-65)", margin: "0 2px 6px" }}>
            {grp.label}
          </div>
          {grp.items.map((req) => (
            <Link
              key={req.id}
              href={`/david/requests/${req.id}`}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                background: "var(--panel)",
                border: "1px solid var(--panel-border)",
                borderRadius: 12,
                padding: "11px 13px",
                marginBottom: 8,
                color: "inherit",
              }}
            >
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: "600 13.5px var(--sans)", color: "var(--text)" }}>{req.serviceTitle}</div>
                <div style={{ font: "11.5px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>
                  {formatRelative(req.createdAt)}
                </div>
              </div>
              <div style={{ flex: "none", font: "16px var(--sans)", color: "var(--text-55)" }}>‹</div>
            </Link>
          ))}
        </div>
      ))}

      <div style={{ font: "600 13px var(--sans)", color: "var(--accent)", marginBottom: 10 }}>סיכום טיפולים</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 22 }}>
        {summary.map(([service, count]) => (
          <div
            key={service}
            style={{
              display: "flex",
              justifyContent: "space-between",
              background: "var(--panel)",
              border: "1px solid var(--panel-border)",
              borderRadius: 10,
              padding: "9px 13px",
              font: "13px var(--sans)",
              color: "var(--text-85)",
            }}
          >
            <div>{service}</div>
            <div style={{ color: "var(--accent)", fontWeight: 600 }}>{count}</div>
          </div>
        ))}
        {summary.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)" }}>אין עדיין טיפולים שהושלמו</div>
        )}
      </div>

      <SectionLabel>היסטוריית טיפולים</SectionLabel>
      {client.history.map((h) => (
        <div
          key={h.id}
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            padding: "10px 2px",
            borderBottom: "1px solid var(--panel-border)",
          }}
        >
          <div style={{ font: "13.5px var(--sans)", color: "var(--text-90)" }}>{h.service}</div>
          <div style={{ font: "12px var(--sans)", color: "var(--text-60)" }}>{formatHeDate(h.date)}</div>
        </div>
      ))}
    </ScreenBody>
  );
}
