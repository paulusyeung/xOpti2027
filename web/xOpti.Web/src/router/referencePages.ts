import type { components } from '@contract/xopti-client'

export type ReferenceKind = components['schemas']['ReferenceKind']

export interface ReferencePage {
  /** Exact legacy menu label this page belongs to. */
  label: string
  /** Stable route id appended to /admin/reference/. */
  id: string
  kind: ReferenceKind
  title: string
  subtitle: string
  keyLabel: string
  nameLabel: string
  parentLabel?: string
  detailLabel?: string
}

export const REFERENCE_PAGES: readonly ReferencePage[] = [
  // Coding
  {
    label: 'Department', id: 'departments', kind: 'Department',
    title: 'Departments', subtitle: 'Maintain departments used to group classes and categories.',
    keyLabel: 'Code', nameLabel: 'Department',
  },
  {
    label: 'Class', id: 'classes', kind: 'Class',
    title: 'Classes', subtitle: 'Maintain classes within a department.',
    keyLabel: 'Code', nameLabel: 'Class', parentLabel: 'Department',
  },
  {
    label: 'Category', id: 'categories', kind: 'Category',
    title: 'Categories', subtitle: 'Maintain categories within a class.',
    keyLabel: 'Code', nameLabel: 'Category', parentLabel: 'Department / Class', detailLabel: 'Methods',
  },
  {
    label: 'Brand', id: 'brands', kind: 'Brand',
    title: 'Brands', subtitle: 'Maintain the brands used on inventory items.',
    keyLabel: 'Code', nameLabel: 'Brand',
  },
  {
    label: 'Add', id: 'adds', kind: 'Add',
    title: 'Add Codes', subtitle: 'Maintain add-on codes used on optical orders.',
    keyLabel: 'Code', nameLabel: 'Description',
  },
  {
    label: 'Material', id: 'materials', kind: 'Material',
    title: 'Materials', subtitle: 'Maintain frame and lens materials.',
    keyLabel: 'Code', nameLabel: 'Material',
  },
  {
    label: 'Doctor', id: 'doctors', kind: 'Doctor',
    title: 'Doctors', subtitle: 'Maintain referring doctors and their contact details.',
    keyLabel: 'ID', nameLabel: 'Doctor', detailLabel: 'Address',
  },
  {
    label: 'Branch', id: 'branches', kind: 'Branch',
    title: 'Branches', subtitle: 'Maintain company branches and their contact details.',
    keyLabel: 'Code', nameLabel: 'Branch', parentLabel: 'City', detailLabel: 'Phone',
  },
  {
    label: 'Payment', id: 'payment-methods', kind: 'PaymentMethod',
    title: 'Payment Methods', subtitle: 'Maintain payment methods and their exchange rates.',
    keyLabel: 'Code', nameLabel: 'Payment Method', detailLabel: 'Short name / rate',
  },

  // Report > Coding listings
  {
    label: 'Add Code Listing', id: 'add-code-listings', kind: 'Add',
    title: 'Add Code Listings', subtitle: 'Review the add-on codes available to reports.',
    keyLabel: 'Code', nameLabel: 'Description',
  },
  {
    label: 'Brand Code Listing', id: 'brand-code-listings', kind: 'Brand',
    title: 'Brand Code Listings', subtitle: 'Review the brands available to reports.',
    keyLabel: 'Code', nameLabel: 'Brand',
  },
  {
    label: 'Category Code Listing', id: 'category-code-listings', kind: 'Category',
    title: 'Category Code Listings', subtitle: 'Review the categories available to reports.',
    keyLabel: 'Code', nameLabel: 'Category', parentLabel: 'Department / Class', detailLabel: 'Methods',
  },
  {
    label: 'Class Code Listing', id: 'class-code-listings', kind: 'Class',
    title: 'Class Code Listings', subtitle: 'Review the classes available to reports.',
    keyLabel: 'Code', nameLabel: 'Class', parentLabel: 'Department',
  },
  {
    label: 'Department Code Listing', id: 'department-code-listings', kind: 'Department',
    title: 'Department Code Listings', subtitle: 'Review the departments available to reports.',
    keyLabel: 'Code', nameLabel: 'Department',
  },
  {
    label: 'Material Code Listing', id: 'material-code-listings', kind: 'Material',
    title: 'Material Code Listings', subtitle: 'Review the materials available to reports.',
    keyLabel: 'Code', nameLabel: 'Material',
  },

  // Preference
  {
    label: 'City', id: 'cities', kind: 'City',
    title: 'Cities', subtitle: 'Maintain the cities used in customer, supplier and doctor addresses.',
    keyLabel: 'Code', nameLabel: 'City', parentLabel: 'Province / Country',
  },
  {
    label: 'Province', id: 'provinces', kind: 'Province',
    title: 'Provinces', subtitle: 'Maintain provinces and states used in addresses.',
    keyLabel: 'Code', nameLabel: 'Province',
  },
  {
    label: 'Country', id: 'countries', kind: 'Country',
    title: 'Countries', subtitle: 'Maintain countries used in addresses.',
    keyLabel: 'Code', nameLabel: 'Country',
  },
  {
    label: 'Job Title', id: 'job-titles', kind: 'JobTitle',
    title: 'Job Titles', subtitle: 'Maintain job titles for staff and contacts.',
    keyLabel: 'Code', nameLabel: 'Job Title',
  },
  {
    label: 'Job Nature', id: 'job-natures', kind: 'JobNature',
    title: 'Job Natures', subtitle: 'Maintain job natures for staff and contacts.',
    keyLabel: 'Code', nameLabel: 'Job Nature',
  },
  {
    label: 'Salutation', id: 'salutations', kind: 'Salutation',
    title: 'Salutations', subtitle: 'Maintain salutations used on letters and reports.',
    keyLabel: 'Value', nameLabel: 'Salutation',
  },
]

export const DEFAULT_REFERENCE_PAGE = REFERENCE_PAGES[2]!

export function referencePageByLabel(label: string): ReferencePage | undefined {
  return REFERENCE_PAGES.find((page) => page.label === label)
}

export function referencePageById(id: string): ReferencePage | undefined {
  return REFERENCE_PAGES.find((page) => page.id === id)
}

export function referencePageByPath(path: string): ReferencePage | undefined {
  const id = path.split('/').filter(Boolean).at(-1)
  return id ? referencePageById(id) : undefined
}

export function referencePath(page: ReferencePage): string {
  return `/admin/reference/${page.id}`
}
