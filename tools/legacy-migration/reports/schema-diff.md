# MDB to xOpti comparison

## Schema

- Source tables: 70
- Target base tables: 71
- Source-only tables: none
- Target-only base tables: users
- Missing columns: 0
- Corrected source typos: 3
  - `preference.paltform` -> `platform`
  - `txsorderlens.rigthbase` -> `right_base`
  - `txsorderlens.rigthoc` -> `right_oc`
- Type differences: 198
  - NUMERIC(15,2) -> numeric(19,4): 116
  - REAL -> double precision: 82
- Unexpected type differences: 0
- Nullability differences: 49 (16 tightened, 33 relaxed)

