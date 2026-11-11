import { createApp } from 'vue'
import { createPinia } from 'pinia'
import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import App from './App.vue'
import { vuetify } from './plugins/vuetify'
import { createAppRouter } from './router'
import { loadRuntimeConfig } from './runtime/config'
import { api } from './api/client'
import { useSessionStore } from './stores/session'

async function bootstrap(): Promise<void> {
  // Runtime configuration first: route guards and nav depend on it.
  await loadRuntimeConfig()

  const pinia = createPinia()
  const app = createApp(App)
  app.use(pinia)

  const router = createAppRouter()
  app.use(router)
  app.use(vuetify)

  const session = useSessionStore(pinia)
  api.setSessionExpiredHandler(() => session.expire())

  await router.isReady()
  app.mount('#app')
}

void bootstrap()
