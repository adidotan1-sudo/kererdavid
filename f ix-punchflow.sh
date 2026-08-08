#!/bin/bash
set -e

mkdir -p "app/app/my"
cat > "app/app/my/page.tsx" << 'KETER_FILE_0_EOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { getCurrentClient } from "@/lib/session";
import { updateMyDetails, requestCard, requestCardTreatment, editAppointment } from "@/lib/actions/client";
import { statusMeta, services } from "@/lib/services";
import { formatHeDate, formatRelative } from "@/lib/format";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { PunchDots } from "@/components/PunchDots";
import { Panel, SectionLabel } from "@/components/Panel";
import { StatusPill } from "@/components/StatusPill";
import { TextField, TextAreaField, SelectField, SubmitButton, CompactSubmitButton } from "@/components/Fields";

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
  const history = await db.historyEntry.findMany({
    where: { clientId: client.id },
    orderBy: { date: "desc" },
    take: 5,
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
              <SelectField
                label="איזה טיפול תרצי לבקש?"
                name="serviceId"
                options={services.map((s) => ({ value: s.id, label: s.title }))}
              />
              <TextField label="תאריך רצוי" name="date" type="date" />
              <TextAreaField label="הערות (לא חובה)" name="notes" rows={2} />
              <CompactSubmitButton>בקשת טיפול על הכרטיסייה</CompactSubmitButton>
            </form>
          ) : (
            <form action={requestCard}>
              <CompactSubmitButton>{renewalActionLabel}</CompactSubmitButton>
            </form>
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

        {history.length > 0 && (
          <>
            <SectionLabel>טיפולים שהושלמו</SectionLabel>
            <Panel style={{ padding: "4px 16px", marginBottom: 22 }}>
              {history.map((h, i) => (
                <div
                  key={h.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "11px 0",
                    borderTop: i === 0 ? "none" : "1px solid var(--panel-border)",
                  }}
                >
                  <div style={{ font: "13.5px var(--sans)", color: "var(--text-90)" }}>{h.service}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-60)" }}>{formatHeDate(h.date)}</div>
                </div>
              ))}
            </Panel>
          </>
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

mkdir -p "app/david/(protected)/requests/[id]"
cat > "app/david/(protected)/requests/[id]/page.tsx" << 'KETER_FILE_1_EOF'
import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatHeDate } from "@/lib/format";
import { setRequestStatus, punchRequest } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { StatusPill } from "@/components/StatusPill";
import { CompactSubmitButton } from "@/components/Fields";

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

export default async function RequestDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const request = await db.appointment.findUnique({ where: { id }, include: { client: true } });
  if (!request) redirect("/david");

  const isCardKind = CARD_KINDS.includes(request.kind);
  const statusChoices = isCardKind ? (["new", "scheduled"] as const) : (["new", "scheduled", "done"] as const);

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
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
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
      </div>

      {isCardKind && (
        <div style={{ marginTop: 20 }}>
          {request.status === "done" ? (
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
              ✓ נוקב — הכרטיסייה עודכנה
            </div>
          ) : (
            <>
              <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginBottom: 10 }}>
                {CARD_NOTE[request.kind]}
              </div>
              <form action={punchRequest}>
                <input type="hidden" name="id" value={request.id} />
                <CompactSubmitButton>נוקב</CompactSubmitButton>
              </form>
            </>
          )}
        </div>
      )}
    </ScreenBody>
  );
}
KETER_FILE_1_EOF

mkdir -p "components"
cat > "components/Fields.tsx" << 'KETER_FILE_2_EOF'
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
KETER_FILE_2_EOF

mkdir -p "lib/actions"
cat > "lib/actions/client.ts" << 'KETER_FILE_3_EOF'
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

export async function requestCardTreatment(formData: FormData) {
  const client = await requireClient();
  const serviceId = String(formData.get("serviceId") || "");
  const service = findService(serviceId);
  const date = String(formData.get("date") || "");
  const notes = String(formData.get("notes") || "").trim() || "—";

  const card = await db.punchCard.findUnique({ where: { clientId: client.id } });
  if (!card || card.used <= 0 || card.used >= card.total) redirect("/app/my");

  await db.appointment.create({
    data: {
      clientId: client.id,
      serviceId: service?.id,
      serviceTitle: service?.title || "",
      phone: client.phone,
      notes,
      requestedDate: date || null,
      status: "new",
      kind: "card_treatment",
    },
  });
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
KETER_FILE_3_EOF

mkdir -p "lib/actions"
cat > "lib/actions/provider.ts" << 'KETER_FILE_4_EOF'
"use server";

import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { createProviderSession, hashPin, requireProvider, verifyPin } from "@/lib/session";

export async function providerLogin(formData: FormData) {
  const pin = String(formData.get("pin") || "").trim();
  const auth = await db.providerAuth.findUnique({ where: { id: 1 } });
  if (!auth || !verifyPin(pin, auth.pinHash, auth.pinSalt)) {
    redirect("/david/login?error=1");
  }
  await createProviderSession();
  redirect("/david");
}

export async function setRequestStatus(formData: FormData) {
  await requireProvider();
  const id = String(formData.get("id") || "");
  const status = String(formData.get("status") || "");
  if (!["new", "scheduled", "done"].includes(status)) redirect(`/david/requests/${id}`);

  const appt = await db.appointment.update({ where: { id }, data: { status } });

  if (status === "done" && appt.kind === "booking" && appt.serviceTitle) {
    await db.historyEntry.create({
      data: {
        clientId: appt.clientId,
        service: appt.serviceTitle,
        date: appt.requestedDate ? new Date(appt.requestedDate) : new Date(),
      },
    });
  }
  redirect(`/david/requests/${id}`);
}

// Punches the client's card and closes out a card-linked request (card_new,
// card_renewal, card_treatment) in one action, so the punch always happens
// together with completion instead of relying on David to remember a
// separate manual adjustment on the client's card screen.
export async function punchRequest(formData: FormData) {
  await requireProvider();
  const id = String(formData.get("id") || "");
  const appt = await db.appointment.findUnique({ where: { id } });
  if (!appt) redirect("/david");

  await db.appointment.update({ where: { id }, data: { status: "done" } });

  const card = await db.punchCard.findUnique({ where: { clientId: appt.clientId } });
  if (card) {
    if (appt.kind === "card_new" || appt.kind === "card_renewal") {
      await db.punchCard.update({
        where: { clientId: appt.clientId },
        data: { used: 1, renewalRequested: false },
      });
    } else if (appt.kind === "card_treatment") {
      await db.punchCard.update({
        where: { clientId: appt.clientId },
        data: { used: Math.min(card.total, card.used + 1) },
      });
    }
  }

  if (appt.kind === "card_treatment" && appt.serviceTitle) {
    await db.historyEntry.create({
      data: {
        clientId: appt.clientId,
        service: appt.serviceTitle,
        date: appt.requestedDate ? new Date(appt.requestedDate) : new Date(),
      },
    });
  }

  redirect(`/david/requests/${id}`);
}

export async function adjustCardUsed(formData: FormData) {
  await requireProvider();
  const clientId = String(formData.get("clientId") || "");
  const delta = Number(formData.get("delta") || 0);
  const card = await db.punchCard.findUnique({ where: { clientId } });
  if (!card) redirect(`/david/clients/${clientId}`);

  const used = Math.max(0, Math.min(card.total, card.used + delta));
  await db.punchCard.update({ where: { clientId }, data: { used } });
  redirect(`/david/clients/${clientId}`);
}

export async function changePin(formData: FormData) {
  await requireProvider();
  const current = String(formData.get("current") || "").trim();
  const next = String(formData.get("next") || "").trim();
  const confirm = String(formData.get("confirm") || "").trim();

  const auth = await db.providerAuth.findUnique({ where: { id: 1 } });
  if (!auth || !verifyPin(current, auth.pinHash, auth.pinSalt)) {
    redirect("/david/settings?error=wrong");
  }
  if (next.length < 4 || next !== confirm) {
    redirect("/david/settings?error=invalid");
  }

  const { hash, salt } = hashPin(next);
  await db.providerAuth.update({ where: { id: 1 }, data: { pinHash: hash, pinSalt: salt } });
  redirect("/david/settings?saved=1");
}
KETER_FILE_4_EOF

git add "app/app/my/page.tsx" "app/david/(protected)/requests/[id]/page.tsx" "components/Fields.tsx" "lib/actions/client.ts" "lib/actions/provider.ts"
git commit -m "Add card-tied treatment requests, explicit punch action, and client-side treatment history" --allow-empty
git push
echo DONE

