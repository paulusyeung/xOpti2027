/**
 * Development and test fixture only. Resolved from the `@analytics-fixtures`
 * alias in non-production builds; production builds use an empty stub so this
 * data is never bundled.
 */
/** Marker searched for by scripts/check-build-output.mjs; must never appear in production output. */
export const PIVOT_FIXTURE_MARKER = 'xopti-pivot-fixture-v1'

export const pivotFixtureRows: Record<string, string | number>[] | null = [
  { Branch: 'Richmond', Category: 'Frames', Quarter: 'Q1', Sales: 12840, Cost: 6210 },
  { Branch: 'Richmond', Category: 'Lenses', Quarter: 'Q1', Sales: 9310, Cost: 4120 },
  { Branch: 'Richmond', Category: 'Frames', Quarter: 'Q2', Sales: 14005, Cost: 6780 },
  { Branch: 'Richmond', Category: 'Lenses', Quarter: 'Q2', Sales: 10230, Cost: 4475 },
  { Branch: 'Surrey', Category: 'Frames', Quarter: 'Q1', Sales: 8120, Cost: 3995 },
  { Branch: 'Surrey', Category: 'Lenses', Quarter: 'Q1', Sales: 6440, Cost: 2890 },
  { Branch: 'Surrey', Category: 'Frames', Quarter: 'Q2', Sales: 8960, Cost: 4310 },
  { Branch: 'Surrey', Category: 'Lenses', Quarter: 'Q2', Sales: 7015, Cost: 3050 },
]
