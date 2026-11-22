<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { api, unwrap } from '@/api/client'
import { AppError } from '@/api/problems'
import DataGridPanel, { type GridColumn } from '@/components/grid/DataGridPanel.vue'

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

interface LegacyStaffRow {
  code: string
  firstName?: string | null
  lastName?: string | null
  jobTitle?: string | null
  jobTitleName?: string | null
}

interface StaffGridRow {
  code: string
  firstName: string
  lastName: string
  jobTitleName: string
  account?: StaffRow
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

type DialogMode = 'view' | 'create' | 'role' | 'branch' | 'reset' | 'disable' | 'enable' | null

const loading = ref(true)
const saving = ref(false)
const forbidden = ref(false)
const errorMessage = ref<string | null>(null)
const notice = ref<string | null>(null)
const fieldErrors = ref<Record<string, string[]>>({})
const resetToken = ref<string | null>(null)

const staff = ref<StaffGridRow[]>([])
const identityAccounts = ref<StaffRow[]>([])
const nextCursor = ref<string | null>(null)
const search = ref('')
const catalogue = ref<RoleCatalogue | null>(null)
const branches = ref<string[]>([])

const dialog = ref<DialogMode>(null)
const dialogVisible = ref(false)
const selected = ref<StaffRow | null>(null)
const form = reactive({
  userName: '',
  displayName: '',
  firstName: '',
  lastName: '',
  jobTitleName: '',
  role: 'clerk',
  branchCode: '',
  reason: '',
})

const columns = computed<GridColumn[]>(() => [
  { key: 'code', title: 'Code', sortable: true },
  { key: 'firstName', title: 'First name', sortable: true },
  { key: 'lastName', title: 'Last name', sortable: true },
  { key: 'jobTitleName', title: 'Job title (role)', sortable: true },
])

const roleOptions = computed(() => catalogue.value?.roles.map((grant) => grant.role) ?? [])

let dragCard: HTMLElement | null = null
let dragStartX = 0
let dragStartY = 0
let dragOffsetX = 0
let dragOffsetY = 0

function onDragMove(event: MouseEvent): void {
  dragOffsetX = event.clientX - dragStartX
  dragOffsetY = event.clientY - dragStartY
  if (dragCard) {
    dragCard.style.transform = `translate(${dragOffsetX}px, ${dragOffsetY}px)`
  }
}

function onDragEnd(): void {
  document.removeEventListener('mousemove', onDragMove)
  document.removeEventListener('mouseup', onDragEnd)
}

function onDragStart(event: MouseEvent): void {
  if ((event.target as HTMLElement).closest('button')) return
  dragCard = (event.currentTarget as HTMLElement).closest<HTMLElement>(
    '[data-testid^="staff-dialog-"]',
  )
  if (!dragCard) return
  dragStartX = event.clientX - dragOffsetX
  dragStartY = event.clientY - dragOffsetY
  document.addEventListener('mousemove', onDragMove)
  document.addEventListener('mouseup', onDragEnd)
}

onBeforeUnmount(onDragEnd)

watch(dialogVisible, (open) => {
  if (!open) return
  dragOffsetX = 0
  dragOffsetY = 0
  if (dragCard) dragCard.style.transform = ''
})

function resetForm(): void {
  form.userName = ''
  form.displayName = ''
  form.firstName = ''
  form.lastName = ''
  form.jobTitleName = ''
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

function mergeRows(legacy: LegacyStaffRow[], accounts: StaffRow[]): StaffGridRow[] {
  const byCode = new Map(accounts.map((account) => [account.userName, account]))
  const rows = legacy.map((row) => ({
    code: row.code,
    firstName: row.firstName ?? '',
    lastName: row.lastName ?? '',
    jobTitleName: row.jobTitleName ?? row.jobTitle ?? '',
    account: byCode.get(row.code),
  }))

  const legacyCodes = new Set(legacy.map((row) => row.code))
  for (const account of accounts) {
    if (!legacyCodes.has(account.userName)) {
      rows.push({
        code: account.userName,
        firstName: account.displayName ?? '',
        lastName: '',
        jobTitleName: account.roles.join(', ') || 'No role (denied)',
        account,
      })
    }
  }
  return rows
}

async function load(): Promise<void> {
  loading.value = true
  errorMessage.value = null
  try {
    const [legacyResult, staffResult, rolesResult, branchResult] = await Promise.all([
      api.client.GET('/api/v1/admin/staff/directory', { params: { query: { pageSize: 50 } } }),
      api.client.GET('/api/v1/admin/staff', { params: { query: { pageSize: 200 } } }),
      api.client.GET('/api/v1/admin/roles'),
      api.client.GET('/api/v1/branches', { params: { query: { pageSize: 20 } } }),
    ])
    const legacyPage = await unwrap(legacyResult)
    const accountPage = await unwrap(staffResult)
    identityAccounts.value = accountPage.items as StaffRow[]
    staff.value = mergeRows(legacyPage.items as LegacyStaffRow[], identityAccounts.value)
    nextCursor.value = legacyPage.nextCursor ?? null
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
      await api.client.GET('/api/v1/admin/staff/directory', {
        params: { query: { pageSize: 50, cursor: nextCursor.value } },
      }),
    )
    staff.value = [
      ...staff.value,
      ...mergeRows(page.items as LegacyStaffRow[], identityAccounts.value),
    ]
    nextCursor.value = page.nextCursor ?? null
  } catch (error) {
    handleError(error)
  }
}

function openCreate(): void {
  resetForm()
  form.role = catalogue.value?.roles[0]?.role ?? 'clerk'
  selected.value = null
  dialog.value = 'create'
  dialogVisible.value = true
}

function openFor(mode: Exclude<DialogMode, 'create' | null>, row: StaffGridRow): void {
  resetForm()
  selected.value = row.account ?? null
  form.userName = row.code
  form.firstName = row.firstName
  form.lastName = row.lastName
  form.jobTitleName = row.jobTitleName
  form.displayName = row.account?.displayName ?? ''
  form.role = row.account?.roles[0] ?? catalogue.value?.roles[0]?.role ?? 'clerk'
  form.branchCode = row.account?.branchCode ?? ''
  dialog.value = mode
  dialogVisible.value = true
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

    dialogVisible.value = false
    await load()
  } catch (error) {
    handleError(error)
  } finally {
    saving.value = false
  }
}

function selectedGridRow(): StaffGridRow {
  return {
    code: selected.value?.userName ?? '',
    firstName: form.firstName,
    lastName: form.lastName,
    jobTitleName: form.jobTitleName,
    account: selected.value ?? undefined,
  }
}

function statusOf(row: StaffRow): string {
  if (row.disabled) return 'Disabled'
  if (row.resetRequired) return 'Reset required'
  return 'Active'
}

function errorFor(field: string): string | null {
  const messages = fieldErrors.value[field]
  return messages && messages.length > 0 ? messages[0] : null
}

onMounted(load)
</script>

<template>
  <div data-testid="staff-admin-page">
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

    <DataGridPanel
      v-if="!forbidden"
      view-id="staff"
      :columns="columns"
      :items="staff"
      v-model:search="search"
      :loading="loading"
      :item-key="'code'"
      link-key="code"
      row-test-id-prefix="staff-row-"
      empty-text="No staff accounts."
      search-label="Search staff"
      @refresh="load()"
      @open="openFor('view', $event as unknown as StaffGridRow)"
    >
      <template #toolbar-actions>
        <v-btn
          color="primary"
          size="small"
          prepend-icon="mdi-plus"
          data-testid="staff-create-open"
          @click="openCreate"
        >
          New staff
        </v-btn>
      </template>

      <template #footer-actions>
        <div v-if="nextCursor" class="mt-4">
          <v-btn variant="text" data-testid="staff-load-more" @click="loadMore">Load more</v-btn>
        </div>
      </template>
    </DataGridPanel>

    <v-dialog
      v-model="dialogVisible"
      max-width="min(100%, 680px)"
      scrollable
      @after-leave="dialog = null"
    >
      <v-card rounded="xl" elevation="6" :data-testid="`staff-dialog-${dialog}`">
        <v-card-title class="dialog-drag-handle d-flex align-center ga-2" @mousedown="onDragStart">
          <template v-if="dialog === 'create'">New staff account</template>
          <template v-else-if="dialog === 'view'">Staff account — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'role'">Change role — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'branch'">Branch scope — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'reset'">Force password reset — {{ selected?.userName }}</template>
          <template v-else-if="dialog === 'disable'">Disable account — {{ selected?.userName }}</template>
          <template v-else>Enable account — {{ selected?.userName }}</template>
          <v-spacer />
          <v-btn
            icon="mdi-close"
            variant="text"
            density="compact"
            aria-label="Close"
            data-testid="staff-dialog-close"
            @click="dialogVisible = false"
          />
        </v-card-title>

        <v-card-text>
          <template v-if="dialog === 'view'">
            <v-alert v-if="!selected" type="info" variant="tonal" class="mb-4">
              This staff code has no application account yet. Only legacy details are available.
            </v-alert>
            <v-row dense>
              <v-col cols="12" sm="4">
                <v-text-field label="Code" :model-value="form.userName" readonly />
              </v-col>
              <v-col cols="12" sm="4">
                <v-text-field label="First name" :model-value="form.firstName || '—'" readonly />
              </v-col>
              <v-col cols="12" sm="4">
                <v-text-field label="Last name" :model-value="form.lastName || '—'" readonly />
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field label="Job title (role)" :model-value="form.jobTitleName || '—'" readonly />
              </v-col>
              <v-col cols="12" sm="6">
                <v-text-field label="Application role" :model-value="selected?.roles.join(', ') || 'No role (denied)'" readonly />
              </v-col>
              <v-col cols="12" sm="4">
                <v-text-field label="Branch" :model-value="selected?.branchCode || '—'" readonly />
              </v-col>
              <v-col cols="12" sm="4">
                <v-text-field
                  label="Status"
                  :model-value="selected ? statusOf(selected) : 'No application account'"
                  readonly
                />
              </v-col>
              <v-col cols="12" sm="4">
                <v-text-field label="Legacy security level" :model-value="selected?.legacyLevel" readonly />
              </v-col>
            </v-row>
          </template>

          <template v-else-if="dialog === 'create'">
            <v-text-field
              v-model="form.userName"
              label="Username"
              data-testid="staff-username"
              :error-messages="errorFor('UserName')"
            />
            <v-text-field v-model="form.displayName" label="Display name" data-testid="staff-display-name" />
            <v-select
              v-model="form.role"
              :items="roleOptions"
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
              :items="roleOptions"
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
            v-if="dialog !== 'view'"
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
          <template v-if="dialog === 'view'">
            <template v-if="selected">
              <v-btn
                size="small"
                variant="text"
                color="primary"
                :data-testid="`staff-role-${selected.userName}`"
                @click="openFor('role', selectedGridRow())"
              >
                Change role
              </v-btn>
            <v-btn
              size="small"
              variant="text"
              :data-testid="`staff-branch-${selected.userName}`"
              @click="openFor('branch', selectedGridRow())"
            >
              Branch
            </v-btn>
            <v-btn
              size="small"
              variant="text"
              :data-testid="`staff-reset-${selected.userName}`"
              @click="openFor('reset', selectedGridRow())"
            >
              Force reset
            </v-btn>
            <v-btn
              v-if="selected.disabled"
              size="small"
              variant="text"
              :data-testid="`staff-enable-${selected.userName}`"
              @click="openFor('enable', selectedGridRow())"
            >
              Enable
            </v-btn>
            <v-btn
              v-else
              size="small"
              variant="text"
              color="error"
              :data-testid="`staff-disable-${selected.userName}`"
              @click="openFor('disable', selectedGridRow())"
            >
              Disable
            </v-btn>
            </template>
            <v-spacer />
            <v-btn variant="text" data-testid="staff-dialog-cancel" @click="dialogVisible = false">
              Close
            </v-btn>
          </template>
          <template v-else>
            <v-spacer />
            <v-btn variant="text" data-testid="staff-dialog-cancel" @click="dialogVisible = false">Cancel</v-btn>
            <v-btn
              color="primary"
              data-testid="staff-dialog-submit"
              :loading="saving"
              @click="submit"
            >
              Save
            </v-btn>
          </template>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<style scoped>
.dialog-drag-handle {
  cursor: move;
  user-select: none;
}
</style>
