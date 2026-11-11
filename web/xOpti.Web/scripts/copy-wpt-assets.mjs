// Copies WebPivotTable locale resources from the installed package into
// public/vendor so they are served from this application's own origin.
import { cpSync, existsSync, mkdirSync, rmSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const source = resolve(root, 'node_modules/webpivottable/dist/locales')
const target = resolve(root, 'public/vendor/webpivottable/locales')

if (!existsSync(source)) {
  console.error(`WebPivotTable locales not found at ${source}. Run npm ci first.`)
  process.exit(1)
}

rmSync(target, { recursive: true, force: true })
mkdirSync(dirname(target), { recursive: true })
cpSync(source, target, { recursive: true })
console.log(`Copied WebPivotTable locales to ${target}`)
