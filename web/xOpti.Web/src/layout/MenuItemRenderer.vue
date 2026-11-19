<template>
  <v-list
    v-if="depth === 0"
    v-model:opened="openedGroups"
    nav
    density="comfortable"
    prepend-gap="8"
    open-strategy="single"
    data-testid="nav-menu"
  >
    <template v-for="item in items" :key="item.to ?? item.title">
      <v-list-group
        v-if="hasChildren(item)"
        :value="groupValue(item)"
        :aria-label="item.title"
        :class="{ 'menu-group--collapsed': showTooltips }"
      >
        <template #activator="{ props: activatorProps, isOpen }">
          <v-tooltip :disabled="!showTooltips" location="right">
            <template #activator="{ props: tooltipProps }">
              <v-list-item
                v-bind="mergeActivatorProps(activatorProps, tooltipProps)"
                :class="{ 'menu-item--collapsed': showTooltips }"
                :prepend-icon="item.icon"
                :title="item.title"
                :aria-label="item.title"
                :aria-expanded="isOpen"
                :data-testid="item.testId"
                rounded="xl"
              />
            </template>

            <span>{{ item.title }}</span>
          </v-tooltip>
        </template>

        <div
          class="menu-children"
          :class="{ 'menu-children--collapsed': showTooltips }"
        >
          <MenuItemRenderer
            :items="item.children ?? []"
            :depth="depth + 1"
            :show-tooltips="showTooltips"
            :group-path="groupValue(item)"
          />
        </div>
      </v-list-group>

      <v-tooltip v-else :disabled="!showTooltips" location="right">
        <template #activator="{ props: tooltipProps }">
          <v-list-item
            v-bind="tooltipProps"
            :class="{ 'menu-item--collapsed': showTooltips }"
            :prepend-icon="item.icon"
            :title="item.title"
            :to="item.to"
            :aria-label="item.title"
            :data-testid="item.testId"
            exact
            rounded="xl"
          />
        </template>

        <span>{{ item.title }}</span>
      </v-tooltip>
    </template>
  </v-list>

  <template v-else>
    <template v-for="item in items" :key="item.to ?? item.title">
      <v-list-group
        v-if="hasChildren(item)"
        :value="groupValue(item)"
        :aria-label="item.title"
        :class="{ 'menu-group--collapsed': showTooltips }"
      >
        <template #activator="{ props: activatorProps, isOpen }">
          <v-tooltip :disabled="!showTooltips" location="right">
            <template #activator="{ props: tooltipProps }">
              <v-list-item
                v-bind="mergeActivatorProps(activatorProps, tooltipProps)"
                :class="{ 'menu-item--collapsed': showTooltips }"
                :prepend-icon="item.icon"
                :title="item.title"
                :aria-label="item.title"
                :aria-expanded="isOpen"
                :data-testid="item.testId"
                rounded="xl"
              />
            </template>

            <span>{{ item.title }}</span>
          </v-tooltip>
        </template>

        <div
          class="menu-children"
          :class="{ 'menu-children--collapsed': showTooltips }"
        >
          <MenuItemRenderer
            :items="item.children ?? []"
            :depth="depth + 1"
            :show-tooltips="showTooltips"
            :group-path="groupValue(item)"
          />
        </div>
      </v-list-group>

      <v-tooltip v-else :disabled="!showTooltips" location="right">
        <template #activator="{ props: tooltipProps }">
          <v-list-item
            v-bind="tooltipProps"
            :class="{ 'menu-item--collapsed': showTooltips }"
            :prepend-icon="item.icon"
            :title="item.title"
            :to="item.to"
            :aria-label="item.title"
            :data-testid="item.testId"
            exact
            rounded="xl"
          />
        </template>

        <span>{{ item.title }}</span>
      </v-tooltip>
    </template>
  </template>
</template>

<script setup lang="ts">
import { getCurrentInstance, ref, watch } from 'vue'
import type { NavTreeNode } from '@/router/nav'

defineOptions({
  name: 'MenuItemRenderer',
})

const props = withDefaults(defineProps<{
  items: NavTreeNode[]
  depth?: number
  showTooltips?: boolean
  groupPath?: string
  defaultOpen?: readonly string[]
}>(), {
  depth: 0,
  showTooltips: false,
  groupPath: undefined,
  defaultOpen: () => [],
})

const instanceUid = getCurrentInstance()?.uid ?? 0
const rootGroupPath = props.groupPath ?? `menu-${instanceUid}`

function slug(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

function groupValue(item: NavTreeNode): string {
  return `${rootGroupPath}-${slug(item.title)}`
}

function hasChildren(item: NavTreeNode): boolean {
  return Array.isArray(item.children) && item.children.length > 0
}

// Groups start collapsed except the ones named in defaultOpen (Point-of-Service
// on first login). The list uses the single open strategy, so opening another
// group closes the previous one. Groups that appear later, for example once
// permissions resolve, follow the same rule and are then left under the user's
// control.
const openedGroups = ref<string[]>([])
const knownGroups = new Set<string>()

watch(
  () => props.items,
  (items) => {
    const additions: string[] = []

    for (const item of items.filter(hasChildren)) {
      const value = groupValue(item)
      if (knownGroups.has(value)) {
        continue
      }
      knownGroups.add(value)
      if (props.defaultOpen.includes(item.title)) {
        additions.push(value)
      }
    }

    if (additions.length > 0) {
      openedGroups.value = [...openedGroups.value, ...additions]
    }
  },
  { immediate: true },
)

function mergeActivatorProps(
  activatorProps: Record<string, unknown>,
  tooltipProps: Record<string, unknown>,
) {
  return {
    ...activatorProps,
    ...tooltipProps,
  }
}
</script>

<style scoped>
.menu-children {
  border-inline-start: 1px solid rgba(var(--v-border-color), var(--v-border-opacity));
  padding-inline-start: 0;
}

.menu-children--collapsed {
  border-inline-start: 0;
}

.menu-group--collapsed :deep(.v-list-group__items .v-list-item__prepend),
.menu-item--collapsed :deep(.v-list-item__prepend) {
  width: 24px;
}
</style>
