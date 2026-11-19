<script setup lang="ts">
import { computed } from 'vue'
import colors from 'vuetify/util/colors'
import { appSchemes, useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()

const currentSchemes = computed(() => {
  const ids = appSchemes[themeStore.mode]
  return ids.map((id) => ({
    id,
    label: schemeLabel(id),
    previewColor: (colors as Record<string, { base?: string }>)[id]?.base ?? '#ccc',
  }))
})

function schemeLabel(id: string): string {
  return id
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, (character) => character.toUpperCase())
}

function onModeChange(value: unknown): void {
  if (value === 'light' || value === 'dark') {
    themeStore.setMode(value)
  }
}

function onSchemeChange(value: unknown): void {
  if (typeof value === 'string') {
    themeStore.setScheme(value)
  }
}
</script>

<template>
  <div class="theme-settings">
    <div class="d-flex align-center justify-space-between mb-4">
      <div class="text-subtitle-1 font-weight-bold">Color scheme</div>
      <v-btn-toggle
        :model-value="themeStore.mode"
        mandatory
        divided
        rounded="lg"
        color="primary"
        variant="outlined"
        density="compact"
        data-testid="theme-mode"
        @update:model-value="onModeChange"
      >
        <v-btn value="light" size="small">
          <v-icon start icon="mdi-white-balance-sunny" />
          Light
        </v-btn>
        <v-btn value="dark" size="small">
          <v-icon start icon="mdi-weather-night" />
          Dark
        </v-btn>
      </v-btn-toggle>
    </div>

    <v-item-group
      :model-value="themeStore.scheme"
      mandatory
      @update:model-value="onSchemeChange"
    >
      <v-row dense>
        <v-col v-for="scheme in currentSchemes" :key="scheme.id" cols="3">
          <v-item v-slot="{ isSelected, toggle }" :value="scheme.id">
            <v-card
              :class="['scheme-card', { 'active-scheme': isSelected }]"
              flat
              v-ripple
              @click="toggle"
            >
              <div class="scheme-preview" :style="{ background: scheme.previewColor }">
                <v-icon
                  v-if="isSelected"
                  color="white"
                  icon="mdi-check-circle"
                  size="small"
                  class="check-icon"
                />
              </div>
              <v-card-text class="pa-2 text-center text-caption">
                {{ scheme.label }}
              </v-card-text>
            </v-card>
          </v-item>
        </v-col>
      </v-row>
    </v-item-group>
  </div>
</template>

<style scoped>
.scheme-card {
  cursor: pointer;
  transition: all 0.2s ease-in-out;
  border: 2px solid transparent !important;
}

.scheme-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.scheme-card.active-scheme {
  border-color: rgb(var(--v-theme-primary)) !important;
  background-color: rgba(var(--v-theme-primary), 0.05);
}

.scheme-preview {
  height: 48px;
  width: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.check-icon {
  position: absolute;
  top: 4px;
  right: 4px;
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.5));
}
</style>
