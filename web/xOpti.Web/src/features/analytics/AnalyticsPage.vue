<script setup lang="ts">
import { getRuntimeConfig } from '@/runtime/config'
import { pivotFixtureRows } from '@analytics-fixtures'
import WptPivotView from './WptPivotView.vue'

const config = getRuntimeConfig()
</script>

<template>
  <div>
    <h1 class="text-h5 mb-4">Analytics</h1>

    <v-alert
      v-if="!config.wptLicenseKey"
      type="warning"
      variant="tonal"
      data-testid="analytics-config-error"
    >
      Analytics is not configured: a licence key is required before the analytics component can load.
    </v-alert>

    <!-- The component (and its module import) is not created without a licence key. -->
    <WptPivotView
      v-else
      :license-key="config.wptLicenseKey"
      :fixture-rows="pivotFixtureRows"
    />
  </div>
</template>
