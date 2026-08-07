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
