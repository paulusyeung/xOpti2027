# Report letterhead configuration

The shop identity printed on reports is **not hard-coded**. It is read at
generation time from the existing `public.preference` row, so changing it does
not require a rebuild or a database migration.

## Source of truth

`public.preference` is a legacy table already present in the migrated schema.
`IPreferencesStore` reads the first row ordered by `serial_number`.

| Printed value | Preference column | DTO property |
| --- | --- | --- |
| Shop / branch name (header line 1, bar-code label) | `user_name` | `UserName` |
| Legal company name (header line 2) | `owner_name` | `OwnerName` |
| Street line | `user_address` | `UserAddress` |
| City | `user_city` (code → `public.city.city_name`) | `UserCityCode`, `UserCityName` |
| Province | `user_province` | `UserProvince` |
| Country | `user_country` (code → `public.country.country_name`) | `UserCountryCode`, `UserCountryName` |
| Postal code | `user_postal_code` | `UserPostalCode` |
| Phone | `user_phone` | `UserPhone` |
| Fax | `user_fax` | `UserFax` |
| GST number | `gst_number` | `GstNumber` |

The letterhead address is composed into one line in this order:

```
street, city, province COUNTRY POSTAL
```

Blank components are skipped. `user_city` is a legacy code resolved through
`public.city`; when `user_country` is blank the country code is taken from the
city row and resolved through `public.country`. For example:

```
105 - 4231 Hazelbridge, RICHMOND, BC CANADA V6X3L7
```

If every component is blank, the legacy Crystal address is used as a fallback.

`gst_number` is normalised to the legacy `R-` prefix when it is missing.

## Changing the values

Use the existing, audited preferences API:

```bash
GET  /api/v1/admin/preferences
PUT  /api/v1/admin/preferences
```

Requires the `master-data:maintain` permission. Example body:

```json
{
  "productName": "Synergy V for Optical",
  "userName": "The Optical Centre, Robson",
  "userAddress": "1190 ROBSON STREET",
  "userCityCode": 11,
  "userProvince": "BC",
  "userPostalCode": "V6E 1B2",
  "userCountryCode": "CA",
  "ownerName": "The Optical International Investment Company Ltd.",
  "userPhone": "(604) 699-9368",
  "userFax": "(604) 899-9367",
  "gstNumber": "R-896634235",
  "pstNumber": "PST...",
  "taxARate": 0,
  "taxBRate": 0,
  "reason": "Update claims receipt letterhead"
}
```

Omitted optional fields are left unchanged. The update is written to
`platform.audit_log` with action `preference.update`.

There is no dedicated preferences screen yet; the API is the supported editing
surface. A future admin screen can call the same endpoints.

## Fallback behaviour

`ReportLetterheadDto.From(PreferencesDto)` supplies the legacy Crystal values
when a preference value is blank, so an unconfigured or partially migrated
database still produces a usable document. The fallbacks live in
`src/xOpti.Application/Reporting/ReportLetterhead.cs` only — nowhere else.

## Reports using it

- **Claims Receipt** (Special Reports) — all header lines and report title.
- **Bar Code Tag** (Special Reports) — the `THE OPTICAL CENTRE` label header.
- **Invoice** (Special Reports) — header line, report title, footer identity, phone/fax and GST number.

Other documents (invoice, order, POS receipt, statements, packing lists) print
customer, supplier or shipping addresses supplied by their own data, not the
shop letterhead, so they have no hard-coded shop identity. Report-specific
boilerplate such as `INSURANCE COMPANY PLEASE NOTE` and
`Signature of dispensing optician` is part of the Crystal layout and is not
configurable.

## Why not the `branch` table?

`public.branch` holds name, address, phone and fax, but has no tax-number or
legal-company column, and its `summary_flag` already means "summary branch",
not "default". Adding `is_default` or tax columns would require a schema change
and a migration. `public.preference` already holds every field and already has
an update API, so it is the zero-migration option.

## Verification

- `ReportLetterheadTests` covers configured values and legacy fallbacks.
- `PreferencesAndImportTests` covers persistence and auditing of the new
  phone/fax fields.
- Claim receipt and bar-code tag integration tests render PDFs using whatever
  the preference row contains.
