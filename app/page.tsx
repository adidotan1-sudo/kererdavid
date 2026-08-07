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
            src="/keter-david-logo.png"
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
