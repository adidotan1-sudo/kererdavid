import { redirect } from "next/navigation";
import Link from "next/link";
import { findService } from "@/lib/services";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";

export default async function ServiceDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const service = findService(id);
  if (!service) redirect("/app");

  return (
    <ScreenBody padding="60px 20px 24px" center>
      <BackLink href="/app" />
      <div style={{ font: "700 22px/1.3 var(--serif)", color: "var(--text-strong)", marginBottom: 14 }}>
        {service.title}
      </div>
      <p style={{ font: "14px/1.8 var(--sans)", color: "var(--text-82)", margin: "0 0 20px" }}>{service.desc}</p>
      <div style={{ font: "600 13px var(--sans)", color: "var(--accent)", marginBottom: 10 }}>מה כלול בטיפול</div>
      {service.included.map((item, i) => (
        <div key={i} style={{ display: "flex", gap: 10, alignItems: "flex-start", marginBottom: 10 }}>
          <div
            style={{
              flex: "none",
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: "var(--accent)",
              marginTop: 7,
            }}
          />
          <div style={{ font: "13.5px/1.6 var(--sans)", color: "var(--text-78)" }}>{item}</div>
        </div>
      ))}
      <Link
        href={`/app/booking/${service.id}`}
        style={{
          marginTop: 24,
          background: "var(--accent)",
          color: "var(--accent-ink)",
          textAlign: "center",
          borderRadius: 14,
          padding: 15,
          font: "700 15px var(--sans)",
          display: "block",
        }}
      >
        קביעת פנייה
      </Link>
    </ScreenBody>
  );
}
