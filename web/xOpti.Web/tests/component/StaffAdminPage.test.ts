import { afterEach, describe, expect, it, vi } from 'vitest'
import { flushPromises } from '@vue/test-utils'
import StaffAdminPage from '@/features/admin/StaffAdminPage.vue'
import { mountInApp } from './support'

const staffPage = {
  items: [
    {
      id: 'u-manager',
      userName: 'manager',
      displayName: 'Manager',
      legacyLevel: 5,
      roles: ['manager'],
      branchCode: '01',
      resetRequired: false,
      disabled: false,
    },
  ],
  nextCursor: null,
}

const roles = {
  version: '1.0.0-provisional.1',
  signed: false,
  signedBy: null,
  approvedOn: null,
  levelRules: [{ minLevel: 1, role: 'clerk' }],
  roles: [
    { role: 'clerk', permissions: ['sales:order-create'] },
    { role: 'manager', permissions: ['cost:view', 'master-data:maintain'] },
  ],
  unassignedPermissions: ['customer:pii'],
  parityGaps: ['PERM-008 cost visibility'],
}

const branches = {
  items: [
    { branchCode: '01', name: 'Branch 1', city: 'Richmond' },
    { branchCode: '02', name: 'Branch 2', city: 'Richmond' },
  ],
  nextCursor: null,
}

const created = {
  account: {
    id: 'u-new',
    userName: 'new.user',
    displayName: 'New User',
    legacyLevel: -1,
    roles: ['clerk'],
    branchCode: '01',
    resetRequired: true,
    disabled: false,
  },
  resetToken: 'TOKEN-123',
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  })
}

function stubApi(postResponse: () => Response = () => json(created, 201)) {
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const request = input instanceof Request ? input : null
    const url = request ? request.url : String(input)
    const method = request ? request.method : (init?.method ?? 'GET')

    if (url.includes('/api/v1/auth/csrf-token')) {
      return json({ token: 'csrf-token' })
    }
    if (url.includes('/api/v1/admin/roles')) {
      return json(roles)
    }
    if (url.includes('/api/v1/admin/staff') && method === 'GET') {
      return json(staffPage)
    }
    if (url.includes('/api/v1/branches')) {
      return json(branches)
    }
    if (url.includes('/api/v1/admin/staff') && method === 'POST') {
      return postResponse()
    }
    return json({}, 404)
  })
  vi.stubGlobal('fetch', fetchMock)
  return fetchMock
}

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('StaffAdminPage', () => {
  it('loads the staff table and the provisional role matrix', async () => {
    stubApi()
    const { wrapper } = await mountInApp(StaffAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="staff-table"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="staff-row-manager"]').text()).toContain('manager')
    expect(wrapper.find('[data-testid="roles-panel"]').text()).toContain('Provisional matrix')
    expect(wrapper.find('[data-testid="roles-panel"]').text()).toContain('master-data:maintain')
    expect(wrapper.text()).toContain('customer:pii')
    wrapper.unmount()
  })

  it('shows a forbidden state instead of the table when the API denies access', async () => {
    vi.stubGlobal('fetch', vi.fn(async () =>
      json({ type: 'https://errors.xopti/authorization', title: 'Forbidden', status: 403 }, 403)))
    const { wrapper } = await mountInApp(StaffAdminPage, { path: '/' })
    await flushPromises()

    expect(wrapper.find('[data-testid="staff-forbidden"]').exists()).toBe(true)
    expect(wrapper.find('[data-testid="staff-table"]').exists()).toBe(false)
    wrapper.unmount()
  })

  it('renders field-level validation errors from a failed create', async () => {
    stubApi(() =>
      json(
        {
          type: 'https://errors.xopti/validation',
          title: 'Validation failed',
          status: 400,
          errors: [{ field: 'UserName', code: 'invalid', message: 'Username is required.' }],
        },
        400,
      ),
    )

    const { wrapper } = await mountInApp(StaffAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="staff-create-open"]').trigger('click')
    await wrapper.find('[data-testid="staff-reason"] input').setValue('new hire')
    await wrapper.find('[data-testid="staff-dialog-submit"]').trigger('click')
    await flushPromises()

    const dialog = wrapper.find('[data-testid="staff-dialog-create"]')
    expect(dialog.exists()).toBe(true)
    expect(dialog.text()).toContain('Username is required.')
    wrapper.unmount()
  })

  it('creates a staff account and surfaces the one-time reset token', async () => {
    const fetchMock = stubApi()

    const { wrapper } = await mountInApp(StaffAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="staff-create-open"]').trigger('click')
    await wrapper.find('[data-testid="staff-username"] input').setValue('new.user')
    await wrapper.find('[data-testid="staff-reason"] input').setValue('new hire')
    await wrapper.find('[data-testid="staff-dialog-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="staff-reset-token"]').text()).toContain('TOKEN-123')
    expect(wrapper.find('[data-testid="staff-notice"]').text()).toContain("'new.user' created")
    expect(fetchMock.mock.calls.some(([input]) => {
      const request = input instanceof Request ? input : null
      return request?.method === 'POST' && request.url.includes('/api/v1/admin/staff')
    })).toBe(true)
    wrapper.unmount()
  })

  it('disables an account with a mandatory reason and reloads the table', async () => {
    const fetchMock = stubApi(() => json({ ...staffPage.items[0], disabled: true }))
    // The disable endpoint returns a staff account, not the create payload.
    fetchMock.mockImplementation(async (input: RequestInfo | URL, init?: RequestInit) => {
      const request = input instanceof Request ? input : null
      const url = request ? request.url : String(input)
      const method = request ? request.method : (init?.method ?? 'GET')
      if (url.includes('/api/v1/auth/csrf-token')) return json({ token: 'csrf-token' })
      if (url.includes('/api/v1/admin/roles')) return json(roles)
      if (url.includes('/api/v1/branches')) return json(branches)
      if (url.includes('/api/v1/admin/staff') && method === 'GET') return json(staffPage)
      if (url.includes('/disable')) return json({ ...staffPage.items[0], disabled: true })
      return json({}, 404)
    })

    const { wrapper } = await mountInApp(StaffAdminPage, { path: '/' })
    await flushPromises()

    await wrapper.find('[data-testid="staff-disable-manager"]').trigger('click')
    await wrapper.find('[data-testid="staff-reason"] input').setValue('left company')
    await wrapper.find('[data-testid="staff-dialog-submit"]').trigger('click')
    await flushPromises()

    expect(wrapper.find('[data-testid="staff-notice"]').text()).toContain('disabled')
    expect(fetchMock.mock.calls.some(([input]) => {
      const request = input instanceof Request ? input : null
      return request?.method === 'POST' && request.url.includes('/disable')
    })).toBe(true)
    wrapper.unmount()
  })
})
