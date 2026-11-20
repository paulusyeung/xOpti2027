export const SIDEBAR_WIDTH_DEFAULT = 252
export const SIDEBAR_WIDTH_MIN = 220
export const SIDEBAR_WIDTH_MAX = 420

const STORAGE_KEY = 'xopti.sidebar.width'

export function clampSidebarWidth(value: number): number {
  if (!Number.isFinite(value)) {
    return SIDEBAR_WIDTH_DEFAULT
  }
  return Math.min(SIDEBAR_WIDTH_MAX, Math.max(SIDEBAR_WIDTH_MIN, Math.round(value)))
}

export function readSidebarWidth(): number {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored !== null) {
      return clampSidebarWidth(Number(stored))
    }
  } catch {
    // Storage may be unavailable; fall back to the default width.
  }
  return SIDEBAR_WIDTH_DEFAULT
}

export function storeSidebarWidth(width: number): void {
  try {
    localStorage.setItem(STORAGE_KEY, String(clampSidebarWidth(width)))
  } catch {
    // Resizing still works for this session when storage is unavailable.
  }
}
