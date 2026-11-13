<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'

interface StaffRow {
  id: string
  userName: string
  displayName?: string | null
  legacyLevel: number
  roles: string[]
  branchCode?: string | null
  resetRequired: boolean
  disabled: boolean
}

interface RoleGrant {
  role: string
  permissions: string[]
}

interface RoleCatalogue {
  version: string
  signed: boolean
  roles: RoleGrant[]
  unassignedPermissions: string[]
  parityGaps: string[]
}

type DialogMode = 'create' | 'role' | 'branch' | 'reset' | 'disable' | 'enable' | null

const loading = ref(true)
const saving = ref(false)
const forbidden = ref(false)
const errorMessage = ref<string | null>(null)
const notice = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const resetToken = ref<string | null>(null)

const staff = ref<StaffRow[]>([])
const nextCursor = ref<string | null>(null)
const catalogue = ref<RoleCatalogue | null>(null)
const branches = ref<string[]>([])

const dialog = ref<DialogMode>(null)
const selected = ref<StaffRow | null>(null)
const form = reactive({
  userName: '',
  displayName: '',
  role: 'clerk',
  branchCode: '',
  reason: '',
})

function resetForm(): void {
  form.userName = ''
  form.displayName = ''
  form.role = catalogue.value?.roles[0]?.role ?? 'clerk'
  form.branchCode = ''
  form.reason = ''
  fieldErrors.value = {}
  errorMessage.value = null
  resetToken.value = null
}

function handleError(error: unknown): void {
  if (error instanceof AppError) {
    if (error.kind === 'authorization' || error.kind === 'unauthenticated') {
      forbidden.value = true
      return
    }
    if (error.kind === 'validation') {
      fieldErrors.value = Object.fromEntries(
        Object.entries(error.fieldErrors).map(([field, messages]) => [field, [...messages]]),
      )
      errorMessage.value = error.userMessage
      return
    }
    errorMessage.value = error.userMessage
    return
  }
  errorMessage.value = 'The request failed. Please try again.'
}

async function load(): Promise<void> {
  loading.value = true
  errorMessage.value = null
  try {
    const [staffResult, rolesResult, branchResult] = await Promise.all([
      api.client.GET('/api/v1/admin/staff', { params: { query: { pageSize: 50 } } }),
      api.client.GET('/api/v1/admin/roles'),
      api.client.GET('/api/v1/branches', { params: { query: { pageSize: 20 } } }),
    ])
    const page = await unwrap(staffResult)
    staff.value = page.items as StaffRow[]
    nextCursor.value = page.nextCursor ?? null
    catalogue.value = await unwrap(rolesResult) as RoleCatalogue
    branches.value = (await unwrap(branchResult)).items.map((branch) => branch.branchCode)
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

async function loadMore(): Promise<void> {
  if (!nextCursor.value) {
    return
  }
  try {
    const page = await unwrap(
      await api.client.GET('/api/v1/admin/staff', {
        params: { query: { pageSize: 50, cursor: nextCursor.value } },
      }),
    )
    staff.value = [...staff.value, ...(page.items as StaffRow[])]
    nextCursor.value = page.nextCursor ?? null
  } catch (error) {
    handleError(error)
  }
}

function openCreate(): void {
  resetForm()
  form.role = catalogue.value?.roles[0]?.role ?? 'clerk'
  dialog.value = 'create'
}

function openFor(mode: Exclude<DialogMode, 'create' | null>, row: StaffRow): void {
  resetForm()
  selected.value = row
  form.role = row.roles[0] ?? catalogue.value?.roles[0]?.role ?? 'clerk'
  form.branchCode = row.branchCode ?? ''
  dialog.value = mode
}

async function submit(): Promise<void> {
  saving.value = true
  fieldErrors.value = {}
  errorMessage.value = null
  resetToken.value = null
  try {
    if (dialog.value === 'create') {
      const created = await unwrap(
        await api.client.POST('/api/v1/admin/staff', {
          body: {
            userName: form.userName,
            displayName: form.displayName || null,
            role: form.role,
            branchCode: form.branchCode || null,
            reason: form.reason,
          },
        }),
      )
      resetToken.value = created.resetToken
      notice.value = `Staff account '${created.account.userName}' created. Give the reset token to the staff member.`
    } else if (selected.value && dialog.value === 'role') {
      await unwrap(
        await api.client.PUT('/api/v1/admin/staff/{id}/role', {
          params: { path: { id: selected.value.id } },
          body: { role: form.role, reason: form.reason },
        }),
      )
      notice.value = `Role updated for '${selected.value.userName}'.`
    } else if (selected.value && dialog.value === 'branch') {
      await unwrap(
        await api.client.PUT('/api/v1/admin/staff/{id}/branch', {
          params: { path: { id: selected.value.id } },
          body: { branchCode: form.branchCode || null, reason: form.reason },
        }),
      )
      notice.value = `Branch scope updated for '${selected.value.userName}'.`
    } else if (selected.value && dialog.value === 'reset') {
      const result = await unwrap(
        await api.client.POST('/api/v1/admin/staff/{id}/force-reset', {
          params: { path: { id: selected.value.id } },
          body: { reason: form.reason },
        }),
      )
      resetToken.value = result.resetToken
      notice.value = `A reset was forced for '${selected.value.userName}'.`
    } else if (selected.value && dialog.value === 'disable') {
      await unwrap(
        await api.client.POST('/api/v1/admin/staff/{id}/disable', {
          params: { path: { id: selected.value.id } },
          body: { reason: form.reason },
        }),
      )
      notice.value = `'${selected.value.userName}' was disabled.`
    } else if (selected.value && dialog.value === 'enable') {
      await unwrap(
        await api.client.POST('/api/v1/admin/staff/{id}/enable', {
          params: { path: { id: selected.value.id } },
          body: { reason: form.reason },
        }),
      )
      notice.value = `'${selected.value.userName}' was re-enabled.`
    }

    dialog.value = null
    await load()
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

function errorFor(field: string): string | null {
  const messages = fieldErrors.value[field]
  return messages && messages.length > 0 ? messages[0] : null
}

onMounted(load)
</script>

<template>
  <div data-testid="staff-admin-page">
    <div class="d-flex align-center mb-4">
      <h1 class="text-h5">Staff administration</h1>
      <v-spacer />
      <v-btn
        color="primary"
        data-testid="staff-create-open"
        :disabled="forbidden"
        @click="openCreate"
      >
        New staff
      </v-btn>
    </div>

    <v-alert v-if="forbidden" type="error" variant="tonal" data-testid="staff-forbidden">
      You do not have permission to administer staff accounts.
    </v-alert>
    <v-alert v-else-if="errorMessage" type="error" variant="tonal" class="mb-4" data-testid="staff-error">
      {{ errorMessage }}
    </v-alert>
    <v-alert v-if="notice" type="success" variant="tonal" class="mb-4" data-testid="staff-notice">
      {{ notice }}
    </v-alert>
    <v-alert v-if="resetToken" type="info" variant="tonal" class="mb-4" data-testid="staff-reset-token">
      Reset token: <code>{{ resetToken }}</code>
    </v-alert>

    <div v-if="loading" class="d-flex justify-center pa-8" data-testid="staff-loading">
      <v-progress-circular indeterminate />
    </div>

    <template v-else-if="!forbidden">
      <v-table data-testid="staff-table" density="comfortable">
        <thead>
          <tr>
            <th>Username</th>
            <th>Display name</th>
            <th>Role</th>
            <th>Branch</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in staff" :key="row.id" :data-testid="`staff-row-${row.userName}`">
            <td>{{ row.userName }}</td>
            <td>{{ row.displayName }}</td>
            <td>{{ row.roles.join(', ') || 'No role (denied)' }}</td>
            <td>{{ row.branchCode || '—' }}</td>
            <td>
              <v-chip v-if="row.disabled" color="error" size="small" data-testid="staff-status-disabled">
                Disabled
              </v-chip>
              <v-chip v-else-if="row.resetRequired" color="warning" size="small">
                Reset required
              </v-chip>
              <v-chip v-else color="success" size="small">Active</v-chip>
            </td>
            <td class="d-flex flex-wrap ga-1">
              <v-btn
                size="small"
                variant="text"
                :data-testid="`staff-role-${row.userName}`"
                @click="openFor('role', row)"
              >
                Role
              </v-btn>
              <v-btn
                size="small"
                variant="text"
                :data-testid="`staff-branch-${row.userName}`"
                @click="openFor('branch', row)"
              >
                Branch
              </v-btn>
              <v-btn
                size="small"
                variant="text"
                :data-testid="`staff-reset-${row.userName}`"
                @click="openFor('reset', row)"
              >
                Force reset
              </v-btn>
              <v-btn
                v-if="row.disabled"
                size="small"
                variant="text"
                :data-testid="`staff-enable-${row.userName}`"
                @click="openFor('enable', row)"
              >
                Enable
              </v-btn>
              <v-btn
                v-else
                size="small"
                variant="text"
                color="error"
                :data-testid="`staff-disable-${row.userName}`"
                @click="openFor('disable', row)"
              >
                Disable
              </v-btn>
            </td>
          </tr>
          <tr v-if="staff.length === 0">
            <td colspan="6" class="text-medium-emphasis">No staff accounts.</td>
          </tr>
        </tbody>
      </v-table>

      <div v-if="nextCursor" class="mt-4">
        <v-btn variant="text" data-testid="staff-load-more" @click="loadMore">Load more</v-btn>
      </div>

      <v-card v-if="catalogue" class="mt-6" variant="outlined" data-testid="roles-panel">
        <v-card-title class="text-subtitle-1">
          Roles and permissions
          <v-chip
            class="ml-2"
            size="small"
            :color="catalogue.signed ? 'success' : 'warning'"
            data-testid="matrix-signed-state"
          >
            {{ catalogue.signed ? 'Signed' : 'Provisional matrix' }}
          </v-chip>
        </v-card-title>
        <v-card-text>
          <div v-for="grant in catalogue.roles" :key="grant.role" class="mb-2">
            <strong>{{ grant.role }}</strong>:
            <span>{{ grant.permissions.join(', ') || 'no permissions' }}</span>
          </div>
          <div v-if="catalogue.unassignedPermissions.length" class="text-medium-emphasis mt-2">
            Unassigned: {{ catalogue.unassignedPermissions.join(', ') }}
          </div>
        </v-card-text>
      </v-card>
    </template>

    <v-card v-if="dialog" class="mt-6" variant="outlined" :data-testid="`staff-dialog-${dialog}`">
        <v-card-title>
          <template v-if="dialog === 'create'">New staff account</template>
          <template v-else-if="dialog === 'role'">Change role — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'branch'">Branch scope — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'reset'">Force password reset — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'disable'">Disable account — {{ selected?.userName }}</template>
          <template v-else>Enable account — {{ selected?.userName }}</template>
        </v-card-title>
        <v-card-text>
          <template v-if="dialog === 'create'">
            <v-text-field
              v-model="form.userName"
              label="Username"
              data-testid="staff-username"
              :error-messages="errorFor('UserName')"
            />
            <v-text-field v-model="form.displayName" label="Display name" data-testid="staff-display-name" />
            <v-select
              v-model="form.role"
              :items="catalogue?.roles.map((grant) => grant.role) ?? []"
              label="Role"
              data-testid="staff-role-select"
              :error-messages="errorFor('Role')"
            />
            <v-select
              v-model="form.branchCode"
              :items="branches"
              label="Branch"
              clearable
              data-testid="staff-branch-select"
            />
          </template>
          <template v-else-if="dialog === 'role'">
            <v-select
              v-model="form.role"
              :items="catalogue?.roles.map((grant) => grant.role) ?? []"
              label="Role"
              data-testid="staff-role-select"
              :error-messages="errorFor('Role')"
            />
          </template>
          <template v-else-if="dialog === 'branch'">
            <v-select
              v-model="form.branchCode"
              :items="branches"
              label="Branch"
              clearable
              data-testid="staff-branch-select"
            />
          </template>
          <v-text-field
            v-model="form.reason"
            label="Reason (recorded in the audit trail)"
            data-testid="staff-reason"
            :error-messages="errorFor('Reason')"
          />
          <v-alert v-if="errorMessage" type="error" variant="tonal" dense data-testid="staff-dialog-error">
            {{ errorMessage }}
          </v-alert>
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" data-testid="staff-dialog-cancel" @click="dialog = null">Cancel</v-btn>
          <v-btn
            color="primary"
            data-testid="staff-dialog-submit"
            :loading="saving"
            @click="submit"
          >
            Save
          </v-btn>
        </v-card-actions>
    </v-card>
  </div>
</template>
