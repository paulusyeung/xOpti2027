import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useThemeStore } from '@/stores/theme'

const STORAGE_KEY = 'xopti.theme.v1'

function newStore() {
  setActivePinia(createPinia())
  return useThemeStore()
}

beforeEach(() => {
  localStorage.clear()
})

describe('theme store', () => {
  it('defaults to a light Vuetify theme', () => {
    const theme = newStore()
    expect(theme.mode).toBe('light')
    expect(theme.isDark).toBe(false)
    expect(theme.vuetifyTheme).toBe(`light-${theme.scheme}`)
  })

  it('toggles between light and dark and updates the Vuetify theme name', () => {
    const theme = newStore()
    theme.setScheme('teal')
    theme.toggleTheme()

    expect(theme.mode).toBe('dark')
    expect(theme.isDark).toBe(true)
    expect(theme.vuetifyTheme).toBe('dark-teal')

    theme.toggleTheme()
    expect(theme.vuetifyTheme).toBe('light-teal')
  })

  it('persists the selected mode and scheme', () => {
    const theme = newStore()
    theme.setMode('dark')
    theme.setScheme('green')

    const restored = newStore()
    expect(restored.mode).toBe('dark')
    expect(restored.scheme).toBe('green')
    expect(restored.vuetifyTheme).toBe('dark-green')
  })

  it('ignores malformed storage and unknown schemes', () => {
    localStorage.setItem(STORAGE_KEY, '{not-json')
    expect(newStore().vuetifyTheme).toBe('light-blue')

    localStorage.setItem(STORAGE_KEY, JSON.stringify({ mode: 'dark', scheme: 'not-a-scheme' }))
    expect(newStore().vuetifyTheme).toBe('light-blue')
  })

  it('rejects unknown schemes without changing the current selection', () => {
    const theme = newStore()
    theme.setScheme('teal')
    theme.setScheme('not-a-scheme')
    expect(theme.scheme).toBe('teal')
  })
})
