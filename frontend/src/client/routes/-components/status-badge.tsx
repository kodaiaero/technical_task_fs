export function StatusBadge({ disabled }: { disabled: boolean }) {
  if (disabled) {
    return (
      <span className="rounded-full bg-red-100 px-2.5 py-0.5 text-xs font-medium text-red-700">
        Disabled
      </span>
    );
  }

  return (
    <span className="rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-medium text-emerald-700">
      Live
    </span>
  );
}
