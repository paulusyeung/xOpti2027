import { createVuetify } from 'vuetify'
import { themeRegistry, type ThemeConfig } from '@/themes/registry'

const themes: Record<string, ThemeConfig> = {}

for (const pair of themeRegistry) {
  themes[`light-${pair.id}`] = pair.light
  themes[`dark-${pair.id}`] = pair.dark
}

// Components and directives are auto-imported by vite-plugin-vuetify, so only
// components actually used are included in the bundle.
export const vuetify = createVuetify({
  locale: { locale: 'en' },
  icons: { defaultSet: 'mdi' },
  theme: {
    defaultTheme: 'light-blue',
    themes,
  },
})
