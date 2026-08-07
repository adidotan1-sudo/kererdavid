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
