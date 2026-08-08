import { redirect } from "next/navigation";
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
      <div style={{ font: "700 20px var(--serif)", color: "var(--text-strong)", marginBottom: 4 }}>
        {request.client.name}
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
    </ScreenBody>
  );
}
