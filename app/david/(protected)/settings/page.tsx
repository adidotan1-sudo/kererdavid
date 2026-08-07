import { changePin } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { TextField, SubmitButton } from "@/components/Fields";

const ERROR_MESSAGES: Record<string, string> = {
  wrong: "קוד הגישה הנוכחי שגוי",
  invalid: "הקוד החדש חייב להיות לפחות 4 ספרות, ולהיות זהה באימות",
};

export default async function SettingsPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; saved?: string }>;
}) {
  const { error, saved } = await searchParams;

  return (
    <ScreenBody padding="60px 20px 24px" center>
      <BackLink href="/david" />
      <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)", marginBottom: 20 }}>
        הגדרות
      </div>

      <div style={{ font: "600 13px var(--sans)", color: "var(--text-75)", marginBottom: 14 }}>
        החלפת קוד גישה
      </div>

      {saved === "1" && (
        <div style={{ font: "13px var(--sans)", color: "oklch(0.85 0.1 145)", marginBottom: 14 }}>
          הקוד עודכן בהצלחה
        </div>
      )}
      {error && (
        <div style={{ font: "13px var(--sans)", color: "oklch(0.7 0.16 25)", marginBottom: 14 }}>
          {ERROR_MESSAGES[error] ?? "אירעה שגיאה"}
        </div>
      )}

      <form action={changePin}>
        <TextField label="קוד גישה נוכחי" name="current" type="password" required />
        <TextField label="קוד גישה חדש" name="next" type="password" required />
        <TextField label="אימות קוד גישה חדש" name="confirm" type="password" required />
        <SubmitButton>שמירת קוד חדש</SubmitButton>
      </form>
    </ScreenBody>
  );
}
