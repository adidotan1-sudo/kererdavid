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
