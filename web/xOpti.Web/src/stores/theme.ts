import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { themeRegistry } from '@/themes/registry'

const THEME_STORAGE_KEY = 'xopti.theme.v1'
const DEFAULT_SCHEME = 'blue'

export const appModes = ['light', 'dark'] as const
export type AppMode = (typeof appModes)[number]

// Every registry entry has a light and a dark variant, so both modes expose the
// same selectable schemes.
export const appSchemes = {
  light: themeRegistry.map((pair) => pair.id),
  dark: themeRegistry.map((pair) => pair.id),
} as const

export type AppScheme = string

interface ThemeState {
  mode: AppMode
  scheme: string
}

export const useThemeStore = defineStore('theme', () => {
  const state = ref<ThemeState>(readStoredTheme())

  const mode = computed(() => state.value.mode)
  const scheme = computed(() => state.value.scheme)
  const isDark = computed(() => state.value.mode === 'dark')
  const vuetifyTheme = computed(() => `${state.value.mode}-${state.value.scheme}`)

  function setMode(nextMode: AppMode): void {
    state.value.mode = nextMode
    if (!(appSchemes[nextMode] as readonly string[]).includes(state.value.scheme)) {
      state.value.scheme = DEFAULT_SCHEME
    }
    saveTheme()
  }

  function setScheme(nextScheme: string): void {
    if (!themeRegistry.some((pair) => pair.id === nextScheme)) {
      return
    }
    state.value.scheme = nextScheme
    saveTheme()
  }

  function toggleTheme(): void {
    setMode(isDark.value ? 'light' : 'dark')
  }

  function saveTheme(): void {
    try {
      localStorage.setItem(THEME_STORAGE_KEY, JSON.stringify(state.value))
    } catch {
      // A blocked or full localStorage must not break theme switching.
    }
  }

  return {
    mode,
    scheme,
    isDark,
    vuetifyTheme,
    setMode,
    setScheme,
    toggleTheme,
  }
})

function readStoredTheme(): ThemeState {
  try {
    const stored = localStorage.getItem(THEME_STORAGE_KEY)
    if (stored) {
      const parsed = JSON.parse(stored) as Partial<ThemeState>
      if (
        parsed.mode !== undefined
        && appModes.includes(parsed.mode as AppMode)
        && typeof parsed.scheme === 'string'
        && themeRegistry.some((pair) => pair.id === parsed.scheme)
      ) {
        return { mode: parsed.mode as AppMode, scheme: parsed.scheme }
      }
    }
  } catch {
    // Ignore malformed or unavailable storage and fall through to the default.
  }

  const systemMode: AppMode =
    typeof window !== 'undefined'
    && window.matchMedia?.('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light'

  return { mode: systemMode, scheme: DEFAULT_SCHEME }
}
