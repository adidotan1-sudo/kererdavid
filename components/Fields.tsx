"use client";

import { useFormStatus } from "react-dom";

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
  const { pending } = useFormStatus();
  const isDisabled = disabled || pending;
  return (
    <button
      type="submit"
      disabled={isDisabled}
      style={{
        width: "100%",
        textAlign: "center",
        borderRadius: 14,
        padding: 15,
        font: "700 15px var(--sans)",
        cursor: isDisabled ? "not-allowed" : "pointer",
        background: isDisabled ? "oklch(0.3 0.03 260)" : "var(--accent)",
        color: isDisabled ? "var(--text-55)" : "var(--accent-ink)",
      }}
    >
      {pending ? "שולח..." : children}
    </button>
  );
}

export function CompactSubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      style={{
        width: "100%",
        textAlign: "center",
        background: pending ? "oklch(0.3 0.03 260)" : "var(--accent)",
        color: pending ? "var(--text-55)" : "var(--accent-ink)",
        borderRadius: 12,
        padding: 12,
        font: "700 13.5px var(--sans)",
        cursor: pending ? "not-allowed" : "pointer",
      }}
    >
      {pending ? "שולח..." : children}
    </button>
  );
}
