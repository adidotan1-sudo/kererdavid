import Link from "next/link";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatRelative } from "@/lib/format";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { SearchBox } from "@/components/SearchBox";

const GROUP_ORDER = ["new", "scheduled", "done"];

export default async function InboxPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();

  const allRequests = await db.appointment.findMany({
    include: { client: true },
    orderBy: { createdAt: "desc" },
  });
  const filtered = query ? allRequests.filter((r) => r.client.name.includes(query)) : allRequests;

  const newCount = allRequests.filter((r) => r.status === "new").length;

  const groups = GROUP_ORDER.map((status) => ({
    status,
    label: statusMeta[status]?.label ?? status,
    items: filtered.filter((r) => r.status === status),
  })).filter((g) => g.items.length > 0);

  return (
    <>
      <div style={{ padding: "22px 20px 8px", display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div>
          <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)" }}>שלום דויד</div>
          <div style={{ font: "13px var(--sans)", color: "var(--text-65)", marginTop: 4 }}>
            {newCount} פניות חדשות ממתינות
          </div>
        </div>
        <Link href="/david/settings" style={{ font: "600 12.5px var(--sans)", color: "var(--accent)", padding: "4px 0" }}>
          הגדרות
        </Link>
      </div>
      <div style={{ padding: "12px 20px 0" }}>
        <SearchBox />
      </div>
      <ScreenBody padding="12px 20px 84px">
        {groups.map((grp) => (
          <div key={grp.status}>
            <div style={{ font: "600 12px var(--sans)", color: "var(--accent)", letterSpacing: ".03em", margin: "14px 2px 8px" }}>
              {grp.label}
            </div>
            {grp.items.map((req) => (
              <Link
                key={req.id}
                href={`/david/requests/${req.id}`}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  background: "var(--panel)",
                  border: "1px solid var(--panel-border)",
                  borderRadius: 14,
                  padding: "13px 15px",
                  marginBottom: 9,
                  color: "inherit",
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{req.client.name}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>{req.serviceTitle}</div>
                </div>
                <div style={{ flex: "none", font: "11px var(--sans)", color: "var(--text-60)" }}>
                  {formatRelative(req.createdAt)}
                </div>
              </Link>
            ))}
          </div>
        ))}
        {groups.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)", textAlign: "center", padding: "24px 0" }}>
            אין פניות להצגה
          </div>
        )}
      </ScreenBody>
      <TabBar
        items={[
          { label: "פניות", href: "/david", active: true },
          { label: "כרטיסיות", href: "/david/cards", active: false },
        ]}
      />
    </>
  );
}
