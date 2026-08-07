import Link from "next/link";
import { getCurrentClient } from "@/lib/session";
import { services } from "@/lib/services";
import { TabBar } from "@/components/TabBar";
import { ScreenBody } from "@/components/Screen";

export default async function HomePage() {
  const client = await getCurrentClient();
  const card = client?.card;

  return (
    <>
      <ScreenBody padding="0 0 84px" center={false}>
        <div style={{ position: "relative", padding: "32px 20px 22px", textAlign: "center" }}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/keter-david-logo.png"
            alt="כתר דוד"
            style={{ width: 64, height: 64, borderRadius: "50%", objectFit: "cover", marginBottom: 12 }}
          />
          <div style={{ font: "700 26px/1.2 var(--serif)", color: "var(--accent)", marginBottom: 6 }}>
            כתר דויד
          </div>
          <div style={{ font: "14px/1.5 var(--sans)", color: "var(--text-80)" }}>
            הגנה וטיהור אנרגטי אישי
          </div>
        </div>

        <div style={{ padding: "4px 20px 0" }}>
          <div style={{ font: "600 13px var(--sans)", color: "var(--text-75)", letterSpacing: ".03em", margin: "14px 4px 12px" }}>
            השירותים שלנו
          </div>

          <Link
            href="/app/my"
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              gap: 14,
              background: "var(--panel)",
              border: "1px solid var(--panel-border)",
              borderRadius: 14,
              padding: "14px 16px",
              marginBottom: 14,
              color: "inherit",
            }}
          >
            <div>
              <div style={{ font: "600 14px var(--sans)", color: "var(--text)", marginBottom: 3 }}>
                כרטיסיית 10 טיפולים
              </div>
              <div style={{ font: "12.5px var(--sans)", color: "var(--accent)" }}>
                {card ? `${card.used}/${card.total} ניקובים` : "0/10 ניקובים"}
              </div>
            </div>
            <div style={{ flex: "none", font: "18px var(--sans)", color: "var(--text-55)" }}>‹</div>
          </Link>

          {services.map((svc) => (
            <Link
              key={svc.id}
              href={`/app/service/${svc.id}`}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 14,
                background: "var(--panel)",
                border: "1px solid var(--panel-border)",
                borderRadius: 14,
                padding: "14px 16px",
                marginBottom: 10,
                color: "inherit",
              }}
            >
              <div
                style={{
                  flex: "none",
                  width: 40,
                  height: 40,
                  borderRadius: "50%",
                  background:
                    "radial-gradient(circle at 50% 45%, var(--accent) 0%, var(--accent) 22%, var(--panel-border) 23%, var(--panel-border) 55%, transparent 56%)",
                  border: "1px solid var(--input-border)",
                }}
              />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: "600 15px var(--serif)", color: "var(--text-strong)" }}>{svc.title}</div>
                <div
                  style={{
                    font: "12.5px/1.4 var(--sans)",
                    color: "var(--text-65)",
                    marginTop: 2,
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                    whiteSpace: "nowrap",
                  }}
                >
                  {svc.tagline}
                </div>
              </div>
              <div style={{ flex: "none", font: "18px var(--sans)", color: "var(--text-55)" }}>‹</div>
            </Link>
          ))}
        </div>
      </ScreenBody>
      <TabBar
        items={[
          { label: "שירותים", href: "/app", active: true },
          { label: "שלי", href: "/app/my", active: false },
        ]}
      />
    </>
  );
}
