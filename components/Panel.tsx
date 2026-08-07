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
