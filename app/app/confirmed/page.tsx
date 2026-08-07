import Link from "next/link";
import { ScreenBody } from "@/components/Screen";

export default function ConfirmedPage() {
  return (
    <ScreenBody padding="32px" center>
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div
          style={{
            width: 64,
            height: 64,
            borderRadius: "50%",
            background:
              "radial-gradient(circle at 50% 45%, var(--accent) 0%, var(--accent) 30%, var(--panel-border) 31%, var(--panel-border) 62%, transparent 63%)",
            marginBottom: 22,
          }}
        />
        <div style={{ font: "700 21px var(--serif)", color: "var(--text-strong)", marginBottom: 10 }}>
          הפנייה התקבלה
        </div>
        <p style={{ font: "14px/1.7 var(--sans)", color: "var(--text-78)", margin: "0 0 26px", maxWidth: 280 }}>
          דויד יחזור אליך בהקדם, בדרך כלל בתוך יום עסקים.
        </p>
        <Link href="/app" style={{ color: "var(--accent)", font: "600 13.5px var(--sans)" }}>
          חזרה לעמוד הבית
        </Link>
      </div>
    </ScreenBody>
  );
}
