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
