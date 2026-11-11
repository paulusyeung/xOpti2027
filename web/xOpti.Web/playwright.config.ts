import { defineConfig, devices } from '@playwright/test'

// Runs against the containerised stack (web -> api -> PostgreSQL) by default.
// Override with XOPTI_E2E_BASE_URL, e.g. the Vite dev server for fixture-based checks.
const baseURL = process.env.XOPTI_E2E_BASE_URL ?? 'http://127.0.0.1:18085'

export default defineConfig({
  testDir: 'tests/e2e',
  testMatch: /.*\.spec\.ts/,
  timeout: 60_000,
  expect: { timeout: 10_000 },
  workers: 1,
  fullyParallel: false,
  reporter: [['list']],
  use: {
    baseURL,
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
})
