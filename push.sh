set -e
mkdir -p '.'
mkdir -p app/app/booking/\[id\]
mkdir -p app/app/confirmed
mkdir -p app/app
mkdir -p app/app/my
mkdir -p app/app
mkdir -p app/app/service/\[id\]
mkdir -p app/david/\(protected\)/cards
mkdir -p app/david/\(protected\)/clients/\[id\]
mkdir -p app/david/\(protected\)
mkdir -p app/david/\(protected\)
mkdir -p app/david/\(protected\)/requests/\[id\]
mkdir -p app/david/\(protected\)/settings
mkdir -p app/david/login
mkdir -p app
mkdir -p app
mkdir -p app
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p components
mkdir -p lib/actions
mkdir -p lib/actions
mkdir -p lib
mkdir -p lib
mkdir -p lib
mkdir -p lib
mkdir -p prisma/migrations/20260806161053_init
mkdir -p prisma/migrations
mkdir -p prisma
mkdir -p prisma
cat > .env.example << 'KDAVIDEOF'
DATABASE_URL="postgresql://user:password@host:5432/dbname?sslmode=require"
KDAVIDEOF
cat > .gitignore << 'KDAVIDEOF'
# See https://help.github.com/articles/ignoring-files/ for more about ignoring files.

# dependencies
/node_modules
/.pnp
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/versions

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*

# env files (can opt-in for committing if needed)
.env*
!.env.example

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

# database
/prisma/*.db
/prisma/*.db-journal
KDAVIDEOF
cat > AGENTS.md << 'KDAVIDEOF'
<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
KDAVIDEOF
cat > CLAUDE.md << 'KDAVIDEOF'
@AGENTS.md
KDAVIDEOF
cat > DEPLOY.md << 'KDAVIDEOF'
# הרצה ופריסה — כתר דויד

## הרצה מקומית

```
npm install
cp .env.example .env   # ומעדכנים את DATABASE_URL להתחבר ל-Postgres מקומי/מרוחק
npx prisma migrate dev
npx prisma db seed
npm run dev
```

קוד הגישה הראשוני של דויד: `5555` (ניתן להחלפה במסך "הגדרות" בתוך האפליקציה).

## פריסה לאוויר

**1. Postgres בענן (Neon, חינמי, בלי כרטיס אשראי)**
1. neon.tech → הרשמה (אפשר עם GitHub)
2. Create a project
3. להעתיק את ה-Connection string מהדשבורד

**2. GitHub**
1. github.com/new → ליצור ריפו ריק (בלי README, כדי לא להתנגש עם ההיסטוריה הקיימת)
2. `git remote add origin <repo-url>`
3. `git push -u origin main`

**3. Vercel**
1. vercel.com → הרשמה עם GitHub → Import Project → לבחור את הריפו
2. Environment Variables → להוסיף `DATABASE_URL` עם ה-connection string מ-Neon
3. Deploy — סקריפט ה-build (`prisma migrate deploy && next build`) יריץ את המיגרציות אוטומטית על כל דיפלוי

**4. אחרי הפריסה**
- לגלוש ל-`/david/login`, להיכנס עם `5555`, ומיד להחליף קוד במסך "הגדרות"
- לשלוח ללקוחות את קישור האתר (כמו קישור הוואטסאפ שדויד שולח בעיצוב המקורי)
KDAVIDEOF
cat > app/app/booking/\[id\]/page.tsx << 'KDAVIDEOF'
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
KDAVIDEOF
cat > app/app/confirmed/page.tsx << 'KDAVIDEOF'
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
KDAVIDEOF
cat > app/app/layout.tsx << 'KDAVIDEOF'
import { requireClient } from "@/lib/session";
import { Screen } from "@/components/Screen";

export default async function ClientAreaLayout({ children }: { children: React.ReactNode }) {
  await requireClient();
  return <Screen>{children}</Screen>;
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
import { TextField, TextAreaField, SubmitButton } from "@/components/Fields";

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
              <button
                type="submit"
                style={{
                  width: "100%",
                  textAlign: "center",
                  background: "var(--accent)",
                  color: "var(--accent-ink)",
                  borderRadius: 12,
                  padding: 12,
                  font: "700 13.5px var(--sans)",
                  cursor: "pointer",
                }}
              >
                {renewalActionLabel}
              </button>
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
KDAVIDEOF
cat > app/app/service/\[id\]/page.tsx << 'KDAVIDEOF'
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
KDAVIDEOF
cat > app/david/\(protected\)/cards/page.tsx << 'KDAVIDEOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { SearchBox } from "@/components/SearchBox";
import { PunchDots } from "@/components/PunchDots";
import { StatusPill } from "@/components/StatusPill";

export default async function CardsPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();

  const clients = await db.client.findMany({
    include: { card: true },
    orderBy: { name: "asc" },
  });
  const filtered = query ? clients.filter((c) => c.name.includes(query)) : clients;
  const withCards = filtered.filter((c) => c.card);

  const completedCount = clients.filter((c) => c.card && c.card.used >= c.card.total).length;

  return (
    <>
      <div style={{ padding: "22px 20px 8px" }}>
        <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)" }}>כרטיסיות</div>
        <div style={{ font: "13px var(--sans)", color: "var(--text-65)", marginTop: 4 }}>
          {completedCount} כרטיסיות הסתיימו מתוך {clients.length}
        </div>
      </div>
      <div style={{ padding: "12px 20px 0" }}>
        <SearchBox />
      </div>
      <ScreenBody padding="12px 20px 84px">
        {withCards.map((c) => {
          const card = c.card!;
          const completed = card.used >= card.total;
          return (
            <Link
              key={c.id}
              href={`/david/clients/${c.id}`}
              style={{
                display: "block",
                background: "var(--panel)",
                border: "1px solid var(--panel-border)",
                borderRadius: 14,
                padding: "14px 16px",
                marginBottom: 10,
                color: "inherit",
              }}
            >
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 8 }}>
                <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{c.name}</div>
                <StatusPill label={completed ? "הסתיימה" : "פעילה"} variant={completed ? "neutral" : "active"} />
              </div>
              <div style={{ marginBottom: 6 }}>
                <PunchDots total={card.total} used={card.used} size={10} />
              </div>
              <div style={{ font: "12px var(--sans)", color: "var(--text-65)" }}>
                {card.used} מתוך {card.total} ניקובים נוצלו
              </div>
            </Link>
          );
        })}
        {withCards.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)", textAlign: "center", padding: "24px 0" }}>
            אין כרטיסיות להצגה
          </div>
        )}
      </ScreenBody>
      <TabBar
        items={[
          { label: "פניות", href: "/david", active: false },
          { label: "כרטיסיות", href: "/david/cards", active: true },
        ]}
      />
    </>
  );
}
KDAVIDEOF
cat > app/david/\(protected\)/clients/\[id\]/page.tsx << 'KDAVIDEOF'
import { redirect } from "next/navigation";
import Link from "next/link";
import { db } from "@/lib/db";
import { formatHeDate } from "@/lib/format";
import { adjustCardUsed } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { Panel, SectionLabel } from "@/components/Panel";
import { PunchDots } from "@/components/PunchDots";

const PHONE_ICON = (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
    <path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1-9.4 0-17-7.6-17-17 0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.4 0 .8-.2 1L6.6 10.8z" />
  </svg>
);

export default async function ClientDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ editCard?: string }>;
}) {
  const { id } = await params;
  const { editCard } = await searchParams;
  const client = await db.client.findUnique({
    where: { id },
    include: { card: true, history: { orderBy: { date: "desc" } } },
  });
  if (!client || !client.card) redirect("/david/cards");
  const card = client.card;
  const completed = card.used >= card.total;
  const cardEditMode = editCard === "1";

  const byService = new Map<string, number>();
  for (const h of client.history) byService.set(h.service, (byService.get(h.service) ?? 0) + 1);
  const summary = Array.from(byService.entries());

  return (
    <ScreenBody padding="60px 20px 24px">
      <BackLink href="/david/cards" />
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: 16 }}>
        <div style={{ font: "700 20px var(--serif)", color: "var(--text-strong)" }}>{client.name}</div>
        <div
          style={{
            font: "600 11px var(--sans)",
            padding: "4px 10px",
            borderRadius: 20,
            background: "var(--panel-border)",
            color: "var(--accent)",
          }}
        >
          {completed ? "הסתיימה" : "פעילה"}
        </div>
      </div>

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
          {client.phone}
        </div>
      </div>

      <Panel style={{ padding: "14px 16px", marginBottom: 22 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
          <div style={{ font: "600 13px var(--sans)", color: "var(--text)" }}>כרטיסייה</div>
          <Link
            href={cardEditMode ? `/david/clients/${client.id}` : `/david/clients/${client.id}?editCard=1`}
            style={{ font: "600 12px var(--sans)", color: "var(--accent)" }}
          >
            {cardEditMode ? "סיום עריכה" : "תיקון ניקובים"}
          </Link>
        </div>
        <div style={{ marginBottom: 8 }}>
          <PunchDots total={card.total} used={card.used} size={10} />
        </div>
        <div style={{ font: "12px var(--sans)", color: "var(--text-65)" }}>
          {card.used} מתוך {card.total} ניקובים נוצלו
        </div>
        {cardEditMode && (
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginTop: 14 }}>
            <form action={adjustCardUsed}>
              <input type="hidden" name="clientId" value={client.id} />
              <input type="hidden" name="delta" value="-1" />
              <button
                type="submit"
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 9,
                  background: "var(--input-bg)",
                  border: "1px solid var(--input-border)",
                  color: "var(--text)",
                  font: "700 16px var(--sans)",
                  cursor: "pointer",
                }}
              >
                −
              </button>
            </form>
            <div style={{ flex: 1, textAlign: "center", font: "600 14px var(--sans)", color: "var(--text)" }}>
              {card.used} ניקובים
            </div>
            <form action={adjustCardUsed}>
              <input type="hidden" name="clientId" value={client.id} />
              <input type="hidden" name="delta" value="1" />
              <button
                type="submit"
                style={{
                  width: 34,
                  height: 34,
                  borderRadius: 9,
                  background: "var(--accent)",
                  border: "none",
                  color: "var(--accent-ink)",
                  font: "700 16px var(--sans)",
                  cursor: "pointer",
                }}
              >
                +
              </button>
            </form>
          </div>
        )}
      </Panel>

      <div style={{ font: "600 13px var(--sans)", color: "var(--accent)", marginBottom: 10 }}>סיכום טיפולים</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 22 }}>
        {summary.map(([service, count]) => (
          <div
            key={service}
            style={{
              display: "flex",
              justifyContent: "space-between",
              background: "var(--panel)",
              border: "1px solid var(--panel-border)",
              borderRadius: 10,
              padding: "9px 13px",
              font: "13px var(--sans)",
              color: "var(--text-85)",
            }}
          >
            <div>{service}</div>
            <div style={{ color: "var(--accent)", fontWeight: 600 }}>{count}</div>
          </div>
        ))}
        {summary.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)" }}>אין עדיין טיפולים שהושלמו</div>
        )}
      </div>

      <SectionLabel>היסטוריית טיפולים</SectionLabel>
      {client.history.map((h) => (
        <div
          key={h.id}
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            padding: "10px 2px",
            borderBottom: "1px solid var(--panel-border)",
          }}
        >
          <div style={{ font: "13.5px var(--sans)", color: "var(--text-90)" }}>{h.service}</div>
          <div style={{ font: "12px var(--sans)", color: "var(--text-60)" }}>{formatHeDate(h.date)}</div>
        </div>
      ))}
    </ScreenBody>
  );
}
KDAVIDEOF
cat > app/david/\(protected\)/layout.tsx << 'KDAVIDEOF'
import { requireProvider } from "@/lib/session";
import { Screen } from "@/components/Screen";

export default async function DavidProtectedLayout({ children }: { children: React.ReactNode }) {
  await requireProvider();
  return <Screen>{children}</Screen>;
}
KDAVIDEOF

cat > app/david/\(protected\)/page.tsx << 'KDAVIDEOF'
import Link from "next/link";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatRelative } from "@/lib/format";
import { ScreenBody } from "@/components/Screen";
import { TabBar } from "@/components/TabBar";
import { SearchBox } from "@/components/SearchBox";

const GROUP_ORDER = ["new", "scheduled", "done"];

export default async function InboxPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? "").trim();

  const allRequests = await db.appointment.findMany({
    include: { client: true },
    orderBy: { createdAt: "desc" },
  });
  const filtered = query ? allRequests.filter((r) => r.client.name.includes(query)) : allRequests;

  const newCount = allRequests.filter((r) => r.status === "new").length;

  const groups = GROUP_ORDER.map((status) => ({
    status,
    label: statusMeta[status]?.label ?? status,
    items: filtered.filter((r) => r.status === status),
  })).filter((g) => g.items.length > 0);

  return (
    <>
      <div style={{ padding: "22px 20px 8px", display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div>
          <div style={{ font: "700 22px var(--serif)", color: "var(--text-strong)" }}>שלום דויד</div>
          <div style={{ font: "13px var(--sans)", color: "var(--text-65)", marginTop: 4 }}>
            {newCount} פניות חדשות ממתינות
          </div>
        </div>
        <Link href="/david/settings" style={{ font: "600 12.5px var(--sans)", color: "var(--accent)", padding: "4px 0" }}>
          הגדרות
        </Link>
      </div>
      <div style={{ padding: "12px 20px 0" }}>
        <SearchBox />
      </div>
      <ScreenBody padding="12px 20px 84px">
        {groups.map((grp) => (
          <div key={grp.status}>
            <div style={{ font: "600 12px var(--sans)", color: "var(--accent)", letterSpacing: ".03em", margin: "14px 2px 8px" }}>
              {grp.label}
            </div>
            {grp.items.map((req) => (
              <Link
                key={req.id}
                href={`/david/requests/${req.id}`}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  background: "var(--panel)",
                  border: "1px solid var(--panel-border)",
                  borderRadius: 14,
                  padding: "13px 15px",
                  marginBottom: 9,
                  color: "inherit",
                }}
              >
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ font: "600 14px var(--sans)", color: "var(--text)" }}>{req.client.name}</div>
                  <div style={{ font: "12px var(--sans)", color: "var(--text-65)", marginTop: 2 }}>{req.serviceTitle}</div>
                </div>
                <div style={{ flex: "none", font: "11px var(--sans)", color: "var(--text-60)" }}>
                  {formatRelative(req.createdAt)}
                </div>
              </Link>
            ))}
          </div>
        ))}
        {groups.length === 0 && (
          <div style={{ font: "13px var(--sans)", color: "var(--text-60)", textAlign: "center", padding: "24px 0" }}>
            אין פניות להצגה
          </div>
        )}
      </ScreenBody>
      <TabBar
        items={[
          { label: "פניות", href: "/david", active: true },
          { label: "כרטיסיות", href: "/david/cards", active: false },
        ]}
      />
    </>
  );
}
KDAVIDEOF
cat > app/david/\(protected\)/requests/\[id\]/page.tsx << 'KDAVIDEOF'
import { redirect } from "next/navigation";
import { db } from "@/lib/db";
import { statusMeta } from "@/lib/services";
import { formatHeDate } from "@/lib/format";
import { setRequestStatus } from "@/lib/actions/provider";
import { BackLink } from "@/components/BackLink";
import { ScreenBody } from "@/components/Screen";
import { StatusPill } from "@/components/StatusPill";

const PHONE_ICON = (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
    <path d="M6.6 10.8c1.4 2.8 3.8 5.1 6.6 6.6l2.2-2.2c.3-.3.7-.4 1-.2 1.1.4 2.3.6 3.6.6.6 0 1 .4 1 1V20c0 .6-.4 1-1 1-9.4 0-17-7.6-17-17 0-.6.4-1 1-1h3.4c.6 0 1 .4 1 1 0 1.3.2 2.5.6 3.6.1.4 0 .8-.2 1L6.6 10.8z" />
  </svg>
);

export default async function RequestDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const request = await db.appointment.findUnique({ where: { id }, include: { client: true } });
  if (!request) redirect("/david");

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
        {(["new", "scheduled", "done"] as const).map((st) => (
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
    </ScreenBody>
  );
}
KDAVIDEOF
cat > app/david/\(protected\)/settings/page.tsx << 'KDAVIDEOF'
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
            src="/keter-david-logo.png"
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
cat > app/globals.css << 'KDAVIDEOF'
:root {
  --navy: #0d1b3f;
  --navy-deep: #081430;
  --panel: #16295c;
  --panel-border: #23386b;
  --pill: #1c3468;
  --input-bg: #142757;
  --input-border: #2c4278;
  --accent: #d4af37;
  --accent-ink: oklch(0.16 0.02 260);

  --text: oklch(0.95 0.01 260);
  --text-strong: oklch(0.96 0.01 260);
  --text-90: oklch(0.9 0.01 260);
  --text-85: oklch(0.85 0.01 260);
  --text-82: oklch(0.82 0.02 260);
  --text-80: oklch(0.8 0.02 260);
  --text-78: oklch(0.78 0.02 260);
  --text-75: oklch(0.75 0.02 260);
  --text-70: oklch(0.7 0.02 260);
  --text-65: oklch(0.65 0.02 260);
  --text-60: oklch(0.6 0.02 260);
  --text-55: oklch(0.55 0.02 260);

  --serif: var(--font-frank), "Frank Ruhl Libre", serif;
  --sans: var(--font-assistant), "Assistant", sans-serif;

  --green-bg: oklch(0.28 0.05 145);
  --green-text: oklch(0.85 0.1 145);
}

* {
  box-sizing: border-box;
}

html,
body {
  margin: 0;
  padding: 0;
  background: var(--navy);
  color: var(--text);
  font-family: var(--sans);
  -webkit-font-smoothing: antialiased;
  min-height: 100%;
}

a {
  color: var(--accent);
  text-decoration: none;
}
a:hover {
  filter: brightness(1.1);
}

input,
textarea {
  font-family: var(--sans);
  outline: none;
}
input::placeholder,
textarea::placeholder {
  color: oklch(0.6 0.02 260);
}

button {
  font-family: var(--sans);
  border: none;
  background: none;
  cursor: pointer;
  color: inherit;
}

input[type="date"] {
  color-scheme: dark;
}
KDAVIDEOF
cat > app/layout.tsx << 'KDAVIDEOF'
import type { Metadata } from "next";
import { Frank_Ruhl_Libre, Assistant } from "next/font/google";
import "./globals.css";

const frankRuhl = Frank_Ruhl_Libre({
  subsets: ["hebrew", "latin"],
  weight: ["400", "500", "700"],
  variable: "--font-frank",
  display: "swap",
});

const assistant = Assistant({
  subsets: ["hebrew", "latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-assistant",
  display: "swap",
});

export const metadata: Metadata = {
  title: "כתר דויד",
  description: "הגנה וטיהור אנרגטי אישי — כתר דויד",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="he" dir="rtl" className={`${frankRuhl.variable} ${assistant.variable}`}>
      <body>{children}</body>
    </html>
  );
}
KDAVIDEOF
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
KDAVIDEOF

cat > components/BackLink.tsx << 'KDAVIDEOF'
import Link from "next/link";

const style: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  gap: 8,
  color: "var(--accent)",
  font: "600 15px var(--sans)",
  marginBottom: 20,
  cursor: "pointer",
  padding: "6px 4px",
};

export function BackLink({
  href,
  onClick,
  label = "חזרה",
}: {
  href?: string;
  onClick?: () => void;
  label?: string;
}) {
  if (href) {
    return (
      <Link href={href} style={style}>
        ‹ {label}
      </Link>
    );
  }
  return (
    <button type="button" onClick={onClick} style={style}>
      ‹ {label}
    </button>
  );
}
KDAVIDEOF
cat > components/Fields.tsx << 'KDAVIDEOF'
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
  return (
    <button
      type="submit"
      disabled={disabled}
      style={{
        width: "100%",
        textAlign: "center",
        borderRadius: 14,
        padding: 15,
        font: "700 15px var(--sans)",
        cursor: disabled ? "not-allowed" : "pointer",
        background: disabled ? "oklch(0.3 0.03 260)" : "var(--accent)",
        color: disabled ? "var(--text-55)" : "var(--accent-ink)",
      }}
    >
      {children}
    </button>
  );
}
KDAVIDEOF
cat > components/Panel.tsx << 'KDAVIDEOF'
export function Panel({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        background: "var(--panel)",
        border: "1px solid var(--panel-border)",
        borderRadius: 14,
        padding: "14px 16px",
        marginBottom: 14,
        ...style,
      }}
    >
      {children}
    </div>
  );
}

export function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <div
      style={{
        font: "600 13px var(--sans)",
        color: "var(--text-75)",
        letterSpacing: ".03em",
        margin: "14px 4px 12px",
      }}
    >
      {children}
    </div>
  );
}
KDAVIDEOF
cat > components/PunchDots.tsx << 'KDAVIDEOF'
export function PunchDots({ total, used, size = 16 }: { total: number; used: number; size?: number }) {
  return (
    <div style={{ display: "flex", gap: size >= 14 ? 6 : 5, flexWrap: "wrap" }}>
      {Array.from({ length: total }).map((_, i) => {
        const filled = i < used;
        return (
          <div
            key={i}
            style={{
              width: size,
              height: size,
              borderRadius: "50%",
              background: filled ? "var(--accent)" : "oklch(0.32 0.03 260)",
              border: `1px solid ${filled ? "var(--accent)" : "oklch(0.4 0.03 260)"}`,
            }}
          />
        );
      })}
    </div>
  );
}
KDAVIDEOF
cat > components/Screen.tsx << 'KDAVIDEOF'
export function Screen({ children }: { children: React.ReactNode }) {
  return (
    <div
      style={{
        height: "100dvh",
        maxWidth: 480,
        margin: "0 auto",
        display: "flex",
        flexDirection: "column",
        background: "var(--navy)",
        color: "var(--text)",
        overflow: "hidden",
      }}
    >
      {children}
    </div>
  );
}

export function ScreenBody({
  children,
  padding = "60px 20px 24px",
  center = false,
}: {
  children: React.ReactNode;
  padding?: string;
  center?: boolean;
}) {
  return (
    <div
      style={{
        flex: 1,
        overflowY: "auto",
        padding,
        display: "flex",
        flexDirection: "column",
        ...(center ? { justifyContent: "center" } : {}),
      }}
    >
      {children}
    </div>
  );
}
KDAVIDEOF
cat > components/SearchBox.tsx << 'KDAVIDEOF'
"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useEffect, useRef, useState } from "react";

export function SearchBox({ placeholder = "חיפוש לפי שם..." }: { placeholder?: string }) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [value, setValue] = useState(searchParams.get("q") ?? "");
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      const params = new URLSearchParams(searchParams.toString());
      if (value) params.set("q", value);
      else params.delete("q");
      router.replace(`${pathname}?${params.toString()}`);
    }, 200);
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value]);

  return (
    <input
      value={value}
      onChange={(e) => setValue(e.target.value)}
      placeholder={placeholder}
      style={{
        width: "100%",
        background: "var(--input-bg)",
        border: "1px solid var(--input-border)",
        borderRadius: 12,
        padding: "11px 14px",
        color: "var(--text)",
        font: "13.5px var(--sans)",
      }}
    />
  );
}
KDAVIDEOF
cat > components/StatusPill.tsx << 'KDAVIDEOF'
type Variant = "neutral" | "active" | "selected" | "unselected";

const VARIANT_STYLE: Record<Variant, React.CSSProperties> = {
  neutral: { background: "var(--panel-border)", color: "var(--accent)" },
  active: { background: "var(--green-bg)", color: "var(--green-text)" },
  selected: { background: "var(--accent)", color: "var(--accent-ink)", border: "1px solid var(--accent)" },
  unselected: { background: "var(--input-bg)", color: "var(--text-85)", border: "1px solid var(--input-border)" },
};

export function StatusPill({
  label,
  variant = "neutral",
  submit,
}: {
  label: string;
  variant?: Variant;
  /** Render as a form-submit button (for use inside a <form action=...>) instead of a plain display pill. */
  submit?: boolean;
}) {
  const style: React.CSSProperties = {
    display: "inline-block",
    font: "600 11px var(--sans)",
    padding: "4px 10px",
    borderRadius: 20,
    ...VARIANT_STYLE[variant],
  };
  if (submit) {
    return (
      <button
        type="submit"
        style={{ ...style, font: "600 12.5px var(--sans)", padding: "9px 16px", cursor: "pointer" }}
      >
        {label}
      </button>
    );
  }
  return <span style={style}>{label}</span>;
}
KDAVIDEOF

cat > components/TabBar.tsx << 'KDAVIDEOF'
import Link from "next/link";

export function TabBar({ items }: { items: { label: string; href: string; active: boolean }[] }) {
  return (
    <div
      style={{
        display: "flex",
        background: "var(--navy-deep)",
        borderTop: "1px solid var(--panel-border)",
        padding: "10px 20px 14px",
      }}
    >
      {items.map((it) => (
        <Link
          key={it.href}
          href={it.href}
          style={{
            flex: 1,
            textAlign: "center",
            padding: 9,
            borderRadius: 10,
            font: "600 13px var(--sans)",
            color: it.active ? "var(--accent)" : "var(--text-60)",
          }}
        >
          {it.label}
        </Link>
      ))}
    </div>
  );
}
KDAVIDEOF
cat > lib/actions/client.ts << 'KDAVIDEOF'
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
KDAVIDEOF
cat > lib/actions/provider.ts << 'KDAVIDEOF'
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

  if (status === "done") {
    if (appt.kind === "booking" && appt.serviceTitle) {
      await db.historyEntry.create({
        data: {
          clientId: appt.clientId,
          service: appt.serviceTitle,
          date: appt.requestedDate ? new Date(appt.requestedDate) : new Date(),
        },
      });
    }
    if (appt.kind === "card_new" || appt.kind === "card_renewal") {
      await db.punchCard.update({
        where: { clientId: appt.clientId },
        data: { renewalRequested: false },
      });
    }
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
KDAVIDEOF
cat > lib/db.ts << 'KDAVIDEOF'
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = db;
KDAVIDEOF
cat > lib/format.ts << 'KDAVIDEOF'
export function formatHeDate(value: string | Date | null | undefined): string {
  if (!value) return "לא צוין";
  const d = typeof value === "string" ? new Date(value) : value;
  if (isNaN(d.getTime())) return "לא צוין";
  return d.toLocaleDateString("he-IL");
}

export function formatRelative(date: Date): string {
  const now = new Date();
  const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const diffDays = Math.round(
    (startOfDay(now).getTime() - startOfDay(date).getTime()) / 86400000
  );
  if (diffDays <= 0) return "היום";
  if (diffDays === 1) return "אתמול";
  return `לפני ${diffDays} ימים`;
}
KDAVIDEOF
cat > lib/services.ts << 'KDAVIDEOF'
export type Service = {
  id: string;
  title: string;
  tagline: string;
  desc: string;
  included: string[];
};

export const services: Service[] = [
  {
    id: "ayin",
    title: "הסרת עין הרע",
    tagline: "הגנה וטיהור אנרגטי אישי",
    desc: "עין הרע היא אנרגיה שלילית שעוברת מאדם לאדם, מכוונת או לא, ומשפיעה על מצב הרוח, השינה והמזל. הטיפול מזהה את המקור ומסיר את ההשפעה מהגוף ומהבית.",
    included: ["אבחון אנרגטי", "הסרת ההשפעה", "הגנה למניעה חוזרת"],
  },
  {
    id: "spell",
    title: "הסרת כישופים",
    tagline: "איתור והסרה של כישוף",
    desc: "טיפול לאיתור והסרה של כישוף שהוטל, כולל בדיקה של מוצא ההשפעה והדרך שבה נכנסה לחיים.",
    included: ["איתור מקור הכישוף", "הסרה מהגוף והבית", "חיזוק הגנה אישית"],
  },
  {
    id: "home",
    title: "טיהור הבית / העסק",
    tagline: "ניקוי אנרגטי למרחב",
    desc: "ניקוי אנרגטי למרחב המגורים או העסק, מסיר שאריות אנרגטיות ומחזיר תחושת קלילות וזרימה.",
    included: ["סקירת המרחב", "ניקוי פינה פינה", "המלצות לשימור הטיהור"],
  },
  {
    id: "balance",
    title: "איזון אנרגטי",
    tagline: "איזון שדה האנרגיה האישי",
    desc: "טיפול לאיזון שדה האנרגיה האישי, מתאים למי שמרגיש עייפות, חוסר מיקוד או תחושת כובד מתמשכת.",
    included: ["מיפוי אנרגטי", "איזון מרכזי אנרגיה", "תרגיל המשך לבית"],
  },
  {
    id: "blocks",
    title: "הסרת חסמות ותיקונים",
    tagline: "הסרת חסמים חוזרים",
    desc: "לפעמים מכשולים חוזרים בעבודה, בזוגיות או בכלכלה מקורם בחסם אנרגטי. הטיפול מזהה את החסם ופועל להסרתו.",
    included: ["איתור החסם", "טיפול ממוקד", "בדיקת מעקב"],
  },
  {
    id: "anxiety",
    title: "טיפול בחרדות",
    tagline: "ליווי אנרגטי לחרדה ולחץ",
    desc: "ליווי אנרגטי לתחושות חרדה, לחץ ומתח מתמשך, בשילוב טכניקות הרגעה והגנה.",
    included: ["שיחת פתיחה", "טיפול הרגעה", "כלים להתמודדות יומיומית"],
  },
];

export function findService(id: string | null | undefined): Service | null {
  if (!id) return null;
  return services.find((s) => s.id === id) ?? null;
}

export const statusMeta: Record<string, { label: string }> = {
  new: { label: "חדש" },
  scheduled: { label: "מתוזמן" },
  done: { label: "הושלם" },
};
KDAVIDEOF
cat > lib/session.ts << 'KDAVIDEOF'
import { cookies } from "next/headers";
import { randomBytes, scryptSync, timingSafeEqual } from "crypto";
import { redirect } from "next/navigation";
import { db } from "./db";

const COOKIE_NAME = "kd_session";
const SESSION_DAYS = 180;

export function hashPin(pin: string) {
  const salt = randomBytes(16).toString("hex");
  const hash = scryptSync(pin, salt, 64).toString("hex");
  return { hash, salt };
}

export function verifyPin(pin: string, hash: string, salt: string) {
  const candidate = scryptSync(pin, salt, 64);
  const stored = Buffer.from(hash, "hex");
  if (candidate.length !== stored.length) return false;
  return timingSafeEqual(candidate, stored);
}

async function setSessionCookie(sessionId: string) {
  const store = await cookies();
  store.set(COOKIE_NAME, sessionId, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: SESSION_DAYS * 24 * 60 * 60,
  });
}

export async function createClientSession(clientId: string) {
  const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  const session = await db.session.create({
    data: { clientId, isProvider: false, expiresAt },
  });
  await setSessionCookie(session.id);
}

export async function createProviderSession() {
  const expiresAt = new Date(Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000);
  const session = await db.session.create({
    data: { isProvider: true, expiresAt },
  });
  await setSessionCookie(session.id);
}

async function getSession() {
  const store = await cookies();
  const sessionId = store.get(COOKIE_NAME)?.value;
  if (!sessionId) return null;
  const session = await db.session.findUnique({ where: { id: sessionId } });
  if (!session || session.expiresAt < new Date()) return null;
  return session;
}

export async function getCurrentClient() {
  const session = await getSession();
  if (!session || !session.clientId) return null;
  return db.client.findUnique({
    where: { id: session.clientId },
    include: { card: true },
  });
}

export async function isProviderSession() {
  const session = await getSession();
  return !!session?.isProvider;
}

export async function requireClient() {
  const client = await getCurrentClient();
  if (!client) redirect("/");
  return client;
}

export async function requireProvider() {
  const ok = await isProviderSession();
  if (!ok) redirect("/david/login");
}
KDAVIDEOF

cat > next.config.ts << 'KDAVIDEOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
};

export default nextConfig;
KDAVIDEOF
cat > package.json << 'KDAVIDEOF'
{
  "name": "keter-david-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "prisma migrate deploy && next build",
    "start": "next start",
    "postinstall": "prisma generate",
    "db:migrate": "prisma migrate dev",
    "db:seed": "tsx prisma/seed.ts"
  },
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  },
  "dependencies": {
    "@prisma/client": "^6.3.1",
    "next": "16.3.0",
    "react": "19.2.8",
    "react-dom": "19.2.8"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "prisma": "^6.3.1",
    "tsx": "^4.19.2",
    "typescript": "^5"
  }
}
KDAVIDEOF
cat > prisma/migrations/20260806161053_init/migration.sql << 'KDAVIDEOF'
-- CreateTable
CREATE TABLE "Client" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PunchCard" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "total" INTEGER NOT NULL DEFAULT 10,
    "used" INTEGER NOT NULL DEFAULT 0,
    "renewalRequested" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "PunchCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Appointment" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "serviceId" TEXT,
    "serviceTitle" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "notes" TEXT NOT NULL,
    "requestedDate" TEXT,
    "status" TEXT NOT NULL DEFAULT 'new',
    "kind" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Appointment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HistoryEntry" (
    "id" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "service" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "HistoryEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProviderAuth" (
    "id" INTEGER NOT NULL DEFAULT 1,
    "pinHash" TEXT NOT NULL,
    "pinSalt" TEXT NOT NULL,

    CONSTRAINT "ProviderAuth_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "clientId" TEXT,
    "isProvider" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Client_phone_key" ON "Client"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "PunchCard_clientId_key" ON "PunchCard"("clientId");

-- AddForeignKey
ALTER TABLE "PunchCard" ADD CONSTRAINT "PunchCard_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Appointment" ADD CONSTRAINT "Appointment_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HistoryEntry" ADD CONSTRAINT "HistoryEntry_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "Client"("id") ON DELETE SET NULL ON UPDATE CASCADE;
KDAVIDEOF
cat > prisma/migrations/migration_lock.toml << 'KDAVIDEOF'
# Please do not edit this file manually
# It should be added in your version-control system (e.g., Git)
provider = "postgresql"
KDAVIDEOF
cat > prisma/schema.prisma << 'KDAVIDEOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model Client {
  id        String   @id @default(cuid())
  name      String
  phone     String   @unique
  createdAt DateTime @default(now())

  card         PunchCard?
  appointments Appointment[]
  history      HistoryEntry[]
  sessions     Session[]
}

model PunchCard {
  id               String  @id @default(cuid())
  clientId         String  @unique
  client           Client  @relation(fields: [clientId], references: [id])
  total            Int     @default(10)
  used             Int     @default(0)
  renewalRequested Boolean @default(false)
}

model Appointment {
  id            String   @id @default(cuid())
  clientId      String
  client        Client   @relation(fields: [clientId], references: [id])
  serviceId     String?
  serviceTitle  String
  phone         String
  notes         String
  requestedDate String?
  status        String   @default("new") // new | scheduled | done
  kind          String // booking | card_new | card_renewal
  createdAt     DateTime @default(now())
}

model HistoryEntry {
  id       String   @id @default(cuid())
  clientId String
  client   Client   @relation(fields: [clientId], references: [id])
  service  String
  date     DateTime
}

model ProviderAuth {
  id      Int    @id @default(1)
  pinHash String
  pinSalt String
}

model Session {
  id         String   @id @default(cuid())
  clientId   String?
  client     Client?  @relation(fields: [clientId], references: [id])
  isProvider Boolean  @default(false)
  expiresAt  DateTime
}
KDAVIDEOF
cat > prisma/seed.ts << 'KDAVIDEOF'
import { PrismaClient } from "@prisma/client";
import { hashPin } from "../lib/session";

const db = new PrismaClient();

const DEFAULT_PIN = "5555";

async function main() {
  await db.session.deleteMany();
  await db.appointment.deleteMany();
  await db.historyEntry.deleteMany();
  await db.punchCard.deleteMany();
  await db.client.deleteMany();
  await db.providerAuth.deleteMany();

  const { hash, salt } = hashPin(DEFAULT_PIN);
  await db.providerAuth.create({ data: { id: 1, pinHash: hash, pinSalt: salt } });

  const sarah = await db.client.create({
    data: {
      name: "שרה לוי",
      phone: "0521234567",
      card: { create: { total: 10, used: 10 } },
      history: {
        create: [
          { service: "הסרת עין הרע", date: new Date("2026-05-03") },
          { service: "הסרת עין הרע", date: new Date("2026-05-17") },
          { service: "איזון אנרגטי", date: new Date("2026-06-01") },
          { service: "הסרת עין הרע", date: new Date("2026-06-14") },
          { service: "טיהור הבית / העסק", date: new Date("2026-06-28") },
          { service: "הסרת עין הרע", date: new Date("2026-07-05") },
          { service: "הסרת עין הרע", date: new Date("2026-07-12") },
          { service: "איזון אנרגטי", date: new Date("2026-07-19") },
          { service: "הסרת עין הרע", date: new Date("2026-07-26") },
          { service: "הסרת עין הרע", date: new Date("2026-08-02") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "ayin",
            serviceTitle: "הסרת עין הרע",
            phone: "0521234567",
            notes: "מרגישה עייפות מוזרה ומזל רע שבוע האחרון.",
            requestedDate: "2026-08-10",
            status: "new",
            kind: "booking",
          },
        ],
      },
    },
  });

  const yossi = await db.client.create({
    data: {
      name: "יוסי אברהם",
      phone: "0537654321",
      card: { create: { total: 10, used: 6 } },
      history: {
        create: [
          { service: "טיהור הבית / העסק", date: new Date("2026-06-02") },
          { service: "טיהור הבית / העסק", date: new Date("2026-06-16") },
          { service: "הסרת חסמות ותיקונים", date: new Date("2026-06-30") },
          { service: "טיהור הבית / העסק", date: new Date("2026-07-14") },
          { service: "איזון אנרגטי", date: new Date("2026-07-28") },
          { service: "טיהור הבית / העסק", date: new Date("2026-08-04") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "home",
            serviceTitle: "טיהור הבית / העסק",
            phone: "0537654321",
            notes: "עברנו דירה חדשה ומרגישים תחושה כבדה בבית.",
            requestedDate: "2026-08-09",
            status: "scheduled",
            kind: "booking",
          },
        ],
      },
    },
  });

  const ronit = await db.client.create({
    data: {
      name: "רונית ברק",
      phone: "0541122334",
      card: { create: { total: 5, used: 2 } },
      history: {
        create: [
          { service: "איזון אנרגטי", date: new Date("2026-07-10") },
          { service: "איזון אנרגטי", date: new Date("2026-07-24") },
        ],
      },
      appointments: {
        create: [
          {
            serviceId: "balance",
            serviceTitle: "איזון אנרגטי",
            phone: "0541122334",
            notes: "חוסר ריכוז ותחושת כובד מתמשכת כבר חודש.",
            requestedDate: "2026-08-03",
            status: "done",
            kind: "booking",
          },
        ],
      },
    },
  });

  const michal = await db.client.create({
    data: {
      name: "מיכל כהן",
      phone: "0529365970",
      card: { create: { total: 10, used: 4 } },
      history: {
        create: [
          { service: "הסרת כישופים", date: new Date("2026-06-20") },
          { service: "הסרת כישופים", date: new Date("2026-07-01") },
          { service: "טיפול בחרדות", date: new Date("2026-07-15") },
          { service: "הסרת כישופים", date: new Date("2026-07-29") },
        ],
      },
    },
  });

  console.log("Seeded clients:", [sarah.name, yossi.name, ronit.name, michal.name]);
  console.log("David's PIN:", DEFAULT_PIN);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => db.$disconnect());
KDAVIDEOF
cat > tsconfig.json << 'KDAVIDEOF'
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts",
    "**/*.mts"
  ],
  "exclude": ["node_modules"]
}
KDAVIDEOF
git add -A
git commit -m 'Implement Keter David app'
git push
echo DONE



