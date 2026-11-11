/// <reference types="vitest/config" />
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vuetify from 'vite-plugin-vuetify'

/**
 * WebPivotTable 7.1.1 creates a Memory-mode worker from a hashed URL
 * (`/assets/memory.worker-*.js`) that is not included in the npm package. Vite
 * would try to resolve that URL at build time and fail. This rewrites only that
 * one expression so it is resolved at runtime; the library already falls back to
 * the main thread when the worker cannot load.
 */
const webPivotWorkerUrl = {
  name: 'xopti-webpivottable-worker-url',
  enforce: 'pre' as const,
  transform(code: string, id: string) {
    if (!id.replace(/\\/g, '/').includes('node_modules/webpivottable/dist/wpt.esm.js')) {
      return null
    }
    const pattern = /new URL\(\s*\/\* @vite-ignore \*\/\s*"\/assets\/memory\.worker-[A-Za-z0-9]+\.js",/
    if (!pattern.test(code)) {
      throw new Error('WebPivotTable worker URL not found; review the xopti-webpivottable-worker-url plugin')
    }
    return {
      code: code.replace(pattern, 'new URL(/* xopti: runtime-resolved */ ["", "assets", "memory.worker.js"].join("/"),'),
      map: null,
    }
  },
}

export default defineConfig(({ mode }) => {
  // The analytics fixture is included only in development and test modes.
  // Production builds (mode "production") resolve to an empty stub, so no
  // fixture data reaches the bundle.
  const includeFixtures = mode !== 'production'

  return {
    plugins: [
      webPivotWorkerUrl,
      vue({
        template: {
          compilerOptions: {
            // WebPivotTable is a custom element; keep the Vue compiler from treating it as a component.
            isCustomElement: (tag) => tag === 'web-pivot-table',
          },
        },
      }),
      vuetify({ autoImport: true }),
    ],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
        '@contract': fileURLToPath(new URL('../../api-contract/generated', import.meta.url)),
        '@analytics-fixtures': includeFixtures
          ? fileURLToPath(new URL('./src/features/analytics/fixtures/pivot-fixture.ts', import.meta.url))
          : fileURLToPath(new URL('./src/features/analytics/fixtures/empty-fixture.ts', import.meta.url)),
      },
    },
    server: {
      port: 5173,
      fs: {
        // Allow importing the committed contract from the repository root.
        allow: [fileURLToPath(new URL('../..', import.meta.url))],
      },
      proxy: {
        '/api': {
          target: process.env.XOPTI_API_URL ?? 'http://127.0.0.1:5199',
          changeOrigin: false,
        },
      },
    },
    build: {
      // The WebPivotTable chunk is large by design and is only loaded on the analytics route.
      chunkSizeWarningLimit: 6000,
      commonjsOptions: {
        // WebPivotTable is an ES module that builds a worker from a URL; the CJS
        // transform must not try to resolve that URL as a build-time module.
        exclude: [/node_modules\/webpivottable\//],
      },
    },
    test: {
      environment: 'jsdom',
      server: {
        // Vuetify ships CSS imports that Node cannot load; let Vite transform them.
        deps: { inline: [/vuetify/] },
      },
      globals: true,
      include: ['tests/unit/**/*.test.ts', 'tests/component/**/*.test.ts'],
      setupFiles: ['tests/setup.ts'],
      alias: {
        webpivottable: fileURLToPath(new URL('./tests/mocks/webpivottable.ts', import.meta.url)),
      },
    },
  }
})
