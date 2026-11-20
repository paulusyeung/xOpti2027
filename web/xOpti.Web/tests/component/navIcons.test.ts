import { readFileSync } from 'node:fs'
import { createRequire } from 'node:module'
import { describe, expect, it } from 'vitest'
import { NAV_ITEMS, type NavItem } from '@/router/nav'

const require = createRequire(import.meta.url)
const mdiCss = readFileSync(
  require.resolve('@mdi/font/css/materialdesignicons.css'),
  'utf8',
)

function collectIcons(items: readonly NavItem[]): string[] {
  return items.flatMap((item) => [
    item.icon,
    ...collectIcons(item.children ?? []),
  ])
}

describe('navigation icons', () => {
  it('uses icon names that exist in the installed Material Design Icons font', () => {
    const missing = collectIcons(NAV_ITEMS).filter((icon) => !mdiCss.includes(`.${icon}::before`))
    expect(missing).toEqual([])
  })
})
