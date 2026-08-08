type Variant = "neutral" | "active" | "selected" | "unselected" | "danger";

const VARIANT_STYLE: Record<Variant, React.CSSProperties> = {
  neutral: { background: "var(--panel-border)", color: "var(--accent)" },
  active: { background: "var(--green-bg)", color: "var(--green-text)" },
  selected: { background: "var(--accent)", color: "var(--accent-ink)", border: "1px solid var(--accent)" },
  unselected: { background: "var(--input-bg)", color: "var(--text-85)", border: "1px solid var(--input-border)" },
  danger: { background: "oklch(0.3 0.1 25)", color: "oklch(0.8 0.14 25)" },
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
