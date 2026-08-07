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
