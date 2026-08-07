import { redirect } from "next/navigation";
import { findService } from "@/lib/services";
import { getCurrentClient } from "@/lib/session";
import { submitBooking } from "@/lib/actions/client";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { TextField, TextAreaField, SubmitButton } from "@/components/Fields";

export default async function BookingPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const service = findService(id);
  if (!service) redirect("/app");
  const client = await getCurrentClient();

  return (
    <ScreenBody padding="60px 20px 24px" center>
      <BackLink href={`/app/service/${service.id}`} />
      <div style={{ font: "700 20px/1.3 var(--serif)", color: "var(--text-strong)", marginBottom: 6 }}>
        פרטים לפנייה
      </div>
      <div
        style={{
          display: "inline-block",
          background: "var(--pill)",
          color: "var(--accent)",
          font: "600 12.5px var(--sans)",
          padding: "6px 12px",
          borderRadius: 20,
          marginBottom: 20,
        }}
      >
        {service.title}
      </div>

      <form action={submitBooking}>
        <input type="hidden" name="serviceId" value={service.id} />
        <TextField label="שם מלא" name="name" defaultValue={client?.name} placeholder="לדוגמה: מיכל כהן" required />
        <TextField label="טלפון נייד" name="phone" defaultValue={client?.phone} placeholder="05X-XXXXXXX" required />
        <TextField label="תאריך מבוקש" name="date" type="date" />
        <TextAreaField label="תיאור קצר / מה מטריד אותך" name="notes" placeholder="כתבו כמה מילים על המצב..." rows={4} />
        <SubmitButton>שליחת פנייה</SubmitButton>
      </form>
    </ScreenBody>
  );
}
