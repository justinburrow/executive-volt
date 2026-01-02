import {
	pgEnum,
	varchar,
	date,
	numeric,
	pgTable,
	serial,
	text,
	timestamp,
	integer,
	jsonb,
	uuid,
	index
} from 'drizzle-orm/pg-core';
import { lte } from 'drizzle-orm';

const timestamps = {
	updated_at: timestamp(),
	created_at: timestamp().defaultNow().notNull(),
	deleted_at: timestamp()
};

export const confidence = pgEnum('confidence', ['high', 'low']);

export const componentTypes = pgTable('component_types', {
	id: serial().primaryKey(),
	name: varchar().notNull().unique(),
	description: text(),
	spec_schema: jsonb('spec_schema'),
	...timestamps
});

export const locations = pgTable('locations', {
	id: serial().primaryKey(),
	name: varchar().notNull().unique(),
	description: text(),
	...timestamps
});

export const components = pgTable(
	'components',
	{
		id: uuid().primaryKey().defaultRandom().unique(),
		type_id: uuid().references(() => componentTypes.id),

		// common
		name: varchar().notNull().unique(),
		manufacturer: varchar(),
		part_number: varchar(),
		manufacturer_part_number: text(),

		// inventory
		quantity: integer('inventory').default(0).notNull(),
		reorder_threshold: integer(),

		// location
		location_id: uuid().references(() => locations.id),
		location_detail: text(),

		// specs
		specs: jsonb().notNull().default('{}'),

		// metadata
		notes: text(),
		datasheet_url: varchar(),
		identity_confidence: confidence().default('high'),
		...timestamps
	},
	(table) => [
		index('idx_components_specs').using('GIN', table.specs),
		index('idx_components_type').on(table.id),
		index('idx_components_quantity')
			.on(table.quantity)
			.where(lte(table.quantity, table.reorder_threshold)),
		index('idx_components_mpn').on(table.manufacturer_part_number)
	]
);

export const suppliers = pgTable('suppliers', {
	id: serial().primaryKey(),
	name: varchar().notNull().unique(),
	url: varchar().notNull(),
	city: varchar().notNull(),
	state: varchar().notNull(),
	zip: varchar(),
	customer_service_email: varchar(),
	...timestamps
});

export const supplierPartNumbers = pgTable(
	'supplier_part_numbers',
	{
		id: serial().primaryKey(),
		component_id: uuid(),
		supplier_id: serial().references(() => suppliers.id),
		supplier_part_number: varchar().notNull().unique(),
		supplier_description: text(),
		last_seen_at: timestamp()
	},
	(table) => [index('idx_supplier_pnlookup').on(table.supplier_id, table.supplier_part_number)]
);

export const projects = pgTable('projects', {
	id: uuid().primaryKey(),
	name: varchar().unique().notNull(),
	description: text(),
	parts_lists: jsonb(),
	...timestamps
});

export const bom_lines = pgTable('bom_lines', {
	id: uuid().primaryKey(),
	project_id: uuid().references(() => projects.id),
	component_id: uuid().references(() => components.id),
	required_specs: jsonb().notNull(),
	qty_needed: integer().notNull(),
	designators: text(),
	notes: text(),
	...timestamps
});

export const purchases = pgTable('purchases', {
	id: uuid().primaryKey(),
	component_id: uuid().references(() => components.id),
	supplier_id: serial().references(() => suppliers.id),
	quantity: integer().notNull(),
	unit_price: numeric({ precision: 10, scale: 4 }),
	currency: text().default('usd'),
	order_reference: text(),
	purchased_at: date().notNull(),
	notes: text(),
	...timestamps
});
