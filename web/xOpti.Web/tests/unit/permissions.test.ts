import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { describe, expect, it } from 'vitest'
import { PermissionNames } from '@/security/permissions'

// Tests run from the web project directory (npm scripts set the working directory).
const backendSource = resolve(process.cwd(), '../../src/xOpti.Application/Authorization/PermissionNames.cs')

function backendPermissions(): string[] {
  const text = readFileSync(backendSource, 'utf8')
  return [...text.matchAll(/public const string \w+ = "([^"]+)";/g)].map((m) => m[1]).sort()
}

describe('permission names', () => {
  it('match the backend PermissionNames source exactly', () => {
    const client = Object.values(PermissionNames).sort()
    expect(client).toEqual(backendPermissions())
  })
})
