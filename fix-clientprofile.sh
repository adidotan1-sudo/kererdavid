#!/bin/bash
set -e

mkdir -p "app/app/my"
cat > "app/app/my/page.tsx" << 'KETER_FILE_0_EOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { getCurrentClient } from "@/lib/session";
import { updateMyDetails, requestCard, requestCardTreatment, editAppointment, cancelAppointment } from "@/lib/actions/client";
import { statusMeta } from "@/lib/services";
import { formatHeDate, formatRelative } from "@/lib/format";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { PunchDots } from "@/components/PunchDots";
import { Panel, SectionLabel } from "@/components/Panel";
import { StatusPill } from "@/components/StatusPill";
import { TextField, TextAreaField, SubmitButton, CompactSubmitButton, DangerSubmitButton } from "@/components/Fields";

export const dynamic = "force-dynamic";

export default async function MyStatusPage({
  searchParams,
}: {
  searchParams: Promise<{ edit?: string; editApt?: string }>;
}) {
  const { edit, editApt } = await searchParams;
  const client = await getCurrentClient();
  if (!client) return null;
  const card = client.card ?? { used: 0, total: 10, renewalRequested: false };

  const appointments = await db.appointment.findMany({
    where: { clientId: client.id },
    orderBy: { createdAt: "desc" },
  });
  const pending = appointments.filter((a) => a.status === "new");
  const upcoming = appointments.filter((a) => a.status === "scheduled");
  const history = await db.historyEntry.findMany({
    where: { clientId: client.id },
    orderBy: { date: "desc" },
    take: 10,
  });

  const isEmpty = card.used === 0;
  const isFull = card.used >= card.total;
  const isActive = !isEmpty && !isFull;
  const renewalActionLabel = isEmpty ? "בקשת כרטיסייה" : "בקשת חידוש כרטיסייה";
  const renewalSentLabel = isEmpty
    ? "הבקשה נשלחה, דויד יחזור אליך בקרוב"
    : "בקשת החידוש נשלחה, דויד יחזור אליך בקרוב";

  const myEditMode = edit === "1";

  return (
    <>
      <ScreenBody padding="60px 20px 84px">
        <BackLink href="/app" />
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
          <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)" }}>סטטוס טיפולים שלי</div>
          <Link
            href={myEditMode ? "/app/my" : "/app/my?edit=1"}
            style={{ font: "600 12.5px var(--sans)", color: "var(--accent)" }}
          >
            {myEditMode ? "ביטול" : "עריכת פרטים"}
          </Link>
        </div>

        {myEditMode && (
          <Panel style={{ padding: 16, marginBottom: 22 }}>
            <form action={updateMyDetails}>
              <TextField label="שם מלא" name="name" defaultValue={client.name} />
              <TextField label="טלפון נייד" name="phone" defaultValue={client.phone} />
              <SubmitButton>שמירה</SubmitButton>
            </form>
          </Panel>
        )}

        <Panel style={{ padding: 18, marginBottom: 22 }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 12 }}>
            <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>כרטיסיית טיפולים</div>
            <div style={{ font: "600 12.5px var(--sans)", color: "var(--accent)" }}>
              {card.used}/{card.total} ניקובים
            </div>
          </div>
          <div style={{ marginBottom: 14 }}>
            <PunchDots total={card.total} used={card.used} />
          </div>
          {card.renewalRequested ? (
            <div
              style={{
                textAlign: "center",
                background: "var(--panel-border)",
                color: "var(--text-75)",
                borderRadius: 12,
                padding: 12,
                font: "600 13px var(--sans)",
              }}
            >
              {renewalSentLabel}
            </div>
          ) : isActive ? (
            <form action={requestCardTreatment}>
              <CompactSubmitButton>בקשת טיפול על הכרטיסייה</CompactSubmitButton>
            </form>
          ) : (
            <form action={requestCard}>
              <CompactSubmitButton>{renewalActionLabel}</CompactSubmitButton>
            </form>
          )}

          {history.length > 0 && (
            <div style={{ marginTop: 16, paddingTop: 14, borderTop: "1px solid var(--panel-border)" }}>
              <div style={{ font: "600 12px var(--sans)", color: "var(--text-65)", marginBottom: 8 }}>
                תאריכי ניקוב
              </div>
              {history.map((h, i) => (
                <div
                  key={h.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 0",
                    borderTop: i === 0 ? "none" : "1px solid var(--panel-border)",
                  }}
                >
                  <div style={{ font: "13px var(--sans)", color: "var(--text-90)" }}>{h.service}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-60)" }}>{formatHeDate(h.date)}</div>
                </div>
              ))}
            </div>
          )}
        </Panel>

        {pending.length > 0 && (
          <>
            <SectionLabel>הבקשות שלי</SectionLabel>
            {pending.map((r) => {
              const isEditing = editApt === r.id;
              return (
                <Panel key={r.id} style={{ padding: "13px 16px", marginBottom: 10 }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{r.serviceTitle}</div>
                      <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>
                        {formatRelative(r.createdAt)}
                      </div>
                    </div>
                    <StatusPill label={statusMeta[r.status]?.label ?? r.status} />
                    <Link
                      href={isEditing ? "/app/my" : `/app/my?editApt=${r.id}`}
                      style={{ flex: "none", font: "600 12px var(--sans)", color: "var(--accent)" }}
                    >
                      {isEditing ? "ביטול" : "עריכה"}
                    </Link>
                  </div>
                  {isEditing && (
                    <div style={{ marginTop: 12 }}>
                      <form action={editAppointment}>
                        <input type="hidden" name="id" value={r.id} />
                        <TextField label="תאריך" name="date" type="date" defaultValue={r.requestedDate ?? ""} />
                        <TextAreaField label="תיאור הבעיה" name="notes" defaultValue={r.notes} rows={3} />
                        <SubmitButton>שמירת שינויים</SubmitButton>
                      </form>
                      <form action={cancelAppointment}>
                        <input type="hidden" name="id" value={r.id} />
                        <DangerSubmitButton>ביטול הטיפול</DangerSubmitButton>
                      </form>
                    </div>
                  )}
                </Panel>
              );
            })}
          </>
        )}

        <SectionLabel>טיפולים קרובים</SectionLabel>
        {upcoming.map((apt) => {
          const isEditing = editApt === apt.id;
          return (
            <Panel key={apt.id} style={{ padding: "13px 16px", marginBottom: 10 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{apt.serviceTitle}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>
                    {formatHeDate(apt.requestedDate)}
                  </div>
                </div>
                <StatusPill label={statusMeta[apt.status]?.label ?? apt.status} variant="active" />
                <Link
                  href={isEditing ? "/app/my" : `/app/my?editApt=${apt.id}`}
                  style={{ flex: "none", font: "600 12px var(--sans)", color: "var(--accent)" }}
                >
                  {isEditing ? "ביטול" : "עריכה"}
                </Link>
              </div>
              {isEditing && (
                <div style={{ marginTop: 12 }}>
                  <form action={editAppointment}>
                    <input type="hidden" name="id" value={apt.id} />
                    <TextField label="תאריך" name="date" type="date" defaultValue={apt.requestedDate ?? ""} />
                    <TextAreaField label="תיאור הבעיה" name="notes" defaultValue={apt.notes} rows={3} />
                    <SubmitButton>שמירת שינויים</SubmitButton>
                  </form>
                  <form action={cancelAppointment}>
                    <input type="hidden" name="id" value={apt.id} />
                    <DangerSubmitButton>ביטול הטיפול</DangerSubmitButton>
                  </form>
                </div>
              )}
            </Panel>
          );
        })}
        {upcoming.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)", textAlign: "center", padding: "16px 0" }}>
            אין טיפולים קרובים כרגע
          </div>
        )}
      </ScreenBody>
      <TabBar
        items={[
          { label: "שירותים", href: "/app", active: false },
          { label: "שלי", href: "/app/my", active: true },
        ]}
      />
    </>
  );
}
KETER_FILE_0_EOF

mkdir -p "app/david/(protected)"
cat > "app/david/(protected)/page.tsx" << 'KETER_FILE_1_EOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatRelative } from "@/lib/format";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { SearchBox } from "@/components/SearchBox";

const GROUP_ORDER = ["new", "scheduled", "done", "cancelled"];

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
KETER_FILE_1_EOF

mkdir -p "app/david/(protected)/requests/[id]"
cat > "app/david/(protected)/requests/[id]/page.tsx" << 'KETER_FILE_2_EOF'
import { redirect } from "next/navigation";
import Link from "next/link";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatHeDate } from "@/lib/format";
import { setRequestStatus, punchRequest } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { StatusPill } from "@/components/StatusPill";

const CARD_KINDS = ["card_new", "card_renewal", "card_treatment"];
const CARD_NOTE: Record<string, string> = {
  card_new: "בקשה לכרטיסייה חדשה — לחיצה על \"נוקב\" תפתח את הכרטיסייה עם הניקוב הראשון",
  card_renewal: "בקשת חידוש כרטיסייה — לחיצה על \"נוקב\" תפתח מחזור ניקוב חדש",
  card_treatment: "טיפול מתוך כרטיסייה פעילה — לחיצה על \"נוקב\" תוסיף ניקוב לכרטיסייה",
};

const PHONE_ICON = (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
    <path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1-9.4 0-17-7.6-17-17 0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.4 0 .8-.2 1L6.6 10.8z" />
  </svg>
);

export const dynamic = "force-dynamic";

export default async function RequestDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const request = await db.appointment.findUnique({ where: { id }, include: { client: true } });
  if (!request) redirect("/david");

  const isCardKind = CARD_KINDS.includes(request.kind);
  const statusChoices = isCardKind ? (["new", "scheduled"] as const) : (["new", "scheduled", "done"] as const);
  const card = isCardKind ? await db.punchCard.findUnique({ where: { clientId: request.clientId } }) : null;

  return (
    <ScreenBody padding="60px 20px 24px">
      <BackLink href="/david" />
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 4 }}>
        <div style={{ font: "700 20px var(--serif)", color: "var(--text-strong)" }}>{request.client.name}</div>
        <Link
          href={`/david/clients/${request.clientId}`}
          style={{ font: "600 12px var(--sans)", color: "var(--accent)" }}
        >
          כל הפעילות של הלקוח
        </Link>
      </div>
      <div
        style={{
          display: "inline-block",
          background: "var(--pill)",
          color: "var(--accent)",
          font: "600 12.5px var(--sans)",
          padding: "6px 12px",
          borderRadius: 20,
          margin: "8px 0 20px",
        }}
      >
        {request.serviceTitle}
      </div>

      <div style={{ font: "600 12.5px var(--sans)", color: "var(--text-70)", marginBottom: 6 }}>תאריך מבוקש</div>
      <div style={{ font: "13.5px var(--sans)", color: "var(--accent)", margin: "0 0 16px" }}>
        {formatHeDate(request.requestedDate)}
      </div>

      <div style={{ font: "600 12.5px var(--sans)", color: "var(--text-70)", marginBottom: 6 }}>תיאור מהלקוח</div>
      <p
        style={{
          font: "13.5px/1.7 var(--sans)",
          color: "var(--text-82)",
          background: "var(--panel)",
          border: "1px solid var(--panel-border)",
          borderRadius: 12,
          padding: 13,
          margin: "0 0 20px",
        }}
      >
        {request.notes}
      </p>

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
          {request.phone}
        </div>
      </div>

      <div style={{ font: "600 12.5px var(--sans)", color: "var(--text-70)", marginBottom: 10 }}>סטטוס הפנייה</div>
      {request.status === "cancelled" ? (
        <StatusPill label="בוטל על ידי הלקוח" variant="danger" />
      ) : (
        <>
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" }}>
            {statusChoices.map((st) => (
              <form key={st} action={setRequestStatus}>
                <input type="hidden" name="id" value={request.id} />
                <input type="hidden" name="status" value={st} />
                <StatusPill
                  label={statusMeta[st].label}
                  variant={request.status === st ? "selected" : "unselected"}
                  submit
                />
              </form>
            ))}
            {isCardKind &&
              (request.status === "done" ? (
                <StatusPill label="✓ נוקב" variant="active" />
              ) : (
                <form action={punchRequest}>
                  <input type="hidden" name="id" value={request.id} />
                  <StatusPill label="נוקב" variant="active" submit />
                </form>
              ))}
          </div>

          {isCardKind && card && (
            <div style={{ marginTop: 14 }}>
              <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginBottom: 4 }}>
                {request.status === "done" ? "הכרטיסייה עודכנה" : CARD_NOTE[request.kind]}
              </div>
              <div style={{ font: "600 13px var(--sans)", color: "var(--accent)" }}>
                {card.used} מתוך {card.total} ניקובים
              </div>
            </div>
          )}
        </>
      )}
    </ScreenBody>
  );
}
KETER_FILE_2_EOF

mkdir -p "app/david/(protected)/clients/[id]"
cat > "app/david/(protected)/clients/[id]/page.tsx" << 'KETER_FILE_3_EOF'
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
KETER_FILE_3_EOF

mkdir -p "components"
cat > "components/Fields.tsx" << 'KETER_FILE_4_EOF'
"use client";

import { useFormStatus } from "react-dom";

const inputStyle: React.CSSProperties = {
  width: "100%",
  minWidth: 0,
  background: "var(--input-bg)",
  border: "1px solid var(--input-border)",
  borderRadius: 12,
  padding: "13px 14px",
  color: "var(--text)",
  font: "14px var(--sans)",
  marginBottom: 16,
};

const labelStyle: React.CSSProperties = {
  display: "block",
  font: "600 12.5px var(--sans)",
  color: "var(--text-70)",
  marginBottom: 6,
};

export function TextField({
  label,
  name,
  defaultValue,
  placeholder,
  type = "text",
  required,
}: {
  label: string;
  name: string;
  defaultValue?: string;
  placeholder?: string;
  type?: string;
  required?: boolean;
}) {
  return (
    <div>
      <label style={labelStyle}>{label}</label>
      <input
        name={name}
        type={type}
        defaultValue={defaultValue}
        placeholder={placeholder}
        required={required}
        style={inputStyle}
      />
    </div>
  );
}

export function TextAreaField({
  label,
  name,
  defaultValue,
  placeholder,
  rows = 4,
}: {
  label: string;
  name: string;
  defaultValue?: string;
  placeholder?: string;
  rows?: number;
}) {
  return (
    <div>
      <label style={labelStyle}>{label}</label>
      <textarea
        name={name}
        defaultValue={defaultValue}
        placeholder={placeholder}
        rows={rows}
        style={{ ...inputStyle, resize: "none", lineHeight: 1.5 }}
      />
    </div>
  );
}

export function SelectField({
  label,
  name,
  options,
  defaultValue,
}: {
  label: string;
  name: string;
  options: { value: string; label: string }[];
  defaultValue?: string;
}) {
  return (
    <div>
      <label style={labelStyle}>{label}</label>
      <select name={name} defaultValue={defaultValue} style={inputStyle}>
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
    </div>
  );
}

export function SubmitButton({ children, disabled }: { children: React.ReactNode; disabled?: boolean }) {
  const { pending } = useFormStatus();
  const isDisabled = disabled || pending;
  return (
    <button
      type="submit"
      disabled={isDisabled}
      style={{
        width: "100%",
        textAlign: "center",
        borderRadius: 14,
        padding: 15,
        font: "700 15px var(--sans)",
        cursor: isDisabled ? "not-allowed" : "pointer",
        background: isDisabled ? "oklch(0.3 0.03 260)" : "var(--accent)",
        color: isDisabled ? "var(--text-55)" : "var(--accent-ink)",
      }}
    >
      {pending ? "שולח..." : children}
    </button>
  );
}

export function CompactSubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      style={{
        width: "100%",
        textAlign: "center",
        background: pending ? "oklch(0.3 0.03 260)" : "var(--accent)",
        color: pending ? "var(--text-55)" : "var(--accent-ink)",
        borderRadius: 12,
        padding: 12,
        font: "700 13.5px var(--sans)",
        cursor: pending ? "not-allowed" : "pointer",
      }}
    >
      {pending ? "שולח..." : children}
    </button>
  );
}

export function DangerSubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      style={{
        width: "100%",
        textAlign: "center",
        background: "transparent",
        color: pending ? "var(--text-55)" : "oklch(0.7 0.16 25)",
        border: `1px solid ${pending ? "var(--input-border)" : "oklch(0.4 0.12 25)"}`,
        borderRadius: 12,
        padding: 11,
        font: "700 13px var(--sans)",
        cursor: pending ? "not-allowed" : "pointer",
        marginTop: 8,
      }}
    >
      {pending ? "מבטל..." : children}
    </button>
  );
}
KETER_FILE_4_EOF

mkdir -p "components"
cat > "components/StatusPill.tsx" << 'KETER_FILE_5_EOF'
type Variant = "neutral" | "active" | "selected" | "unselected" | "danger";

const VARIANT_STYLE: Record<Variant, React.CSSProperties> = {
  neutral: { background: "var(--panel-border)", color: "var(--accent)" },
  active: { background: "var(--green-bg)", color: "var(--green-text)" },
  selected: { background: "var(--accent)", color: "var(--accent-ink)", border: "1px solid var(--accent)" },
  unselected: { background: "var(--input-bg)", color: "var(--text-85)", border: "1px solid var(--input-border)" },
  danger: { background: "oklch(0.3 0.1 25)", color: "oklch(0.8 0.14 25)" },
};

export function StatusPill({
  label,
  variant = "neutral",
  submit,
}: {
  label: string;
  variant?: Variant;
  /** Render as a form-submit button (for use inside a <form action=...>) instead of a plain display pill. */
  submit?: boolean;
}) {
  const style: React.CSSProperties = {
    display: "inline-block",
    font: "600 11px var(--sans)",
    padding: "4px 10px",
    borderRadius: 20,
    ...VARIANT_STYLE[variant],
  };
  if (submit) {
    return (
      <button
        type="submit"
        style={{ ...style, font: "600 12.5px var(--sans)", padding: "9px 16px", cursor: "pointer" }}
      >
        {label}
      </button>
    );
  }
  return <span style={style}>{label}</span>;
}
KETER_FILE_5_EOF

mkdir -p "lib/actions"
cat > "lib/actions/client.ts" << 'KETER_FILE_6_EOF'
"use server";

import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { createClientSession, requireClient } from "@/lib/session";
import { findService } from "@/lib/services";

export async function registerClient(formData: FormData) {
  const name = String(formData.get("name") || "").trim();
  const phone = String(formData.get("phone") || "").trim();
  if (!name || !phone) redirect("/");

  let client = await db.client.findUnique({ where: { phone } });
  if (!client) {
    client = await db.client.create({
      data: { name, phone, card: { create: { total: 10, used: 0 } } },
    });
  } else {
    client = await db.client.update({ where: { id: client.id }, data: { name } });
    const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
    if (!card) await db.punchCard.create({ data: { clientId: client.id, total: 10, used: 0 } });
  }
  await createClientSession(client.id);
  redirect("/app");
}

export async function updateMyDetails(formData: FormData) {
  const client = await requireClient();
  const name = String(formData.get("name") || "").trim();
  const phone = String(formData.get("phone") || "").trim();
  if (name && phone) {
    try {
      await db.client.update({ where: { id: client.id }, data: { name, phone } });
    } catch {
      // phone already taken by another client — keep previous values
    }
  }
  redirect("/app/my");
}

export async function submitBooking(formData: FormData) {
  const client = await requireClient();
  const serviceId = String(formData.get("serviceId") || "");
  const service = findService(serviceId);
  const name = String(formData.get("name") || "").trim() || client.name;
  const phone = String(formData.get("phone") || "").trim() || client.phone;
  const date = String(formData.get("date") || "");
  const notes = String(formData.get("notes") || "").trim() || "—";

  await db.client.update({ where: { id: client.id }, data: { name, phone } });
  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceId: service?.id,
      serviceTitle: service?.title || "",
      phone,
      notes,
      requestedDate: date || null,
      status: "new",
      kind: "booking",
    },
  });
  redirect("/app/confirmed");
}

export async function requestCard(_formData: FormData) {
  const client = await requireClient();
  const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
  if (!card || card.renewalRequested) redirect("/app/my");

  const isFirst = card.used === 0;
  await db.punchCard.update({ where: { clientId: client.id }, data: { renewalRequested: true } });
  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceTitle: isFirst ? "בקשת כרטיסיית טיפולים" : "חידוש כרטיסיית טיפולים",
      phone: client.phone,
      notes: isFirst ? "בקשה לפתיחת כרטיסיית 10 טיפולים." : "בקשה לחידוש כרטיסיית 10 טיפולים.",
      status: "new",
      kind: isFirst ? "card_new" : "card_renewal",
    },
  });
  redirect("/app/my");
}

export async function requestCardTreatment(_formData: FormData) {
  const client = await requireClient();
  const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
  if (!card || card.used <= 0 || card.used >= card.total) redirect("/app/my");

  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceTitle: "בקשת טיפול על הכרטיסייה",
      phone: client.phone,
      notes: "בקשה לטיפול נוסף במסגרת הכרטיסייה הפעילה.",
      status: "new",
      kind: "card_treatment",
    },
  });
  redirect("/app/my");
}

export async function cancelAppointment(formData: FormData) {
  const client = await requireClient();
  const id = String(formData.get("id") || "");

  const appt = await db.appointment.findUnique({ where: { id } });
  if (!appt || appt.clientId !== client.id) redirect("/app/my");
  if (appt.status === "done" || appt.status === "cancelled") redirect("/app/my");

  await db.appointment.update({ where: { id }, data: { status: "cancelled" } });

  if (appt.kind === "card_new" || appt.kind === "card_renewal") {
    await db.punchCard.update({ where: { clientId: client.id }, data: { renewalRequested: false } });
  }

  redirect("/app/my");
}

export async function editAppointment(formData: FormData) {
  const client = await requireClient();
  const id = String(formData.get("id") || "");
  const date = String(formData.get("date") || "");
  const notes = String(formData.get("notes") || "").trim();

  const appt = await db.appointment.findUnique({ where: { id } });
  if (!appt || appt.clientId !== client.id) redirect("/app/my");

  await db.appointment.update({
    where: { id },
    data: { requestedDate: date || null, notes: notes || appt.notes },
  });
  redirect("/app/my");
}
KETER_FILE_6_EOF

mkdir -p "lib"
cat > "lib/services.ts" << 'KETER_FILE_7_EOF'
export type Service = {
  id: string;
  title: string;
  tagline: string;
  desc: string;
  included: string[];
};

export const services: Service[] = [
  {
    id: "ayin",
    title: "הסרת עין הרע",
    tagline: "הגנה וטיהור אנרגטי אישי",
    desc: "עין הרע היא אנרגיה שלילית שעוברת מאדם לאדם, מכוונת או לא, ומשפיעה על מצב הרוח, השינה והמזל. הטיפול מזהה את המקור ומסיר את ההשפעה מהגוף ומהבית.",
    included: ["אבחון אנרגטי", "הסרת ההשפעה", "הגנה למניעה חוזרת"],
  },
  {
    id: "spell",
    title: "הסרת כישופים",
    tagline: "איתור והסרה של כישוף",
    desc: "טיפול לאיתור והסרה של כישוף שהוטל, כולל בדיקה של מוצא ההשפעה והדרך שבה נכנסה לחיים.",
    included: ["איתור מקור הכישוף", "הסרה מהגוף והבית", "חיזוק הגנה אישית"],
  },
  {
    id: "home",
    title: "טיהור הבית / העסק",
    tagline: "ניקוי אנרגטי למרחב",
    desc: "ניקוי אנרגטי למרחב המגורים או העסק, מסיר שאריות אנרגטיות ומחזיר תחושת קלילות וזרימה.",
    included: ["סקירת המרחב", "ניקוי פינה פינה", "המלצות לשימור הטיהור"],
  },
  {
    id: "balance",
    title: "איזון אנרגטי",
    tagline: "איזון שדה האנרגיה האישי",
    desc: "טיפול לאיזון שדה האנרגיה האישי, מתאים למי שמרגיש עייפות, חוסר מיקוד או תחושת כובד מתמשכת.",
    included: ["מיפוי אנרגטי", "איזון מרכזי אנרגיה", "תרגיל המשך לבית"],
  },
  {
    id: "blocks",
    title: "הסרת חסמות ותיקונים",
    tagline: "הסרת חסמים חוזרים",
    desc: "לפעמים מכשולים חוזרים בעבודה, בזוגיות או בכלכלה מקורם בחסם אנרגטי. הטיפול מזהה את החסם ופועל להסרתו.",
    included: ["איתור החסם", "טיפול ממוקד", "בדיקת מעקב"],
  },
  {
    id: "anxiety",
    title: "טיפול בחרדות",
    tagline: "ליווי אנרגטי לחרדה ולחץ",
    desc: "ליווי אנרגטי לתחושות חרדה, לחץ ומתח מתמשך, בשילוב טכניקות הרגעה והגנה.",
    included: ["שיחת פתיחה", "טיפול הרגעה", "כלים להתמודדות יומיומית"],
  },
];

export function findService(id: string | null | undefined): Service | null {
  if (!id) return null;
  return services.find((s) => s.id === id) ?? null;
}

export const statusMeta: Record<string, { label: string }> = {
  new: { label: "חדש" },
  scheduled: { label: "מתוזמן" },
  done: { label: "הושלם" },
  cancelled: { label: "בוטל" },
};
KETER_FILE_7_EOF

git add "app/app/my/page.tsx" "app/david/(protected)/page.tsx" "app/david/(protected)/requests/[id]/page.tsx" "app/david/(protected)/clients/[id]/page.tsx" "components/Fields.tsx" "components/StatusPill.tsx" "lib/actions/client.ts" "lib/services.ts"
git commit -m "Cancel/status visibility, date-overflow fix, unified client profile" --allow-empty
git push
echo DONE

