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
