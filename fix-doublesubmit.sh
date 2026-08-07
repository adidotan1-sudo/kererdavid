set -e
cat > components/Fields.tsx << 'KDAVIDEOF'
"use client";

import { useFormStatus } from "react-dom";

const inputStyle: React.CSSProperties = {
  width: "100%",
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
KDAVIDEOF
cat > app/app/my/page.tsx << 'KDAVIDEOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { getCurrentClient } from "@/lib/session";
import { updateMyDetails, requestCard, editAppointment } from "@/lib/actions/client";
import { statusMeta } from "@/lib/services";
import { formatHeDate, formatRelative } from "@/lib/format";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { PunchDots } from "@/components/PunchDots";
import { Panel, SectionLabel } from "@/components/Panel";
import { StatusPill } from "@/components/StatusPill";
import { TextField, TextAreaField, SubmitButton, CompactSubmitButton } from "@/components/Fields";

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
  const upcoming = appointments.filter((a) => a.status === "scheduled" && a.kind === "booking");

  const isFirst = card.used === 0;
  const renewalActionLabel = isFirst ? "בקשת כרטיסייה" : "בקשת חידוש כרטיסייה";
  const renewalSentLabel = isFirst
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
          ) : (
            <form action={requestCard}>
              <CompactSubmitButton>{renewalActionLabel}</CompactSubmitButton>
            </form>
          )}
        </Panel>

        {pending.length > 0 && (
          <>
            <SectionLabel>הבקשות שלי</SectionLabel>
            {pending.map((r) => (
              <div
                key={r.id}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  background: "var(--panel)",
                  border: "1px solid var(--panel-border)",
                  borderRadius: 14,
                  padding: "13px 16px",
                  marginBottom: 10,
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{r.serviceTitle}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>
                    {formatRelative(r.createdAt)}
                  </div>
                </div>
                <StatusPill label={statusMeta[r.status]?.label ?? r.status} />
              </div>
            ))}
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
KDAVIDEOF
git add -A
git commit -m 'Prevent duplicate submissions by disabling buttons while pending'
git push
echo DONE

