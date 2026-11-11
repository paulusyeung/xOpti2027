import { createVuetify } from 'vuetify'

// Components and directives are auto-imported by vite-plugin-vuetify, so only
// components actually used are included in the bundle.
export const vuetify = createVuetify({
  locale: { locale: 'en' },
  icons: { defaultSet: 'mdi' },
  theme: {
    defaultTheme: 'light',
  },
})
