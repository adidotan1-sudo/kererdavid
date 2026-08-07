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
