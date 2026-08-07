set -e
cat > app/page.tsx << 'KDAVIDEOF'
import { redirect } from "next/navigation";
import { getCurrentClient } from "@/lib/session";
import { registerClient } from "@/lib/actions/client";
import { Screen, ScreenBody } from "@/components/Screen";
import { TextField, SubmitButton } from "@/components/Fields";

export default async function RegisterPage() {
  const client = await getCurrentClient();
  if (client) redirect("/app");

  return (
    <Screen>
      <ScreenBody padding="32px" center>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/IMG_0867.png"
            alt="כתר דוד"
            style={{ width: 110, height: 110, borderRadius: "50%", objectFit: "cover", marginBottom: 20 }}
          />
          <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)", marginBottom: 26 }}>
            ברוכים הבאים לכתר דויד
          </div>
          <form action={registerClient} style={{ width: "100%", textAlign: "right" }}>
            <TextField label="שם מלא" name="name" placeholder="לדוגמה: מיכל כהן" required />
            <TextField label="טלפון נייד" name="phone" placeholder="05X-XXXXXXX" required />
            <div style={{ marginTop: 6 }}>
              <SubmitButton>הרשמה וכניסה</SubmitButton>
            </div>
          </form>
        </div>
      </ScreenBody>
    </Screen>
  );
}
KDAVIDEOF
cat > app/app/page.tsx << 'KDAVIDEOF'
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
            src="/IMG_0867.png"
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
KDAVIDEOF
cat > app/david/login/page.tsx << 'KDAVIDEOF'
import { redirect } from "next/navigation";
import { isProviderSession } from "@/lib/session";
import { providerLogin } from "@/lib/actions/provider";
import { Screen, ScreenBody } from "@/components/Screen";
import { SubmitButton } from "@/components/Fields";

export default async function DavidLoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const { error } = await searchParams;
  const alreadyIn = await isProviderSession();
  if (alreadyIn) redirect("/david");

  return (
    <Screen>
      <ScreenBody padding="32px" center>
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/IMG_0867.png"
            alt="כתר דוד"
            style={{ width: 90, height: 90, borderRadius: "50%", objectFit: "cover", marginBottom: 20 }}
          />
          <div style={{ font: "700 20px var(--serif)", color: "var(--text-strong)", marginBottom: 10 }}>
            כניסה לניהול
          </div>
          <div style={{ font: "13.5px var(--sans)", color: "var(--text-70)", marginBottom: 24 }}>
            הזן את קוד הגישה שלך
          </div>
          <form action={providerLogin} style={{ width: "100%" }}>
            <input
              name="pin"
              type="password"
              inputMode="numeric"
              autoFocus
              placeholder="קוד גישה"
              style={{
                width: "100%",
                background: "var(--input-bg)",
                border: "1px solid var(--input-border)",
                borderRadius: 12,
                padding: "13px 14px",
                color: "var(--text)",
                font: "18px var(--sans)",
                textAlign: "center",
                letterSpacing: "0.3em",
                marginBottom: error ? 10 : 20,
              }}
            />
            {error && (
              <div style={{ font: "12.5px var(--sans)", color: "oklch(0.7 0.16 25)", marginBottom: 14 }}>
                קוד שגוי, נסה שוב
              </div>
            )}
            <SubmitButton>כניסה</SubmitButton>
          </form>
        </div>
      </ScreenBody>
    </Screen>
  );
}
KDAVIDEOF
git add -A
git commit -m 'Point logo image at existing IMG_0867.png'
git push
echo DONE

