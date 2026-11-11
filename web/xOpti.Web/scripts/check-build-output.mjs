// Post-build gates for dist/:
//  1. No development fixture data in the production output.
//  2. No configured secret (XOPTI_WPT_LICENSE_KEY) and no common credential patterns.
//  3. Initial (entry + statically imported) JavaScript stays within the agreed budget.
//  4. The WebPivotTable component is not part of the initial JavaScript.
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs'
import { dirname, join, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { gzipSync } from 'node:zlib'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const dist = resolve(root, 'dist')
// Initial JavaScript budget (gzip, KiB). Agreed with the change design; raise only with a recorded decision.
const INITIAL_JS_BUDGET_GZIP_KIB = 260

const failures = []

if (!existsSync(dist)) {
  console.error('dist/ not found. Run the build first.')
  process.exit(1)
}

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name)
    return statSync(path).isDirectory() ? walk(path) : [path]
  })
}

const files = walk(dist)
const textFiles = files.filter((f) => /\.(js|mjs|html|css|json|map)$/.test(f))

const fixtureMarker = 'xopti-pivot-fixture-v1'
const secret = process.env.XOPTI_WPT_LICENSE_KEY?.trim()
const credentialPatterns = [
  { name: 'PEM private key', re: /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/ },
  { name: 'AWS access key id', re: /\bAKIA[0-9A-Z]{16}\b/ },
  { name: 'OpenAI-style secret key', re: /\bsk-[A-Za-z0-9_-]{32,}\b/ },
]

for (const file of textFiles) {
  const content = readFileSync(file, 'utf8')
  const rel = relative(dist, file)
  if (content.includes(fixtureMarker)) {
    failures.push(`fixture data present in ${rel}`)
  }
  if (secret && secret.length >= 8 && content.includes(secret)) {
    failures.push(`configured licence key present in ${rel}`)
  }
  for (const pattern of credentialPatterns) {
    if (pattern.re.test(content)) {
      failures.push(`${pattern.name} pattern in ${rel}`)
    }
  }
}

// Initial graph: index.html entry script plus modulepreload links.
const html = readFileSync(join(dist, 'index.html'), 'utf8')
const initialRefs = [...html.matchAll(/(?:src|href)="\/?(assets\/[^"]+\.js)"/g)].map((m) => m[1])
const initialFiles = [...new Set(initialRefs)].map((r) => join(dist, r))
const initialGzip = initialFiles.reduce((sum, f) => sum + gzipSync(readFileSync(f)).length, 0)
const initialKib = initialGzip / 1024

if (initialKib > INITIAL_JS_BUDGET_GZIP_KIB) {
  failures.push(`initial JavaScript ${initialKib.toFixed(1)} KiB gzip exceeds budget ${INITIAL_JS_BUDGET_GZIP_KIB} KiB`)
}

const wptInInitial = initialFiles.some((f) => /web-pivot-table|webpivottable/i.test(readFileSync(f, 'utf8')))
if (wptInInitial) {
  failures.push('WebPivotTable code is included in the initial JavaScript')
}

// The analytics route chunk must not be preloaded or referenced by the entry.
const analyticsPreloaded = [...html.matchAll(/(?:src|href)="\/?(assets\/AnalyticsPage[^"]+\.js)"/g)]
if (analyticsPreloaded.length > 0) {
  failures.push('analytics route chunk is preloaded by index.html')
}
// The entry may name the lazy chunk in its import map; it must not contain the screen's own code.
const analyticsMarkers = ['analytics-config-error', 'data-testid":"wpt-view', 'wpt-loading']
const entryHasAnalyticsCode = initialFiles.some((f) => {
  const content = readFileSync(f, 'utf8')
  return analyticsMarkers.some((marker) => content.includes(marker))
})
if (entryHasAnalyticsCode) {
  failures.push('analytics screen code is included in the initial JavaScript')
}

console.log(`Initial JavaScript: ${initialKib.toFixed(1)} KiB gzip (budget ${INITIAL_JS_BUDGET_GZIP_KIB} KiB)`)

if (failures.length > 0) {
  console.error('Build output check failed:')
  for (const failure of failures) {
    console.error(`  - ${failure}`)
  }
  process.exit(1)
}
console.log('Build output check passed.')
