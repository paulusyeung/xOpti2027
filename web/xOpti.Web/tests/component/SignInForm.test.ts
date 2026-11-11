import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import SignInForm from '@/layout/SignInForm.vue'
import { createPinia, setActivePinia } from 'pinia'
import { useSessionStore } from '@/stores/session'
import { AppError } from '@/api/problems'
import { mountInApp } from './support'

afterEach(() => {
  vi.restoreAllMocks()
})

async function submit(wrapper: { find: (s: string) => { trigger: (e: string) => Promise<unknown> } }, username: string, password: string) {
  const inputs = (wrapper as unknown as { findAll: (s: string) => { setValue: (v: string) => void }[] }).findAll(
    'input',
  )
  inputs[0].setValue(username)
  inputs[1].setValue(password)
  await wrapper.find('[data-testid="sign-in-submit"]').trigger('click')
  await flushPromises()
}

describe('SignInForm', () => {
  it('shows the same message for an unknown user and a wrong password', async () => {
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    const reject = vi
      .spyOn(session, 'signIn')
      .mockRejectedValue(new AppError({ kind: 'unauthenticated', status: 401, correlationId: 'c' }))

    const { wrapper } = await mountInApp(SignInForm, { pinia })
    await submit(wrapper, 'nobody', 'x')
    const unknownMessage = wrapper.find('[data-testid="sign-in-error"]').text()

    reject.mockRejectedValueOnce(new AppError({ kind: 'unauthenticated', status: 401, correlationId: 'c' }))
    await submit(wrapper, 'manager', 'wrong')
    const wrongMessage = wrapper.find('[data-testid="sign-in-error"]').text()

    expect(unknownMessage).toBe('The username or password is incorrect.')
    expect(wrongMessage).toBe(unknownMessage)
    wrapper.unmount()
  })

  it('shows the reset-required message and no password form', async () => {
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    vi.spyOn(session, 'signIn').mockRejectedValue(
      new AppError({ kind: 'reset-required', status: 403, correlationId: 'c' }),
    )

    const { wrapper } = await mountInApp(SignInForm, { pinia })
    await submit(wrapper, 'newuser', 'temp')

    expect(wrapper.find('[data-testid="sign-in-error"]').text()).toContain('administrator')
    expect(wrapper.find('input[type="password"]').exists()).toBe(false)
    expect(wrapper.find('[data-testid="sign-in-submit"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('clears the password after a failed attempt', async () => {
    const pinia = createPinia()
    setActivePinia(pinia)
    const session = useSessionStore(pinia)
    vi.spyOn(session, 'signIn').mockRejectedValue(
      new AppError({ kind: 'unauthenticated', status: 401, correlationId: 'c' }),
    )

    const { wrapper } = await mountInApp(SignInForm, { pinia })
    await submit(wrapper, 'manager', 'secret')

    const password = wrapper.find('input[type="password"]').element as HTMLInputElement
    expect(password.value).toBe('')
    wrapper.unmount()
  })
})
