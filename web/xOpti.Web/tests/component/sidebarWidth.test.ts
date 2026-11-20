import { beforeEach, describe, expect, it } from 'vitest'
import {
  SIDEBAR_WIDTH_DEFAULT,
  SIDEBAR_WIDTH_MAX,
  SIDEBAR_WIDTH_MIN,
  clampSidebarWidth,
  readSidebarWidth,
  storeSidebarWidth,
} from '@/layout/sidebarWidth'

beforeEach(() => {
  localStorage.clear()
})

describe('sidebar width', () => {
  it('clamps widths to the supported range', () => {
    expect(clampSidebarWidth(100)).toBe(SIDEBAR_WIDTH_MIN)
    expect(clampSidebarWidth(9999)).toBe(SIDEBAR_WIDTH_MAX)
    expect(clampSidebarWidth(318.6)).toBe(319)
    expect(clampSidebarWidth(Number.NaN)).toBe(SIDEBAR_WIDTH_DEFAULT)
  })

  it('defaults when nothing is stored', () => {
    expect(readSidebarWidth()).toBe(SIDEBAR_WIDTH_DEFAULT)
  })

  it('persists and restores a valid width', () => {
    storeSidebarWidth(320)
    expect(readSidebarWidth()).toBe(320)
  })

  it('ignores invalid stored values', () => {
    localStorage.setItem('xopti.sidebar.width', 'not-a-number')
    expect(readSidebarWidth()).toBe(SIDEBAR_WIDTH_DEFAULT)
  })
})
