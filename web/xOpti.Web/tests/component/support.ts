import { defineComponent, h, type Component } from 'vue'
import { mount, type VueWrapper } from '@vue/test-utils'
import { createPinia, setActivePinia, type Pinia } from 'pinia'
import { createMemoryHistory, type Router } from 'vue-router'
import { VApp } from 'vuetify/components'
import { createAppRouter } from '@/router'
import { vuetify } from '@/plugins/vuetify'
import { useSessionStore } from '@/stores/session'

/**
 * Mounts a component inside Vuetify's VApp (required by layout components) with
 * pinia, a memory router, and vuetify. Unless a session is already set on the
 * supplied pinia, the session is anonymous, so the guard never calls the network.
 */
export async function mountInApp(
  component: Component,
  options: { path?: string; props?: Record<string, unknown>; pinia?: Pinia } = {},
): Promise<{ wrapper: VueWrapper; router: Router; pinia: Pinia }> {
  const pinia = options.pinia ?? createPinia()
  setActivePinia(pinia)
  const session = useSessionStore(pinia)
  if (session.status === 'unknown') {
    session.status = 'anonymous'
  }

  const router = createAppRouter(createMemoryHistory())
  await router.push(options.path ?? '/sign-in')
  await router.isReady()

  const Host = defineComponent({
    setup() {
      return () => h(VApp, null, () => [h(component, options.props)])
    },
  })
  const wrapper = mount(Host, {
    global: {
      plugins: [pinia, router, vuetify],
    },
    attachTo: document.body,
  })
  return { wrapper, router, pinia }
}
